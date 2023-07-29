# Butterfly changed

## 1. Valine custom fileds

[File path](layout\includes\third-party\comments\valine.pug)

```diff
const valine = new Valine(Object.assign({
  el: '#vcomment',
  appId: '#{theme.valine.appId}',
  appKey: '#{theme.valine.appKey}',
  avatar: '#{theme.valine.avatar}',
  serverURLs: '#{theme.valine.serverURLs}',
  emojiMaps: !{emojiMaps},
  path: window.location.pathname,
-  visitor: #{theme.valine.visitor}
+  visitor: #{theme.valine.visitor},
+  placeholder: "说说你现在的想法\n昵称为必填项，需要三个字及以上哦",
+  requiredFields: ['nick'],
+  meta: ['nick','mail']
}, !{JSON.stringify(theme.valine.option)}))
```
