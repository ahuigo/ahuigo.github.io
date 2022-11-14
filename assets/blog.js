import * as toclib from './toc.js';
import styles from "/assets/main.css" assert { type: "css" };
import "https://cdnjs.cloudflare.com/ajax/libs/vue/2.7.10/vue.min.js";
import "https://cdnjs.cloudflare.com/ajax/libs/vue-router/3.6.5/vue-router.min.js";
document.adoptedStyleSheets = [...document.adoptedStyleSheets, styles];
window.$ = document.querySelector.bind(document);
window.$$ = document.querySelectorAll.bind(document);
window.searchBlog = (kword) => {
  location.href = "https://google.com/search?q=" + encodeURIComponent(`${kword} site:${location.hostname}`);
}
const Cnf = {
  postDir: 'post',
};

window.disqus = function () {
  if (!window.DISQUS) {
    var d = document, s = d.createElement('script');
    s.src = `https://${config.disqus_user}.disqus.com/embed.js`;
    // s.setAttribute('data-timestamp', +new Date());
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
        this.page.url = window.location.href.split('#')[0];
        const p = (new URL(location.href).searchParams?.get('p') || '').slice(2);
        this.page.identifier = p ? p : window.location.pathname
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
        this.$root.routeFolder(file)
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
      title: ''
    };
  },
  props: [],
  mounted: function () {
    console.log('mounted');
    this.$nextTick(function () {
      this.onclickLink()
      gotoHash();
    });
  },
  updated() {
    console.log('updated');
    document.querySelectorAll('pre code').forEach(function (e) {
      return hljs.highlightBlock(e, '    ');
    });
    this.$root.$$('#content img').forEach((v, k, arr) => {
      v.addEventListener('click', e => {
          this.$root.imgsrc = e.target.src;
      })
    });

    console.log('create toc');
    const toc = document.querySelector('#toc');
    const tocDom = toclib.createToc(this.$el);
    toc.hidden = tocDom.childElementCount == 0;
    if (tocDom.childElementCount > 0) {
      toc.replaceChildren(tocDom);
    }
    toclib.enableTocScroll(toc, this.$el)

      // parse title + date
      const h1nodes = $$('#content h1');
      if (h1nodes.length) {
          let h1node;
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
          h1node.after(dateNode);
          //set title
          h1node.style.cssText += 'text-align:center; background:initial';
          document.title = h1node.innerText;
      }
      disqus_reset();
      this.evalMdScript();
  },
  watch: {
    $route(to, from) {
      console.log("watch.$route", { to: to.query.p });
        this.fetchMd();
    }
  },
  methods: {
    fetchMd() {
      let uriPath = this.$route.query.p;
      if (!uriPath) {
        uriPath = 'f~index';
      }
      console.log({ u: this.$route, uriPath: uriPath })
      let filePromise;
      if (uriPath.startsWith('f~')) {
        const filepath = '/' + uriPath.slice(2).replaceAll('~', '/') + '.md';
        filePromise = fetch(filepath);
      } else if (uriPath.startsWith('d~')) {
        const dirpath = uriPath.slice(2).replaceAll('~', '/');
        filePromise = fetchDirectoryAsMarkdown(dirpath);
      } else {
        filePromise = new Promise(r => r(new Response(`# 404\n${uriPath} not found`)));
      }

      filePromise.then(async (r) => {
        if (!r.ok) {
          this.md = '# 此文章可能被删除了';
        } else {
          let data = await r.text();
          let title, date;
          if (data.slice(0, 4) === '---\n') {
            let pos = data.indexOf('\n---\n', 4);
            let m = data.slice(4, pos).match(/title:[ \t]*(\S.*)/);
            title = m ? m[1] : '';
            m = data.slice(4, pos).match(/date:[ \t]*(\S.*)/);
            date = m ? m[1] : '';
            data = data.slice(pos + 5);
          }
          this.title = title || data.split('\n', 1)[0].slice(2);
          this.date = date ? date : '';
          //data = data.replace(/\n/g, '\t\n')
          this.md = data;
        }
      });
    },
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
    onclickLink() {
      window.addEventListener('click', event => {
        let { target } = event;
        let i = 5;
        while (i-- > 0 && target && target.tagName !== 'A') target = target.parentNode;
        if (target?.tagName !== 'A') {
          return;
        }
        if (target.getAttribute('target')?.match(/\b_blank\b/i)) {
          return;
        }
        const url = new URL(target.href);
        if (url.host == location.host) {
          if (url.pathname.match(/\.html$/)) {
            return;
          }
          if (url.hash == location.hash) {
            event.preventDefault();
          }
          if (url.pathname.startsWith('/b/')) {
            url.search = 'p=f~post~' + url.pathname.slice(3).replaceAll('/', '~');
          }
          if (url.search != window.location.search) {
            // const path = url.searchParams.get('p') || '';
            console.log(url.search);
            this.$router.push(url.search);
          }
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

/**
node: {name: "algorithm", path: "post/algorithm", type: "dir", show: true}
node: {name: "0.go-begin.md", path: "post/go/0.go-begin.md", type: "file", show: true}
*/

const getUriByFilePath = (filepath) => {
    if (filepath.endsWith('.md')) {
      // post/go/go-begin.md -> ?p=f~post/go/go-begin
      return '?p=f~' + filepath.slice(0, -3).replaceAll('/', '~');
    } else {
      return '?p=d~' + filepath.replaceAll('/', '~');
    }
}

// e.g.: getDirectoryAsMarkdown('/a')
// e.g.: getDirectoryAsMarkdown('/post/.dir.json')
const fetchDirectoryAsMarkdown = (uri) => {
  return fetchPath(uri).then(nodes => {
    const pathSegs = uri.split('/');
        const tokens = [];
        const navPaths = [];
        pathSegs.forEach((pathSeg, i) => {
          navPaths.push(`[${pathSeg || 'All'}](?p=d~${pathSegs.slice(0, i + 1).join("~")})`);
        });
        tokens.push('# Archive\n' + navPaths.join('/'));

        for (const node of nodes) {
            const href = getUriByFilePath(node.path);
            let item = '';
            if (node.type == 'dir') {
                item = `- [${node.name}](${href})`;
            } else if (node.type == 'file') {
                item = `- [${node.name}](${href})`;
            }
            if (item) {
                tokens.push(item);
            }
        }
        const markdown = tokens.join('\n');
        return new Response(markdown);
    });
}

// @usage: fetchPath('post/db')
// @return nodes or []
const fetchPath = (path, disableCache = false) => {
    const v = localStorage.getItem(path) || '{}';
    const data = JSON.parse(v);
    if (data && data.time) {
        if (new Date() - data.time < 86400 * 1000 * 1) {
            console.log('from cache');
            return Promise.resolve(data.nodes);
        }
        console.log('cache expired:', new Date() - data.time);
    }
  let fetchPromise;
  if (window.config.use_cached_dir && !disableCache) {
    fetchPromise = fetch(`/${path}/.dir.json`, {});
  } else {
    fetchPromise = fetch(`https://api.github.com/repos/${window.config.user}/${window.config.repo}/contents/${path}`, {});
  }
  return fetchPromise.then(async (r) => {
    if (r.status === 404) {
      throw 404;
    }
    return r.json();
  }).then((data) => {
            const hidePaths =
                window.config.user === 'ahuigo' ? ['ai', 'p'] : [];
            let nodes = data
                .map((v) => ({
                    name: v.name,
                    path: v.path,
                    type: v.type,
                    show: true
                }))
                .filter(
                    (node) => !hidePaths.includes(node.path.split('/')[1])
                );
            localStorage.setItem(path, JSON.stringify({ time: +new Date(), nodes })
            );
            return nodes;
        }).catch((err) => {
          // if (err === 404 && window.config.use_cached_dir && disableCache === false) {
          //   return fetchPath(path, true);
          // }
          console.error({ err });
          throw err;
        });

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
        path: Cnf.postDir,
        show: true,
        showMenu: false,
        config: config,
        imgsrc: "",
    },
    methods: {
        $$: $$,
        async routeFolder(vueData) {
            const nodes = await fetchPath(vueData.path);
            if (nodes.length) {
                Vue.set(vueData, 'nodes', nodes);
            }
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
      this.routeFolder(this.$data);
  }
}).$mount('#app');

function gotoHash() {
  setTimeout(function () {
    const hash = decodeURI(location.hash);
    document.getElementById(hash.slice(1))?.scrollIntoView();
  }, 1000);
}
