const config = {
  'user': 'ahuigo', // github user acount
  'repo': 'a', //'repo': 'ahuigo.github.io',
  'weibo_uid': 1607772514,
  'twitter_user': 'ahuigoo',
  'disqus_user': 'ahuigo',
}
const ROOT = '/b'
const IMG_URI = '/a'
const $ = document.querySelector.bind(document);
const $$ = document.querySelectorAll.bind(document);
function loadComments() {
  new Valine({
    el: '#comments',
    notify: false,// # mail notifier 
    verify: false,// # Verification code
    appId: 'bmveuJdEEaT5OWICGyCMpaVc-gzGzoHsz',
    appKey: 'VhaQW20n3QnLFXnmViBld9lw',
    placeholder: 'Just go go',
    avatar: 'mm',
    meta: 'nick,mail,link'.split(','),
    pageSize: 10,
    visitor: false,
  });
}
function searchBlog(kword) {
  location.href = "https://google.com/search?q=" + encodeURIComponent(`${kword} site:${location.host}`)
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
      //this.fetchMd()
    }
  },
  mounted: function () {
    console.log('mounted: renderMd')
    this.renderMd()
    this.$nextTick(function () { })
    loadComments()
    $('#markdown').remove()
  },
  updated() {
    console.log('updated:renderMd')
    this.renderMd()
  },
  methods: {
    renderMd() {
      document.querySelectorAll('pre code').forEach(function (e) {
        return hljs.highlightBlock(e, '    ');
      });
      this.$root.$$('#content a').forEach((v, k, arr) => {
        v.href = v.getAttribute('href').replace(/^\/p\//, `${ROOT}/`);
      })
      this.$root.$$('#content img').forEach((v, k, arr) => {
        if (v.getAttribute('src').startsWith('/img/')) {
          v.src = v.getAttribute('src').replace(/^\/img\//, `${IMG_URI}/img/`)
        }
        v.addEventListener('click', e => {
          this.$root.imgsrc = e.target.src;
          //$('#imgview').style.display = 'flex';
        })
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
        dateNode.style.cssText = 'text-align:center; color:#ccc; border-bottom:1px solid #007998'
        dateNode.innerHTML = 'Created: ' + this.date;
        if (this.updated) {
          dateNode.innerHTML += '; Updated: ' + this.updated
        }
        h1node.after(dateNode)
        //set title
        h1node.style.cssText += 'color: #007998; text-align:center; '
        document.title = h1node.innerText
      }
    },
    fetchMd() {
      fetch(`/${config.repo}/${MD_URL}`).then(async r => {
        if (!r.ok) {
          this.md = '# 文章不存在!'
        } else {
          let data = await r.text()
          let meta = {}
          if (data.substr(0, 4) === '---\n') {
            let pos = data.indexOf('\n---\n', 4)
            data.slice(4, pos).split('\n').forEach((line) => {
              let [k, v] = line.split(':', 2)
              meta[k] = v || ''
            });
            data = data.substr(pos + 5);
          }
          this.title = meta.title || data.split('\n', 1)[0].slice(2)
          this.date = meta.date
          this.updated = meta.updated
          //data = data.replace(/\n/g, '\t\n')
          this.md = data
        }
      })
      //
    },
    marked: function (text) {
      console.log('marked text')
      return marked(text)
    },
  },
  created() {
    console.log('before created: fetch')
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
    imgsrc: '',
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
        const ignorePath = this.config.user === 'ahuigo' ? ['ai', 'atom', 'index.md'] : [];
        let nodes = data.map(v => ({ name: v.name, path: v.path, type: v.type, show: true })).filter(
          (v) => !(ignorePath.includes(v.path.slice(this.path.length + 1)))
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