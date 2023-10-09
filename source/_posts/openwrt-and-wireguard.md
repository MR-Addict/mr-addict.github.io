---
title: 通过Wireguard实现Openwrt内网穿透
date: 2023-10-09 14:37:30
comments: true
tags:
  - wireguard
  - openwrt
description: 通过Wireguard实现Openwrt内网穿透
cover: /images/posts/openwrt-and-wireguard/cover.png
categories: 教程
---

虽然说 Wireguard 是一个艺术品(work of art)，但是只要和网络相关的都很难搞，经常是调试一整天网路还是不通，试了很多方法还是无济于事。

Wireguard 我已经接触很久了，中间断断续续用过很多回，总是各种网路不通搞到头大，然后就不弄了。

不过最近总算是搞通了，实现了 Wireguard 和 Openwrt 网段之间的互通，下面是我的折腾笔记。

> 这里我只提供 Wireguard 和 Openwrt 网段之间的互通的应用场景，更多的场景比如 Openwrt 通过 Wireguard 上网可以参考这篇文章，写的非常优秀，包含各种 Wireguard 应用场景，这篇文章我在配置的时候读了很多遍，受到的启发很多。
>
> - [MULTI-HOP WIREGUARD](https://www.procustodibus.com/blog/2022/06/multi-hop-wireguard/)

# 一、网络结构

在部署前，我们先认识一下我们的网络结构：

![openwert-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-diagram.png)

我们在公网服务器上部署一个 Wireguard 服务器，然后让 Openwrt 通过 Wireguard 连接到公网服务器，这样就可以实现 Openwrt 和公网服务器之间的互通。

Wireguard 的 VPN 隧道的网段是 `172.22.192.0/24`，Openwrt 的内网网段是 `192.168.6.0/24`，我们希望通过 Wireguard 客户端连接到公网服务器后，可以访问到 Openwrt 的内网网段 `192.168.6.0/24`，同时 Openwrt 的内网设备也可以访问到 Wireguard 的内网网段 `172.22.192.0/24`。

即实现了 Openwrt 和 Wireguard 之间的互通。

# 二、部署服务端

我们需要一台有公网的服务器，然后在上面安装 wiregaurd，这里我用的是 Ubuntu 22.04，其他系统也是类似的。

## 1. 安装 Wireguard

```sh
sudo apt-get install wireguard -y
```

## 2. 配置 Wireguard

使用以下命令分别为`服务器`，`openwrt`和`客户端`生成三对公钥和私钥，后面的配置会用到：

```sh
wg genkey | tee private.key | wg pubkey > public.key
```

新建一个配置文件：

```sh
sudo vim /etc/wireguard/wg0.conf
```

添加类似以下内容：

```conf
[Interface]
PrivateKey = server_private_key
Address = 172.22.192.1/32
ListenPort = 51820
SaveConfig = false

PostUp = iptables -A FORWARD -i wg0 -j ACCEPT && iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT && iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE

# openwrt
[Peer]
PublicKey = openwrt_public_key
AllowedIPs = 172.22.192.110/32, 192.168.6.0/24

# client
[Peer]
PublicKey = client_public_key
AllowedIPs = 172.22.192.111/32
```

将其中的 key 换成上面生成的对应设备的公钥和私钥。

需要注意的是，`PostUp`和`PostDown`这两个配置，这里的`eth0`是服务器的网卡，如果你的服务器网卡不是`eth0`，需要将其换成你的网卡名称。

你可以使用下面的命令查看你的服务器网卡名称：

```sh
ip route list table main default
```

例如，如果返回的是 `default via 172.18.224.1 dev enp4s0 proto dhcp src 172.18.224.100 metric 100`，那么你的网卡名称就是 `enp4s0`。

另外你会发现，在 Openwrt 的 Peer 的 AllowedIPs 中，分别是 172.22.192.110/32 和 192.168.6.0/24，前一个是 Openwrt 的 Wireguard 内网地址，后一个是 Openwrt 的内网网段。换句话说，如果有请求的目标是 172.22.192.110/32 和 192.168.6.0/24 时，Wireguard 就会将其转发给 Openwrt 对端。

这就是我们能够访问 Openwrt 内网网段的关键！

## 3. 配置防火墙

首先我们需要打开 Ubuntu 的防火墙，如果你的 ufw 防火墙没有打开，那么你就不需要打开。

```sh
sudo ufw allow 51820/udp
```

然后我们需要允许转发，编辑 `/etc/sysctl.conf` 文件，将 `net.ipv4.ip_forward=1` 的注释去掉，然后执行 `sysctl -p` 命令使其生效。

```conf
net.ipv4.ip_forward=1
```

## 3. 启动 Wireguard

最后启动 wireguard 就可以了：

```sh
wg-quick up wg0
```

# 三、配置 Openwrt

你的 Openwrt 需要安装 Wireguard 插件，这里我就跳过这一步骤了。

## 1. 配置 Wireguard

### 1.1 添加接口

在 Openwrt 的网络配置中，添加一个 Wireguard 接口：

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-interface-new.png)

### 1.2 修改常规设置

然后在常规设置中添加重要的的配置，如私钥和 IP 地址：

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-interface-general.png)

### 1.3 创建防火墙

在防火墙设置中，创建一个新的防火墙区域 wg：

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-interface-firewall.png)

### 1.4 添加对端

最后新建一个 Peer 对端，也就是配置公网服务的信息，允许的 IP 必须是 `172.22.192.0/24`，勾选路由允许的 IP，可以给一个持续 Keep-Alive 让 Openwrt 主动保持连接服务器：

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-interface-peer.png)

### 1.5 检查 Wireguard 连接

最后保存并应用就可以了，如果一切正常，你就可以在 Openwrt 的网络状态中看到 Wireguard 的状态了：

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-status.png)

## 2. 配置防火墙

虽然我们在 Wireguard 的 Peer 中配置了防火墙，但是 Openwrt 的防火墙还是需要配置一下的，这里我就不多说了，直接上图：

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-firewall.png)

我们要允许 lan 的流量转发到 wg 口，这样 lan 口的设备才能访问到 wg 口的设备。类似的我们还要允许 wg 口的流量转发到 lan 口。

需要特别注意的是我们要勾选 wg 的 IP 动态伪装和 MSS 钳制，这样才能让 Openwrt 把来自 lan 口的请求正常地发送到 wg 口。这是个大坑，我搞了好久才发现这个问题，不然 lan 口设备就没法访问 wg 口的设备。

![openwrt-wireguard](/images/posts/openwrt-and-wireguard/openwrt-wireguard-firewall-mss.png)

至此我们就完成了 Openwrt 和 Wireguard 的配置了，如果一切正常，我们就可以在 Wireguard 的客户端访问到 Openwrt 的内网网段了。最后让我们简单配置以下客户端的 Wireguard。

# 四、配置客户端

客户端的话，你可以使用 Wireguard 官方的客户端，Linux，Windows，MacOS，Android，iOS 都有，下载地址在这里[https://www.wireguard.com/install](https://www.wireguard.com/install)。

下面我以 Windows 为例，下面是我配置的客户端的 Wireguard 的配置文件：

```conf
[Interface]
PrivateKey = client_private_key
Address = 172.22.192.210/32

[Peer]
PublicKey = server_public_key
AllowedIPs = 172.22.192.0/24, 192.168.6.0/24
Endpoint = server_pubic_ip:51820
```

这里尤其要注意添加 172.22.192.0/24 和 192.168.6.0/24，这样 Wireguard 客户端才能访问到 Openwrt 的内网网段。

然后你就可以试试，是不是可以访问到 Openwrt 的内网网段，以及在 Openwrt 下访问 Wireguard 的内网网段。

# 五、总结

这篇文章主要是记录了我在配置 Wireguard 和 Openwrt 之间的互通的过程，希望对你能有帮助。
