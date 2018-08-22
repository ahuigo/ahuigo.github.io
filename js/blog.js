/**
 * clock
 */
var clock = Snap(".clock");
var frame = clock.circle(32,32,30).attr({
  fill: "#ffffff",
  stroke: "#df5b4d",
  strokeWidth: 4
})
var hours = clock.rect(29, 18, 6, 22, 3).attr({fill: "#344d5a"});
var minutes = clock.rect(30, 15, 4, 25, 2).attr({fill: "#344d5a"});
var seconds = clock.path("M30.5,38.625c0,0.828,0.672,1.5,1.5,1.5s1.5-0.672,1.5-1.5c0-0.656-0.414-1.202-1-1.406V10.125c0-0.277-0.223-0.5-0.5-0.5s-0.5,0.223-0.5,0.5v27.094C30.914,37.423,30.5,37.969,30.5,38.625z M31,38.625c0-0.552,0.448-1,1-1s1,0.448,1,1s-0.448,1-1,1S31,39.177,31,38.625z").attr({
  fill: "#bb3e2c",
});
var middle = clock.circle(32,32,3).attr({
  fill: "#ffffff",
  stroke: "#bb3e2c",
  strokeWidth: 2
})

// CLOCK Timer

var updateTime = function() {
  var currentTime, data, hour, minute, second;
  currentTime = new Date();
  second = currentTime.getSeconds();
  minute = currentTime.getMinutes();
  hour = currentTime.getHours();
  hour = (hour > 12)? hour -12 : hour;
  hour = (hour == '00')? 12 : hour;
  hour = hour + minute / 60;
  hours.animate({transform: "r" + hour * 30 + "," + 32 + "," + 32}, 200, mina.elastic);
minutes.animate({transform: "r" + minute * 6 + "," + 32 + "," + 32}, 200, mina.elastic);
seconds.animate({transform: "r" + second * 6 + "," + 32 + "," + 32}, 500, mina.elastic);
}

setInterval(updateTime, 1000)

/**
 * blog.js for note-blog
 */
const $ = document.querySelector.bind(document);
const $$ = document.querySelectorAll.bind(document);
function disqus() {
  if (!window.DISQUS) {
    var d = document, s = d.createElement('script');
    s.src = `https://${config.disqus_user}.disqus.com/embed.js`;
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
        this.page.url = window.location.href.replace('#', '#!');
        this.page.identifier = window.location.hash.slice(1);
        this.page.title = document.title;
      }
    });
  }
}

Vue.component('tree-folder', {
  template: '#tree-folder',
  props: ['nodes', 'show'],
  methods: {
    openFolder(file) {
      if (!file.nodes) {
        file.show = true
        Vue.set(file, 'nodes', [{ type: 'file', name: "loading...", path: '' }]);
        this.$root.fetchFolder(file)
      } else {
        Vue.set(file, 'show', !file.show);
      }
    },
  },
});

marked.setOptions({
  gfm: true,
  breaks: true,
  sanitize: false,
  latexRender: katex.renderToString.bind(katex),
});

const mdConponent = {
  template: '#md',
  data() {
    return {
      md: '',
      title: '',
    }
  },
  props: [],
  watch: {
    '$route'(to, from) {
      console.log('watched123')
      this.fetchMd()
    }
  },
  mounted: function () {
    console.log('mounted')
    this.$nextTick(function () {
    })
  },
  updated() {
    console.log('updated')
    document.querySelectorAll('pre code').forEach(function (e) {
      return hljs.highlightBlock(e, '    ');
    });
    this.$root.$$('#content a').forEach((v, k, arr) => {
      if (v.getAttribute('href').startsWith('/p/')) {
        v.href = v.getAttribute('href').replace(/^\/p/, '#/post') + '.md'
      }
    })
    this.$root.$$('#content img').forEach((v, k, arr) => {
      if (v.getAttribute('src').startsWith('/img/')) {
        v.src = v.getAttribute('src').replace(/^\/img/, 'img')
      }
    })
    const toc = document.querySelector('#toc');
    if (toc.children.length) {
      toc.children[0].replaceWith(createToc(this.$el))
    } else {
      toc.appendChild(createToc(this.$el))
    }
    const h1nodes = $$('#content h1')

    // fix title + date
    if (h1nodes.length) {
      var h1node;
      if (h1nodes.length === 1) {
        h1node = h1nodes[0]
        for (const el of $('#content').children) {
          if (el.tagName.match(/^H\d$/)) {
            el.innerText = el.innerText.replace(/^1\./, '')
          }
        }
      } else {
        h1node = document.createElement('h1')
        h1node.innerText = this.title
        $('#content').insertBefore(h1node, h1nodes[0])
      }
      const dateNode = document.createElement('p')
      dateNode.style.cssText = 'text-align:center; color:#ccc'
      dateNode.innerHTML = this.date
      h1node.before(dateNode)
      //set title
      h1node.style.cssText += 'color: #007998; text-align:center; border-bottom:1px solid'
      document.title = h1node.innerText
    }
    disqus_reset()
  },
  methods: {
    fetchMd() {
      var path = this.$route.path
      if (path === '/') {
        path = 'post/0.md';
      }else{
        path = path.slice(1);
      }
      fetch(path).then(async r=> {
        if(!r.ok){
          this.md = '# 文章不存在!'
        }else{
          let data = await r.text()
          let title, date;
          if (data.substr(0, 4) === '---\n') {
            let pos = data.indexOf('\n---\n', 4)
            var m = data.slice(4, pos).match(/title:[ \t]*(\S.*)/);
            title = m ? m[1]:'';
            var m = data.slice(4, pos).match(/date:[ \t]*(\S.*)/);
            date = m ? m[1]:'';
            data = data.substr(pos+5);
          }
          this.title = title || data.split('\n',1)[0].slice(2)
          this.date = date? date : ''
          //data = data.replace(/\n/g, '\t\n')
          this.md = data
        }
      })
    },
    marked: function (text) {
      console.log('marked text')
      return marked(text)
    },
  },
  created() {
    console.log('before created')
    this.fetchMd()
  },
}

const router = new VueRouter({
  routes: [
    { path: '/bar', component: { template: '<div>bar</div>' } },
    { path: '/*', component: mdConponent },
  ],
  scrollBehavior(to, from, savedPosition) {
    return { x: 0, y: 0 }
  },
});

const app = new Vue({
  router,
  data: {
    nodes: [],
    path: 'post',
    show: true,
    showMenu: false,
    config: config,
  },
  methods: {
    $$: $$,
    fetchFolder(file) {
      var v = localStorage.getItem(file.path) || '{}'
      var data = JSON.parse(v)
      if (data && data.time) {
        if (new Date - data.time < 86400 * 1000) {
          console.log('from cache')
          Vue.set(file, 'nodes', data.nodes);
          return;
        }
        console.log('cache expired:', new Date - data.time)

      }
      return fetch(`https://api.github.com/repos/${this.config.user}/${this.config.repo}/contents/${file.path}`, {
      }).then(r => r.json()).then(data => {
        const ignorePath = this.config.user === 'ahuigo' ? ['ai', 'atom', '0'] : ['0'];
        let nodes = data.map(v => ({ name: v.name, path: v.path, type: v.type, show: true })).filter(
          (v) => !(
            v.type == 'dir'
            && ignorePath.includes(v.path.slice(this.path.length+1))
          )
        );
        Vue.set(file, 'nodes', nodes);
        localStorage.setItem(file.path, JSON.stringify({ time: +new Date, nodes }))
        return [null, nodes]
      }).catch(err => {
        console.log([err])
        return [err]
      })
    },
    openShare(site, o) {
      var link;
      const title = window.encodeURIComponent(document.title)
      const url = window.encodeURIComponent(location.href)
      if (site === 'twitter') {
        link = `http://twitter.com/share?text=${title}&url=${url}`;
      } else {
        link = `http://service.weibo.com/share/share.php?url=${url}&title=${title}`;
      }
      window.open(link, site + ' share', 'width=550,height=235');
      return false;
    },
  },
  created: function () {
    this.fetchFolder(this.$data)
  }
}).$mount('#app')