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
  <article id="content" class="post-content">
  {{ content }}
  </article>

</div>
<hr/>

<link rel="stylesheet" href="https://imsun.github.io/gitment/style/default.css">
<script src="https://imsun.github.io/gitment/dist/gitment.browser.js"></script>
<div id="disqus_thread"></div>
<script type="text/javascript">
const gitment = new Gitment({
  id: 'Your page ID', // optional
  owner: 'ahuigo',
  repo: 'ahuigo.github.io',
  oauth: {
    client_id: 'a7c0f288ec4299af29ba',
    client_secret: '7d5d52202c5a33975d7122e2506bf5abc7cfa8d4',
  },
  // ...
  // For more available options, check out the documentation below
})

gitment.render("disqus_thread")
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
