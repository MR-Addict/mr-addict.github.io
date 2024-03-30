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

## 一、准备工作

首先你需要准备一台 Proxmox VE 服务器，如果你还没有安装 Proxmox VE，可以参考[官方文档](https://pve.proxmox.com/wiki/Installation)进行安装。

另外你需要下载一个 OpenWrt 的镜像文件，这里我已 [iStoreOS](https://www.istoreos.com) 为例，你也可以选择你喜欢的 OpenWrt 镜像。

![istoreos](/images/posts/install-and-setup-bypass-router-on-pve/istoreos.png)

下载完之后你需要解压一下镜像文件。然后我们可以将解压好的 OpenWrt 镜像上传到 Proxmox VE 服务器上，你可以使用PVE自带的ISO上传功能：

![upload-image](/images/posts/install-and-setup-bypass-router-on-pve/upload-image.png)

上传完成后，我们可以在 Proxmox VE 的 Web 界面上看到上传的镜像文件：

![uploaded-image](/images/posts/install-and-setup-bypass-router-on-pve/uploaded-image.png)

`/var/lib/vz/template/iso/istoreos-22.03.6-2024031514-x86-64-squashfs-combined.img` 就是镜像文件的位置了，这在后面导入磁盘的时候会用到。

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
qm importdisk 100 /var/lib/vz/template/iso/istoreos-22.03.6-2024031514-x86-64-squashfs-combined.img local-lvm
```

你需要将**100**修改为你创建的虚拟机的 ID，`/var/lib/vz/template/iso/istoreos-22.03.6-2024031514-x86-64-squashfs-combined.img` 是你上传的 OpenWrt 镜像文件的位置，`local-lvm` 是你的存储名称，默认`local-lvm`就可以。

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

因为我们做的是旁路由，只有一个lan口，所以启动后旁路由会自动获取上游的IP地址，你可以通过登录自己的主路由查看旁路由的IP地址。

获取到IP地址后，你可以通过浏览器访问旁路由的管理界面，进行设置。默认的用户名和密码是 `root` 和 `password`。

## 五、设置旁路由

你可以使用IStoreOS的网络向导来设置旁路由：

![setup-bypass-router](/images/posts/install-and-setup-bypass-router-on-pve/setup-bypass-router.png)

根据向导设置好旁路由后，你就可以使用旁路由了。

## 六、使用旁路由

这里我只介绍如何在单个设备上使用旁路由，如果你想在整个局域网上使用旁路由，你需要在主路由上设置静态路由，将旁路由的流量转发到旁路由上。

下面默认主路由的IP地址是 `192.168.10.1`，旁路由的IP地址是 `192.168.10.10`。

**在手机上使用旁路由**

参考下面的截图：

![bypass-router-on-phone](/images/posts/install-and-setup-bypass-router-on-pve/bypass-router-on-phone.png)

**在电脑上使用旁路由**

参考下面的截图：

![bypass-router-on-computer](/images/posts/install-and-setup-bypass-router-on-pve/bypass-router-on-computer.png)

**在Ubuntu上使用旁路由**

参考下面的网络配置：

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
