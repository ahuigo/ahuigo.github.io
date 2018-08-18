---
layout: default
---
<div class="post">

  <header class="post-header">
      <div>
          <div class="post-title">
              {{ page.title }} <br/>
          </div>
          <div class="post-date" >{{ page.date | date: "%b %-d, %Y" }}</div>
      </div>
  </header>
  <div id="toc"></div>
  <article class="post-content">
  {{ content }}
  </article>

</div>
<hr/>

<div id="disqus_thread"></div>
<script type="text/javascript">
    var disqus_shortname = 'ahui132';

    (function() {
        var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
        dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
        (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
    })();
</script>
<hr/>

<div class="post-page">
    <div class="post-page-left">
        <a href="{{ page.previous.url }}">{{ page.previous.title }}</a>
    </div>
    <div class="post-page-right">
        <a href="{{ page.next.url }}">{{ page.next.title }}</a>
    </div>
</div>

<script src="/js/page.js"></script>
