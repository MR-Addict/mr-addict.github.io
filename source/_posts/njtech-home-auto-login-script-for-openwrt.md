---
title: 南工大校园网路由器自动登录脚本
comments: true
date: 2024-03-23 00:02:07
description: 南京工业大学校园网路由器自动登录脚本
cover: /images/posts/njtech-home-auto-login-script-for-openwrt/cover.png
categories: 教程
tags:
  - openwrt
  - 南京工业大学
  - 自动登录
  - 脚本
---

## 一、前言

南京工业大学校园网登录需要输入账号密码，而且登录后会有一段时间的有效期，一般是 ~~**10分钟**~~（现在好像是变成**5分钟**了）。虽然你可以在后台发一些心跳包来保持登录状态，但是这样依然有可能会掉线。如果能够保持持续在线状态并且自动登录，那当然是最好的。

一开始南工的校园网是没有验证码的，脚本就很好写，不过后来加了验证码，就没那么容易了。现在又把验证码取消了，所以登录脚本相对而言就比较简单了。反正校园网就是反反复复地改来改去，说不定哪天登录验证的接口又变了。

你最好拥有一台刷了 OpenWrt 的路由器，如果没有这个教程可能不太适合你。如果这个教程对你有帮助那当然是最好的，我也就是想写点东西。

So，let's go！

## 二、抓取登录接口

我目前使用的脚本是基于下面这个登录页面的：

![login](/images/posts/njtech-home-auto-login-script-for-openwrt/login.png)

通过观察网络请求可以发现，登录使用的接口中需要知道 `运营商`，`用户名`，`密码`还有一个 `IP 地址`。这个IP地址就是运营商分配给你的IP地址，一般是动态的，所以需要动态获取。然后还有一堆其他的参数，好像都是固定的，不过我也没仔细研究。

简单来说下面这行命令就可以实现自动登录：

```sh
curl -s \
"http://10.50.255.11:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=,0,\
"$username"@"$provider"&user_password="$password"&wlan_user_ip="$address"\
&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=me60&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=7804&lang=zh"
```

其中，如果你的运营商是电信，那么 `provider` 就是 `telecom`，如果是移动，那么 `provider` 就是 `cmcc`。`username` 和 `password` 就是你的校园网账号和密码，`address` 就是你的IP地址。

## 三、编写脚本

在路由器上创建一个脚本文件，比如 `/root/projects/autologin/login.sh`，然后复制下面的内容：

```sh
#! /bin/bash

# check wifi connection
function check() {
  if curl -s baidu.com | grep -q html ;then
    echo "[WARN] WiFi already connected!"
    return 1
  elif ping -w 1 -c 1 njtech.edu.cn > /dev/null 2>&1; then
    return 0
  else
    echo "[ERROR] Cannot access Njtech-Home!"
    return 1
  fi
}

# login
function login() {
  # provider="cmcc"
  provider="telecom"
  username="username"
  password="password"
  address=$(ifstatus wan | jsonfilter -e '@["ipv4-address"][0].address')
  res=$(curl -s "http://10.50.255.11:801/eportal/portal/login?callback=dr1003&login_method=1&user_account=,0,"$username"@"$provider"&user_password="$password"&wlan_user_ip="$address"&wlan_user_ipv6=&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=me60&jsVersion=4.1.3&terminal_type=1&lang=zh-cn&v=7804&lang=zh")
  if echo $res | awk -F'[:,]' '{print $2}' | grep -q 1; then
    echo "[INFO] Login success!"
  else
    echo "[ERROR] Login failed!"
  fi
}

# entry point
if check; then
  login
fi
```

修改 `provider`，`username` 和 `password` 为你自己的信息，然后给这个脚本添加可执行权限：

```sh
chmod +x /root/projects/autologin/login.sh
```

这个脚本用的命令行工具有：

- `curl`：用来发送请求
- `grep`：用来匹配字符串
- `awk`：用来处理字符串
- `jsonfilter`：用来解析JSON

请确保你的路由器上已经安装了这些工具，如果没有，可以通过 `opkg` 安装：

```sh
opkg update
opkg install curl grep awk jsonfilter
```

## 四、开机自启和定时任务

设置开机自启的好处是，每次重启路由器后都会立即自动登录，减少等待连接的时间。而设置定时任务的目的是每隔一段时间就会自动尝试登录，保持在线状态。

### 4.1 开机自启

在路由器上创建一个启动脚本文件，比如 `/etc/init.d/autologin`，然后复制下面的内容：

```sh
#!/bin/sh /etc/rc.common

STOP=10
START=99

# commands to start application
start() {
  /root/projects/autologin/login.sh &
}

# commands to stop application
stop() {
  /root/projects/autologin/logout.sh
}

# start application after boot
boot() {
  sleep 10
  start
}
```

然后给这个脚本添加可执行权限：

```sh
chmod +x /etc/init.d/autologin
```

最后启用这个服务：

```sh
/etc/init.d/autologin enable
```

### 4.2 定时任务

在路由器上创建一个定时任务文件，比如 `/etc/crontabs/root`，然后复制下面的内容：

```sh
*/5 * * * * /root/projects/autologin/login.sh
```

这个任务的意思是每隔5分钟就会执行一次登录脚本。如果你想要修改间隔时间，可以修改 `*/5` 这个值。

最后重启路由器，然后就可以看到效果了。

## 五、总结

这里附上一个退出登录的脚本，方便大家进行测试登录的效果，如 `/root/projects/autologin/logout.sh`：

```sh
#! /bin/bash

function logout() {
  address=$(ifstatus wan | jsonfilter -e '@["ipv4-address"][0].address')
  res=$(curl -s "http://10.50.255.11:801/eportal/portal/logout?callback=dr1003&login_method=1&user_account=drcom&user_password=123&ac_logout=1&register_mode=1&wlan_user_ip="$address"&wlan_user_ipv6=&wlan_vlan_id=0&wlan_user_mac=000000000000&wlan_ac_ip=&wlan_ac_name=&jsVersion=4.1.3&v=2706&lang=zh")
  if echo $res | awk -F'[:,]' '{print $2}' | grep -q 1; then
    echo "[INFO] Logout success!"
  else
    echo "[ERROR] Logout failed!"
  fi
}

logout
```

这个脚本不需要做任何修改，直接就可以使用，不过你需要给这个脚本添加可执行权限：

```sh
chmod +x /root/projects/autologin/logout.sh
```

最后，如果你有什么问题或者建议，欢迎在评论区留言，我会尽快回复的。
