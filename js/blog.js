/**
 * clock
 */
var canvas = document.getElementById("canvas");
var ctx = canvas.getContext("2d");
var radius = canvas.height / 2;
ctx.translate(radius, radius);
radius = radius * 0.90
setInterval(drawClock, 1000);

function drawClock() {
  drawFace(ctx, radius);
  drawNumbers(ctx, radius);
  drawTime(ctx, radius);
}

function drawFace(ctx, radius) {
  var grad;
  ctx.beginPath();
  ctx.arc(0, 0, radius, 0, 2*Math.PI);
  ctx.fillStyle = 'white';
  ctx.fill();
  grad = ctx.createRadialGradient(0,0,radius*0.95, 0,0,radius*1.05);
  grad.addColorStop(0, '#333');
  grad.addColorStop(0.5, 'white');
  grad.addColorStop(1, '#333');
  ctx.strokeStyle = grad;
  ctx.lineWidth = radius*0.1;
  ctx.stroke();
  ctx.beginPath();
  ctx.arc(0, 0, radius*0.1, 0, 2*Math.PI);
  ctx.fillStyle = '#333';
  ctx.fill();
}

function drawNumbers(ctx, radius) {
  var ang;
  var num;
  ctx.font = radius*0.15 + "px arial";
  ctx.textBaseline="middle";
  ctx.textAlign="center";
  for(num = 1; num < 13; num++){
    ang = num * Math.PI / 6;
    ctx.rotate(ang);
    ctx.translate(0, -radius*0.85);
    ctx.rotate(-ang);
    ctx.fillText(num.toString(), 0, 0);
    ctx.rotate(ang);
    ctx.translate(0, radius*0.85);
    ctx.rotate(-ang);
  }
}

function drawTime(ctx, radius){
    var now = new Date();
    var hour = now.getHours();
    var minute = now.getMinutes();
    var second = now.getSeconds();
    //hour
    hour=hour%12;
    hour=(hour*Math.PI/6)+
    (minute*Math.PI/(6*60))+
    (second*Math.PI/(360*60));
    drawHand(ctx, hour, radius*0.5, radius*0.07);
    //minute
    minute=(minute*Math.PI/30)+(second*Math.PI/(30*60));
    drawHand(ctx, minute, radius*0.8, radius*0.07);
    // second
    second=(second*Math.PI/30);
    drawHand(ctx, second, radius*0.9, radius*0.02);
}

function drawHand(ctx, pos, length, width) {
    ctx.beginPath();
    ctx.lineWidth = width;
    ctx.lineCap = "round";
    ctx.moveTo(0,0);
    ctx.rotate(pos);
    ctx.lineTo(0, -length);
    ctx.stroke();
    ctx.rotate(-pos);
}

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
      v.href = v.getAttribute('href').replace(/^\/(p|b)\//, '#/post/') + '.md'
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
        path = 'post/index.md';
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
        const ignorePath = this.config.user === 'ahuigo' ? ['ai', 'atom', 'index.md'] : [];
        let nodes = data.map(v => ({ name: v.name, path: v.path, type: v.type, show: true })).filter(
          (v) => !( ignorePath.includes(v.path.slice(this.path.length+1)))
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