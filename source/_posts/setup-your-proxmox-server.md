---
title: Proxmox 配置指南
date: 2024-01-06 13:58:30
comments: true
tags:
  - proxmox
  - homelab
description: 几个简单配置，让你的 Proxmox 更好用
cover: /images/posts/setup-your-proxmox-server/cover.png
categories: 教程
---

我每次重装 Promox 系统都要重新把一些常用的配置再配置一遍，所以干脆写个教程，以后就不用再去找了，大家也可以做个借鉴。

# 一、更换国内源

Proxmox 默认的源是国外的，速度很慢，比较好的做法是换成国内的源。同时我们也可以关掉企业源，因为企业源是收费的，我们用不到。

## 1. 换成清华源

编辑 `/etc/apt/sources.list` 文件，将其替换成以下内容：

```conf
# deb http://ftp.debian.org/debian bookworm main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm main contrib non-free non-free-firmware

# deb http://ftp.debian.org/debian bookworm-updates main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian/ bookworm-updates main contrib non-free non-free-firmware

# deb http://security.debian.org bookworm-security main contrib
deb https://mirrors.tuna.tsinghua.edu.cn/debian-security bookworm-security main contrib non-free non-free-firmware

# PVE pve-no-subscription repository
deb https://mirrors.tuna.tsinghua.edu.cn/proxmox/debian/pve bookworm pve-no-subscription
```

## 2. 关闭企业源

编辑 `/etc/apt/sources.list.d/pve-enterprise.list` 文件，将其内容注释掉：

```conf
# deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```

编辑 `/etc/apt/sources.list.d/ ceph.list` 文件，将其内容注释掉：

```conf
# deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise
```

## 3. 更新源

最后别忘了更新一下源：

```sh
apt update && apt dist-upgrade
```

# 二、关闭订阅提醒

Proxmox 会在登录的时候弹出订阅提醒，我们可以通过修改 `/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js` 文件来关闭这个提醒。

在该文件中找到以下内容：

```js
if (
  res === null ||
  res === undefined ||
  !res ||
  res.data.status.toLowerCase() !== "active"
) {
  Ext.Msg.show({
    title: gettext("No valid subscription"),
    icon: Ext.Msg.WARNING,
    message: Proxmox.Utils.getNoSubKeyHtml(res.data.url),
    buttons: Ext.Msg.OK,
    callback: function (btn) {
      if (btn !== "ok") {
        return;
      }
      orig_cmd();
    },
  });
} else {
  orig_cmd();
}
```

只要我们将第一个判断条件永远不成立，这样就不会弹出提醒了，你可以直接删除判断条件或者像我一样添加一个判断条：

```js
// 直接不成立
if(false)

// 或者添加一个判断条件，这样也不会弹出提醒还保留了原来的内容
if (false && (res === null || res === undefined || !res || res.data.status.toLowerCase() !== "active"))
```

最后重启一下 Proxmox：

```sh
systemctl restart pveproxy
```

清除浏览器缓存之后重新登录，你就会发现订阅提醒不见了。
