---
title: Hexo 点击加载Disqus、
date: 2018-09-24 17:02:38
tags:
---
# Hexo 点击加载disqus

## disqus

    let disqus_user = 'ahuigo';
    function disqus() {
      if (!window.DISQUS) {
        var d = document, s = d.createElement('script');
        s.src = `https://${disqus_user}.disqus.com/embed.js`;
        s.setAttribute('data-timestamp', +new Date());
        (d.head || d.body).appendChild(s);
        s.onload = function () {
          console.log('onload disqus')
          disqus_reset()
        }
      } else {
        disqus_reset()
      }
    }
    function disqus_reset() {
      if (window.DISQUS) {
        DISQUS.reset({
          reload: true,
          config: function () {
            this.page.url = window.location.href.replace('#', '#!');//为了便于识别不同的锚点
            this.page.identifier = window.location.hash.slice(1);
            this.page.title = document.title;
          }
        });
      }
    }
