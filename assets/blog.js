const $ = document.querySelector.bind(document);
const $$ = document.querySelectorAll.bind(document);
function searchBlog(kword) {
  location.href = "https://google.com/search?q=" + encodeURIComponent(`${kword} site:${location.hostname}`);
}
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



const routeUriMap = {
  '/': '/post/index.md',
  '/readme': '/README.md',
}

const mdConponent = {
  template: '#md',
  data() {
    return {
      md: '',
      title: ''
    };
  },
  props: [],
  watch: {
    $route(to, from) {
      console.log('trigger watched');
      this.fetchMd();
    }
  },
  mounted: function () {
    console.log('mounted');
    this.$nextTick(function () { });
  },
  updated() {
    console.log('updated');
    document.querySelectorAll('pre code').forEach(function (e) {
      return hljs.highlightBlock(e, '    ');
    });
    // this.$root.$$('#content a').forEach((v, k, arr) => {
    //   let match_reg = /^\/p\//;
    //   if (v.getAttribute('href').match(match_reg)) {
    //     v.href = v.getAttribute('href').replace(match_reg, '#/post/') + '.md';
    //   }
    // });
    this.$root.$$('#content img').forEach((v, k, arr) => {
      v.addEventListener('click', e => {
        this.$root.imgsrc = e.target.src;
        //$('#imgview').style.display = 'flex';
      })
      // if (v.getAttribute('src').startsWith('/img/')) {
      //   v.src = v.getAttribute('src').replace(/^\/img/, 'img');
      // }
    });
    const toc = document.querySelector('#toc');
    if (toc.children.length) {
      toc.children[0].replaceWith(createToc(this.$el));
    } else {
      toc.appendChild(createToc(this.$el));
    }
    const h1nodes = $$('#content h1');

    // fix title + date
    if (h1nodes.length) {
      var h1node;
      if (h1nodes.length === 1) {
        h1node = h1nodes[0];
        for (const el of $('#content').children) {
          if (el.tagName.match(/^H\d$/)) {
            el.innerText = el.innerText.replace(/^1\./, '');
          }
        }
      } else {
        h1node = document.createElement('h1');
        h1node.innerText = this.title;
        $('#content').insertBefore(h1node, h1nodes[0]);
      }
      const dateNode = document.createElement('p');
      dateNode.style.cssText = 'text-align:center; color:#ccc';
      dateNode.innerHTML = this.date;
      h1node.before(dateNode);
      //set title
      h1node.style.cssText +=
        'color: #007998; text-align:center; background:initial';
      document.title = h1node.innerText;
    }
    disqus_reset();
    this.evalMdScript();
  },
  methods: {
    async evalMdScript() {
      for (let script of document.querySelectorAll('#content script')) {
        if (script.src) {
          let sc = document.createElement('script');
          sc.src = script.src;
          document.body.append(sc);
        } else {
          let code = script.innerHTML;
          eval(code);
        }
      }
    },
    setHistoryPath(postpath) {
      let uri = `/p/${postpath.slice(6, -3)}`;
      history.replaceState(null, '', uri);
    },
    fetchMd() {
      let filepath = this.$route.path;
      const tmppath = routeUriMap[filepath];
      if (tmppath) {
        filepath = tmppath;
      } else if (filepath.startsWith('/p/') || filepath.startsWith('/b/')) {
        filepath = '/post' + filepath.slice(2) + '.md';
      } else {
        this.setHistoryPath(filepath);
      }

      fetch(filepath).then(async (r) => {
        if (!r.ok) {
          this.md = '# 文章不存在!';
        } else {
          let data = await r.text();
          let title, date;
          if (data.substr(0, 4) === '---\n') {
            let pos = data.indexOf('\n---\n', 4);
            var m = data.slice(4, pos).match(/title:[ \t]*(\S.*)/);
            title = m ? m[1] : '';
            var m = data.slice(4, pos).match(/date:[ \t]*(\S.*)/);
            date = m ? m[1] : '';
            data = data.substr(pos + 5);
          }
          this.title = title || data.split('\n', 1)[0].slice(2);
          this.date = date ? date : '';
          //data = data.replace(/\n/g, '\t\n')
          this.md = data;
        }
      });
    },
    marked: function (text) {
      console.log('marked text');
      return marked(text);
    }
  },
  created() {
    console.log('before created');
    this.fetchMd();
  }
};

const router = new VueRouter({
  // history: createWebHistory(),
  mode: 'history',
  routes: [
    { path: '/bar', component: { template: '<div>bar</div>' } },
    { path: '/*', component: mdConponent }
  ],
  scrollBehavior(to, from, savedPosition) {
    return { x: 0, y: 0 };
  }
});

const app = new Vue({
  router,
  data: {
    nodes: [],
    path: 'post',
    show: true,
    showMenu: false,
    config: config,
    imgsrc: "",
  },
  methods: {
    $$: $$,
    fetchFolder(vueData) {
      var v = localStorage.getItem(vueData.path) || '{}';
      var data = JSON.parse(v);
      if (data && data.time) {
        if (new Date() - data.time < 86400 * 1000) {
          console.log('from cache');
          Vue.set(vueData, 'nodes', data.nodes);
          return;
        }
        console.log('cache expired:', new Date() - data.time);
      }
      return fetch(
        `https://api.github.com/repos/${this.config.user}/${this.config.repo}/contents/${vueData.path}`,
        {}
      )
        .then((r) => r.json())
        .then((data) => {
          const hidePaths =
            this.config.user === 'ahuigo' ? ['ai', 'p', 'index.md'] : [];
          let nodes = data
            .map((v) => ({
              name: v.name,
              path: v.path,
              type: v.type,
              show: true
            }))
            .filter(
              (v) => !hidePaths.includes(v.path.slice(this.path.length + 1))
            );
          Vue.set(vueData, 'nodes', nodes);
          localStorage.setItem(
            vueData.path,
            JSON.stringify({ time: +new Date(), nodes })
          );
          return [null, nodes];
        })
        .catch((err) => {
          console.log([err, 1]);
          return [err];
        });
    },
    openShare(site, o) {
      var link;
      const title = window.encodeURIComponent(document.title);
      const url = window.encodeURIComponent(location.href);
      if (site === 'twitter') {
        link = `http://twitter.com/share?text=${title}&url=${url}`;
      } else {
        link = `http://service.weibo.com/share/share.php?url=${url}&title=${title}`;
      }
      window.open(link, site + ' share', 'width=550,height=235');
      return false;
    }
  },
  created: function () {
    this.fetchFolder(this.$data);
  }
}).$mount('#app');
