---
title: 如何在电脑上安装双系统
comments: true
tags:
  - 双系统
  - Linux
  - Mint
date: 2022-07-27 10:38:55
description: 让你的电脑同时拥有Windows和Linux两个系统
cover: /images/posts/dual-boot/cover.png
categories: 笔记
---

> 注意：安装双系统是一件非常有风险的事情，如果你对整个流程不是很熟悉，建议你不要随便安装，可以先参考观看阅读大量视频文章，理解了其中原理再动手，不然很有可能连 Windows 都用不了！！！

## 一、准备硬盘和分区

### 1. 准备硬盘

我装这个双系统的时候，特地买了一块 500G 的机械硬盘，这样我就可以让 Mint 系统使用整个硬盘了。不过如果你的固态硬盘足够大的话，你也可以把你的固态硬盘重新分区，腾出 30-100G 的空间给你的 Linux 系统。甚至于你也可以把系统装在 U 盘或者其他移动硬盘上。

![HDD](/images/posts/dual-boot/hdd.png)

### 2. 分区

分区的目的是让已有的硬盘最终留出 30-100G 的`Unallocated`空间以方便安装，只有未分区的空间才可以拿来安装系统。

使用整块硬盘的分区方法很简单，只要直接将整个硬盘删除就可以了。比如我要把系统安装在 U 盘上，具体分区方法是，在 Windows 的搜索栏中搜索`Create and Format Hard Disk`这个应用然后打开。那么只要选中 E 盘符，然后右键选择`Delete-Volume`就可以了，操作完成后会显示`Unallocated`。

![Delete-Volume](/images/posts/dual-boot/delete-volume.png)

> 注意：已经使用的硬盘也可以分区，比如你本来装有 Windows 的固态硬盘，但是安装双系统有风险，不建议大家这么做。

## 二、制作系统启动盘

制作 USB 系统启动盘的目的是为了后面安装 Linux 系统用的，这个过程和树莓派烧录系统类似。

### 1. 准备系统

烧录当然少不了系统，这边我以[Linux Mint](https://linuxmint.com/)为例，你也可以选择你喜欢的 Linux 发行版。

![Linux-Mint](/images/posts/dual-boot/linux-mint.png)

### 2. 安装烧录软件

烧录系统可以使用的软件很多，推荐使用以下三个软件：

|          [Rufus](https://rufus.ie)          |    [Etcher](https://www.balena.io/etcher/)    | [Raspberry Pi Imager](https://www.raspberrypi.com/software/) |
| :-----------------------------------------: | :-------------------------------------------: | :----------------------------------------------------------: |
| ![Rufus](/images/posts/dual-boot/rufus.png) | ![Etcher](/images/posts/dual-boot/etcher.png) |    ![RPI-Imager](/images/posts/dual-boot/rpi-imager.png)     |

### 3. 烧录系统

下面就是插入一个 16GB 以上的 U 盘，然后根据你安装的烧录软件烧录你喜欢的 Linux 系统。

以树莓派 Imager 为例，一般的流程就是选择系统，选择需要烧录的硬盘，最后烧录就可以了。

![Burn-OS](/images/posts/dual-boot/burn-os.png)

这个过程我就不做详细介绍了，可以参考相应的软件文档或者相关视频。

## 三、进入 BIOS

这个步骤根据不同的电脑而定，如果你把你制作好的启动盘插入电脑重启后自动进入了安装界面，那么你可以跳过这个步骤。

如果你的电脑没有自动进入安装界面，那么你可能就要手动进入 BIOS 后选择对应的 U 盘。具体方法是电脑在刚刚启动时，按电脑上的`F1~F12`中的一个，具体是哪一个不同品牌的电脑进入 BIOS 的方法也不同，可以自行上网查找一下。

进入 BIOS 后到`Boot Override`选项，选择你烧录的 U 盘回车就可以进入安装界面了。

![Boot-Override](/images/posts/dual-boot/bootoverride.png)

## 四、安装系统

这边我以 Mint 的安装过程为例进行介绍，由于 Mint 是基于 Ubuntu 的发行版，所以安装过程和 Ubuntu 非常相似，如果你是安装 Ubuntu 的话可以参考的。

### 1. 选择语言

首先是选择语言，这边我选择英文：

![Language](/images/posts/dual-boot/language.png)

### 2. 键盘布局

然后会让你选择键盘布局，一般都是美式布局：

![Keyboard-Layout](/images/posts/dual-boot/keyboard.png)

### 3. WiFi

然后会问你是否需要连接 WiFi，非常不建议连接 WiFi，不然使用国外源的时候安装会非常慢，建议跳过：

![WiFi](/images/posts/dual-boot/wifi.png)

### 4. 多媒体解码器

然后会询问你是否安装多媒体编解码器，因为没有网络，所以不安装，你可以在后面装好系统换了源后在安装：

![Multimedia-Codecs](/images/posts/dual-boot/multidedia-codecs.png)

### 5. 安装类型

然后是安装类型，这边我们选择其他类型，也就是自定义类型：

![Install-Type](/images/posts/dual-boot/install-type.png)

### 6. 系统分区

后面重点就来了，也就是对系统进行分区。

其实目前的电脑配置和个人使用条件来说，分区不需要特别详细，不过你可以参考网上的分区方案。这里最重要还是不能把盘弄错，比如这边的`sda`就是我的机械硬盘，也就是 500G 的那个。所以我们所有的操作都要在`sda`下操作，其他已有分区不要做任何改动。

因为我们在前面已经对硬盘做了处理，让硬盘处于未分区状态下，也就是`Unallocated`，这时候会显示为`free space`。因为只有`free space`才可以用来分区，所以要分区的话就选中`sda`的`free space`后点击左下角的`+`就可以了。如果你的硬盘没有显示 free space，那么你可以选中对应的分区，点击`-`号就可以了。然后就会变成 free space 了。

> 注意：请确保点击`-`的时候分区没有重要数据，并且是在你刚刚安装的硬盘下，比我的`sda`。

这里我就直接将机械硬盘只分一个根目录，不做其他分区。大家可以参考下面图片进行分区：

![Create-Partition](/images/posts/dual-boot/create-partition.png)

### 7. Bootloader

分区结束后要选择 Bootloader 的位置，这一点也一定不能错，记得安装在我们分好的根目录下，或者对应的硬盘下面就可以了，这样即使系统安装失败或者删除系统也不会影响我们的固态硬盘。

![Bootloader-Location](/images/posts/dual-boot/bootloader-location.png)

最后点击 Install Now 直接安装就可以了，应该会弹出其他警示弹窗，选择 Continue 就好了。

### 8. 时区

下面会让你选择时区，我们就直接选择上海：

![Timezone](/images/posts/dual-boot/timezone.png)

### 9. 主机名和用户名

紧接着会让你配置一下主机名和用户名，配置完就可以安装系统了。

![User](/images/posts/dual-boot/user.png)

### 10. 完成安装重启电脑

安装完会提示你重启电脑，重启后输入你设置的用户密码就可以看见 Mint 的欢迎界面了。

![Welcome](/images/posts/dual-boot/welcome.png)

## 五、使用双系统

### 1. 修改 Grub

安装好 Linux 重启后你可能会注意到每次登录都有 10s 的登录选项等待，这样开机时间会大大延长，手动选择又会很麻烦。解决办法是修改 grub 配置文件。

首先进入 grub 的配置文件：

```bash
sudo vim /etc/default/grub
```

找到**GRUB_TIMEOUT=10**这一选项，将其改为**GRUB_TIMEOUT=0**：

![Edit-Grub](/images/posts/dual-boot/grub.png)

然后再禁止系统修改 TIMROUT。

首先进入配置文件：

```bash
sudo vim /etc/grub.d/30_os-prober
```

然后找到最后一行，注释掉**adjust_timeout**：

![Adjust-Timeout](/images/posts/dual-boot/adjust-timeout.png)

最后更新一下 gurb，重启之后就可以生效了：

```bash
sudo update-grub
```

### 2. 修改系统启动项

如果我们想要切换不同的系统，需要修改系统的启动项，进入 BIOS 找到 BOOT 将你常用的系统放在第一个就好了。

![Boot-Options](/images/posts/dual-boot/boot-options.png)

如果只是临时使用，可以进入 BIOS 后选择对应的 BootOverride 进入，这和前面进入 USB 启动盘是一样的。
