---
title: 在 Proxmox 上安装 TrueNAS
date: 2024-01-06 17:10:30
comments: true
tags:
  - proxmox
  - truenas
description: 在 Proxmox 上安装 TrueNAS
cover: /images/posts/install-truenas-on-promox/cover.png
categories: 教程
---

TrueNAS 是一款基于 FreeBSD 的 NAS 操作系统，它的前身是 FreeNAS，后来被 iXsystems 收购，改名为 TrueNAS。TrueNAS 有两个版本，一个是免费的 Community Edition，一个是收费的 Enterprise Edition。Community Edition 的功能已经足够强大，而且免费，所以我们这里就用 Community Edition。

后来 TrueNAS 衍生出了 TrueNAS SCALE，它是基于 Linux 的，但是目前还处于 Beta 阶段，所以我们这里还是使用 TrueNAS Core。

# 一、下载镜像

首先我们需要下载 TrueNAS 的安装镜像，下载地址在这里：

- [TrueNAS Core](https://www.truenas.com/download-truenas-core)

下载完之后上传到Proxmox然后开始安装。

# 二、安装镜像

在 Proxmox 的控制台中，选择我们的服务器，然后点击 `Create VM`，创建一个新的虚拟机。

Gerneral 中，我们可以设置虚拟机的名称：

![general](/images/posts/install-truenas-on-promox/general.png)

OS 选择我们刚刚上传的镜像：

![os](/images/posts/install-truenas-on-promox/os.png)

System 中，我们选择默认即可。

Disk 中，我们可以设置虚拟机的磁盘大小，最小设置 16G：

![disk](/images/posts/install-truenas-on-promox/disk.png)

CPU 中，我们可以设置虚拟机的 CPU 核心数，最小设置 2：

![cpu](/images/posts/install-truenas-on-promox/cpu.png)

Memory 中，我们可以设置虚拟机的内存大小，最小设置 8G：

![memory](/images/posts/install-truenas-on-promox/memory.png)

Network选择默认即可。

最后点击 `Create`，创建虚拟机，注意不要勾选 `Start after created`。

![create](/images/posts/install-truenas-on-promox/create.png)

# 三、挂载硬盘

在 Proxmox 的控制台中，进入Shell，或者通过SSH进入Proxmox后台也可以。

首先我们需要找到我们硬盘的Serial编号：

```bash
lsblk -o +MODEL,SERIAL
```

比如我的硬盘是sda，它的Serial编号就是 `2023092202777`：

```bash
NAME                         MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS MODEL               SERIAL
sda                            8:0    0 953.9G  0 disk             Kingchuxing 1TB     2023092202777
nvme0n1                      259:0    0 476.9G  0 disk             QUANXING N301 512GB AC20230527A0101010
├─nvme0n1p1                  259:1    0  1007K  0 part
├─nvme0n1p2                  259:2    0     1G  0 part /boot/efi
└─nvme0n1p3                  259:3    0 475.9G  0 part
  ├─pve-swap                 252:0    0     8G  0 lvm  [SWAP]
  ├─pve-root                 252:1    0    96G  0 lvm  /
  ├─pve-data_tmeta           252:2    0   3.6G  0 lvm
  │ └─pve-data-tpool         252:4    0 348.8G  0 lvm
  │   ├─pve-data             252:5    0 348.8G  1 lvm
  │   └─pve-vm--101--disk--0 252:6    0    16G  0 lvm
  └─pve-data_tdata           252:3    0 348.8G  0 lvm
    └─pve-data-tpool         252:4    0 348.8G  0 lvm
      ├─pve-data             252:5    0 348.8G  1 lvm
      └─pve-vm--101--disk--0 252:6    0    16G  0 lvm
```

然后我们需要找到我们硬盘的id：

```bash
ls -l /dev/disk/by-id
```

比如我的硬盘是sda，它的id就是 `ata-Kingchuxing_1TB_2023092202777`：

```bash
lrwxrwxrwx 1 root root  9 Jan  6 17:10 ata-Kingchuxing_1TB_2023092202777 -> ../../sda
```

然后把硬盘挂载到对应的虚拟机上：

```bash
qm set 101 -scsi1 /dev/disk/by-id/ata-Kingchuxing_1TB_2023092202777
```

注意这里的101是虚拟机的ID，如果你的虚拟机ID不是101，需要把101改成你的虚拟机ID。

最后我们还需要手动把Serial编号添加到虚拟机的配置文件中：

```bash
vim /etc/pve/qemu-server/101.conf
```

将 `serial=2023092202777` 添加到scsi1的末尾：

```bash
scsi1: /dev/disk/by-id/ata-Kingchuxing_1TB_2023092202777,size=1000204632K,serial=2023092202777
```

> 提醒：
>
> 类似地，如果你有多个硬盘，也可以把它们都挂载到虚拟机上，只需要把上面的命令中的 `scsi1` 改成 `scsi2`、`scsi3` 等等，然后把 `serial=2023092202777` 改成对应的硬盘的Serial编号即可。

# 四、启动虚拟机

最后启动虚拟机，进入 TrueNAS 的安装界面就可以正常安装了，这里就不做介绍了，你也可以参考下面的视频进行配置。

- [TrueNAS CORE Setup Guide for Beginners](https://www.youtube.com/watch?v=Z5QXgBjYJ7M)
