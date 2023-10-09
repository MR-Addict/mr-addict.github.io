---
title: 给Ubuntu服务器上安装WiFi驱动
date: 2023-10-08 23:55:30
comments: true
tags:
  - ubuntu
  - 驱动
description: 给Ubuntu服务器上安装WiFi驱动
cover: /images/posts/install-wifi-driver-for-ubuntu-server/cover.jpg
categories: 教程
---

我的手上有一块 mini 主机，我用来做 Ubuntu 服务器的，它有一块 WiFi6 的 **RTL8852BE** 的网卡。但是 Ubuntu 服务器默认在安装时不会安装 WiFi 驱动，需要我们自己安装。

于是我就想着给小主机装一个驱动，这样有的时候就不需要拿到路由器旁边，接一堆线了。
下面是我在网上查阅资料后总结的安装 WiFi 驱动的步骤。

# 一、查看设备信息

安装驱动前，我们需要先确定 Ubuntu 的内核版本，以及 WiFi 网卡的型号。

## 1. 查看内核版本

使用以下命令查看你 Ubuntu 的内核版本：

```sh
uname -r
```

会有类似以下的输出：

```txt
5.15.0-86-generic
```

一般内核都是小于 5.18 的稳定版本，这在后面安装驱动会用到。

## 2. 查看网卡型号

我们还要安装对应 WiFi 型号的驱动。

使用以下命令查看你的网络设备：

```sh
sudo lshw -C network
```

找到描述是 `Wireless interface` 的设备，里面就有你网卡的具体信息：

```txt
*-network
      description: `Wireless interface`
      product: Realtek Semiconductor Co., Ltd.
      vendor: Realtek Semiconductor Co., Ltd.
      physical id: 0
      bus info: pci@0000:03:00.0
      logical name: wlp3s0
      version: 00
      serial: a8:43:a4:28:cb:4c
      width: 64 bits
      clock: 33MHz
      capabilities: pm msi pciexpress bus_master cap_list ethernet physical wireless
      configuration: broadcast=yes driver=rtl8852be driverversion=v1.15.6.0.2-0-gac110bf5.2021102 firmware=N/A ip=192.168.6.100 latency=0 link=yes multicast=yes wireless=IEEE 802.11AX
      resources: irq:144 ioport:3000(size=256) memory:50600000-506fffff
```

不过我这边只显示网卡是 Realtek 的，并没有具体的型号，于是我就在购买信息上找到了网卡的具体型号是 **RTL8852BE**。

# 二、下载、编译、安装驱动

这边的驱动都需要我们下载后手动编译，根据前面的内核版本和网卡信号，你可以前往这位大佬的 [GitHub 主页](https://github.com/lwfinger) 下载对应的驱动。但是我没有找到我的型号，但是我找到了另个一 [Github 仓库](https://github.com/HRex39/rtl8852be)，正好是我需要的驱动。

如果你也找不到的话，可能就需要自己上网找找了。

然后下载该驱动：

```sh
# 内核< 5.18
git clone https://github.com/HRex39/rtl8852be.git
# 内核>= 5.18
git clone https://github.com/HRex39/rtl8852be.git -b dev
```

下载完后编译安装：

```sh
cd rtl8852be
make -j8
sudo make install
```

编译结束后就可以使用了：

```sh
# 安装驱动
sudo modprobe 8852be
# 卸载驱动
sudo modprobe -r 8852be
```

这样的话，你使用下面的命令就可以发现你的 WiFi 驱动信息了，可能是 `wlan` 或者是 `wlp3s0` 这样的名称：

```sh
iwconfig
```

下面是配置好 WiFi 后的输出：

```txt
lo        no wireless extensions.

enp2s0    no wireless extensions.

wlp3s0    IEEE 802.11AX  ESSID:"OpenWrt"  Nickname:"<WIFI@REALTEK>"
          Mode:Managed  Frequency:5.22 GHz  Access Point: D4:35:38:92:9A:E6
          Bit Rate:1.201 Gb/s   Sensitivity:0/0
          Retry:off   RTS thr:off   Fragment thr:off
          Power Management:off
          Link Quality=72/100  Signal level=72/100  Noise level=0/100
          Rx invalid nwid:0  Rx invalid crypt:0  Rx invalid frag:0
          Tx excessive retries:0  Invalid misc:0   Missed beacon:0
```

# 三、配置 WiFi

驱动安装上之后，我们就可以配置 WiFi 了。

打开配置网络的配置文件，一般在 /etc/netplan 位置下：

```sh
ls /etc/netplan
```

可能是以下输出

```txt
00-installer-config.yaml
```

如果是多个文件，就看一下里面的内容，那一个是正在用的，我这边就一个：

然后在里面添加有关 WiFi 的信息，修改`wifi-interface`，`wifi-ssid`，`wifi-password` 三项就可以了,其他的不需要修改：

```yaml
network:
  version: 2

  ethernets:
    enp2s0:
      dhcp4: true

  wifis:
    wifi-interface:
      dhcp4: true
      access-points:
        wifi-ssid:
          password: wifi-password
```

可以看到里面有线网口的名称是 `enp2s0`，这和我们使用 `iwconfig` 看到的信息是一致的，这也印证了这个配置文件就是系统在使用的配置文件，你的 `wifi-interface` 也可以对应改成 `iwconfig` 里面网卡的名称，我这里就是 `wlp3s0`。

然后使用下面的命令检查配置文件有没有格式错误：

```sh
sudo netplan try
```

如果没有错误可以按回车确认：

```txt
Do you want to keep these settings?

Press ENTER before the timeout to accept the new configuration

Changes will revert in 106 seconds
Configuration accepted.
```

最后应用就可以了：

```sh
sudo netplan apply
```

成功连接上之后，使用 `ifconfig` 查看看口有没有分配到 IP 地址，如果有就表明 WiFi 配置成功了。

```txt
wlp3s0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.6.100  netmask 255.255.255.0  broadcast 192.168.6.255
        inet6 fd1d:e932:293a:0:aa43:a4ff:fe28:cb4c  prefixlen 64  scopeid 0x0<global>
        inet6 fe80::aa43:a4ff:fe28:cb4c  prefixlen 64  scopeid 0x20<link>
        inet6 fd1d:e932:293a::924  prefixlen 128  scopeid 0x0<global>
        ether a8:43:a4:28:cb:4c  txqueuelen 1000  (Ethernet)
        RX packets 0  bytes 2279554 (2.2 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 2257  bytes 282259 (282.2 KB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```
