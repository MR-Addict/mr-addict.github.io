---
title: 在 Proxmox VE 上安装和设置旁路由
comments: true
date: 2024-03-29 15:32:57
description: 在 Proxmox VE 上安装和设置旁路由
cover: /images/posts/install-and-setup-bypass-router-on-pve/cover.png
categories: 教程
tags:
  - openwrt
  - proxmox
---

本文介绍如何在 Proxmox VE 上安装和设置旁路由，以实现在 Proxmox VE 上运行 OpenWrt 虚拟机，从而实现旁路由功能。

## 一、构建固件

首先你需要准备一台 Proxmox VE 服务器，如果你还没有安装 Proxmox VE，可以参考[官方文档](https://pve.proxmox.com/wiki/Installation)进行安装。

另外你需要下载一个 OpenWrt 的镜像文件，这里我已 [OpenWrt-AI](https://openwrt.ai)为例，这个网站支持自定义编译 OpenWrt 镜像。当你选择 X86-64 平台后，可以直接配置好你需要的插件和设置成旁路由，使用起来很方便。

![openwrt-ai](/images/posts/install-and-setup-bypass-router-on-pve/openwrt-ai.jpeg)

构建完成后将镜像下载下来，我建议再改个名字。

然后我们可以将解压好的 OpenWrt 镜像上传到 Proxmox VE 服务器上，你可以使用PVE自带的ISO上传功能：

![upload-image](/images/posts/install-and-setup-bypass-router-on-pve/upload-image.png)

上传完成后，我们可以在 Proxmox VE 的 Web 界面上看到上传的镜像文件：

![uploaded-image](/images/posts/install-and-setup-bypass-router-on-pve/uploaded-image.png)

`/var/lib/vz/template/iso/openwrt.img` 就是镜像文件的位置了，这在后面导入磁盘的时候会用到。

## 二、创建 OpenWrt 虚拟机

我们创建一个新的虚拟机，**OS** 选择不使用任何介质：

![pve-os](/images/posts/install-and-setup-bypass-router-on-pve/pve-os.png)

**system** 保持默认：

![pve-system](/images/posts/install-and-setup-bypass-router-on-pve/pve-system.png)

点击删除符号删除硬盘：

![pve-delete-disk](/images/posts/install-and-setup-bypass-router-on-pve/pve-delete-disk.png)

**CPU**，**Memory** 和 **Network** 保持默认或者根据自己的需求调整：

![pve-cpu](/images/posts/install-and-setup-bypass-router-on-pve/pve-cpu.png)

![pve-memory](/images/posts/install-and-setup-bypass-router-on-pve/pve-memory.png)

![pve-network](/images/posts/install-and-setup-bypass-router-on-pve/pve-network.png)

最后确认一下配置，点击 **Finish** 完成创建，注意不要勾选 **Start after created**：

![pve-finish](/images/posts/install-and-setup-bypass-router-on-pve/pve-finish.png)

## 三、导入 OpenWrt 镜像

首先打开创建好的虚拟机，点击 **Hardware**，将 **CD/DVD Drive** 和 **Hard Disk** 删除：

![delete-dvd-drive-and-hard-disk](/images/posts/install-and-setup-bypass-router-on-pve/delete-dvd-drive-and-hard-disk.png)

然后通过 SSH 登录到 Proxmox VE 服务器，执行以下命令：

```bash
qm importdisk 100 /var/lib/vz/template/iso/openwrt.img local-lvm
```

你需要将**100**修改为你创建的虚拟机的 ID，`/var/lib/vz/template/iso/openwrt.img` 是你上传的 OpenWrt 镜像文件的位置，`local-lvm` 是你的存储名称，默认`local-lvm`就可以。

执行完会有这么一段输出：

```plaintext
Successfully imported disk as 'unused0:local-lvm:vm-100-disk-0'
```

然后回到 Proxmox VE 的 Web 界面上，点击 **Hardware**，找到 **Unused Disk**，点击 **Add**：

![add-unused-disk](/images/posts/install-and-setup-bypass-router-on-pve/add-unused-disk.png)

然后再回到 Proxmox VE 的 Web 界面上，点击 **Options**，找到 **Boot Order**，将 **scsi0** 打勾并移动到第一位：

![change-boot-order](/images/posts/install-and-setup-bypass-router-on-pve/change-boot-order.png)

然后我们回到 Proxmox VE 的 Web 界面上，点击启动虚拟机就开始安装了。

## 四、安装 OpenWrt

启动之后，你会看到 OpenWrt 的安装界面，按照提示进行安装即可，一般是直接就可以进入系统的。

IP地址是你编译时设置的IP地址，你可以通过浏览器访问旁路由的管理界面进行设置。默认的用户名是 `root`，密码是你编译时设置的密码。

由于编译时我们已经设置好了旁路由的功能，所以你可以直接使用旁路由了。

安装完成后，你需要在防火墙中关掉的lan口的 `IP动态伪装`，以保证你能在非局域网中访问旁路由下的设备：

![configure-firewall](/images/posts/install-and-setup-bypass-router-on-pve/configure-firewall.png)

## 五、使用旁路由

这里我只介绍如何在单个设备上使用旁路由，如果你想在整个局域网上使用旁路由，你需要在主路由上设置静态路由，将旁路由的流量转发到旁路由上。

下面默认主路由的IP地址是 `192.168.10.1`，旁路由的IP地址是 `192.168.10.10`。

### 1. 在手机上使用旁路由

参考下面的截图：

![bypass-router-on-phone](/images/posts/install-and-setup-bypass-router-on-pve/bypass-router-on-phone.png)

### 2. 在电脑上使用旁路由

参考下面的截图：

![bypass-router-on-computer](/images/posts/install-and-setup-bypass-router-on-pve/bypass-router-on-computer.png)

### 3. 在Ubuntu上使用旁路由

修改 `/etc/netplan/*.yaml` 的内容，参考修改为下面的网络配置：

```plaintext
network:
  ethernets:
    ens18:
      addresses:
      - 192.168.10.20/24
      nameservers:
        addresses:
        - 223.5.5.5
        search: []
      routes:
      - to: default
        via: 192.168.10.10
  version: 2
```

### 4. 在 Home Assistant 上使用旁路由

打开HA的终端，输入下面的命令：

```bash
net update eth0 --ipv4-method static
net update eth0 --ipv4-address 192.168.10.12
net update eth0 --ipv4-gateway 192.168.10.10
net update eth0 --ipv4-nameservers 223.5.5.5

net update eth0 --ipv6-method disabled
```

### 5. 在TrueNAS上使用旁路由

进入 TrueNAS 的 Web 界面，点击 **Network**，找到 **Global Configuration**，修改为下面的内容：

![truenas-global-configuration](/images/posts/install-and-setup-bypass-router-on-pve/truenas-global-configuration.png)

然后进入 TrueNAS 的控制台，输入1按照提示修改网络配置。

![truenas-shell-configuration](/images/posts/install-and-setup-bypass-router-on-pve/truenas-shell-configuration.png)
