---
title: Butterfly主题下添加ICP备案信息
comments: true
tags:
  - 网站备案
date: 2022-08-05 10:37:35
description: 给我的个人主页添加ICP备案信息
cover: /images/post/add-icp-certificate/cover.png
categories: 小品
---

提到 Butterfly 主题添加 ICP 备案信息，如果你用过 Butterfly 一段时间，好像它的配置文件没有提到添加备案信息。其实不然，你可以通过添加自定义网页页脚的方式添加 ICP 备案信息。

在 Butterfly 主题的配置文件中找到以下配置，然后将内容更改为你自己的备案信息就可以了：

```yml
# Footer Settings
# --------------------------------------
footer:
  owner:
    enable: true
    since: 2022
  custom_text: <a href="https://beian.miit.gov.cn/">苏ICP备2022032826号</a>
  copyright: true # Copyright of theme and framework
```
