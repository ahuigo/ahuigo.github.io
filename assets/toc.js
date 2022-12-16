/**
 * Create TOC of Markdown
 */
String.prototype.nthIndex = function(pat, n){
    var L= this.length, i= -1;
    while(n-- && i++<L){
        i= this.indexOf(pat, i);
        if (i < 0) break;
    }
    return i;
}

String.URIChar = {
    '<':'%3C',
    '>':'%3E',
    '"':'%22'
}
String.prototype.encodeURIComponentUnicode = function(){
    return this.replace(/./g, function(k){return String.URIChar[k] || k;}) ;
}

function getTocObj(article){
    const toc = { l: 0 };
    const hList = article.querySelectorAll('h1,h2,h3,h4,h5,h6,h7');
    for (let i = 0; i < hList.length; ++i) {
        const h = hList[i];
        const l = h.tagName.substr(1);
        const tNode = getTNode(l, toc);
        const id = tNode.refIndex + h.innerText;
        const hash = "#" + id.encodeURIComponentUnicode();
        tNode.href = hash;
        tNode.title = h.innerText;

        // title
        h.id = id;
        h.innerText = tNode.refIndex + ' ' + h.innerText;
        // link
        const link = document.createElement('a');
        link.href = hash;
        link.innerText = h.innerText;
        h.replaceChildren(link);
    }
    return toc;
}

/**
 * @param {createToc} article 
 */
export function createToc(article) {
  const tocObj = getTocObj(article),
    div = document.createElement('div');
  div.innerHTML = genToc(tocObj);
  return div;
}

/**
 * findParent
 * @param {*} tagname 
 * @param {*} el 
 */
function findParent(tagname,el){
  while (el){
    if ((el.nodeName || el.tagName).toLowerCase()===tagname.toLowerCase()){
      return el;
    }
    el = el.parentNode;
  }
  return null;
}

/**
 * 
 * @param {genToc} toc 
 */
function genToc(toc){
    var t = '';
  if(toc.href !== undefined) {
      t = '<li>' + '<a href="'+(toc.href)+'" >' + toc.title.replace(/[<>]/g, function(k){return k === '<' ? '&lt;' : '&gt;';}) + '</li>';
  }
  if(toc.list !== undefined){
    t += '<ol>';
    for(var i =0;  i<toc.list.length; ++i){
      t+= genToc(toc.list[i]);
    }
    t += '</ol>';
  }
  return t;
}

function getTNode(l, toc, refIndexPre) {
  var node;
  if (refIndexPre === undefined) refIndexPre = '';
  l = parseInt(l); 
if(l<1 || toc.l >=l ) return;
  if(toc.list === undefined){ toc['list'] =[];}

  if(toc.l===l-1){
    node = toc.list[toc.list.length] = { l: l };
    node.refIndex = refIndexPre + toc.list.length + '.';
    return node;
  }else{
    if (toc.list.length === 0) {
      toc.list[0] = { l: toc.l + 1 };
    }
    node = toc.list[toc.list.length-1];
    return getTNode(l, node, refIndexPre + toc.list.length + '.');
  }
}

export function enableTocScroll(tocEl, contentEl) {
return;
  if (window.onscroll) {
    return;
  }
  // auto overflow
  const offsetTop = tocEl.offsetTop;
  tocEl.style.overflow = 'auto';
  tocEl.style.boxSizing = 'border-box';
  tocEl.style.maxHeight = window.innerHeight + 'px';

  let isScrolTop = false;
  const scrollTocViaContent = throttle(scrollTocWithContent, 200);
  const onscroll = () => {
    console.log('onscroll1')
    if (tocEl.offsetTop - contentEl.offsetTop > 300) {
      return;
    }
    // auto position:fix
    const _isScrolTop = window.scrollY > offsetTop;
    if (isScrolTop !== _isScrolTop) {
      isScrolTop = _isScrolTop;
      tocEl.style.position = isScrolTop ? 'fixed' : ''; ``;
      tocEl.style.top = isScrolTop ? '0px' : undefined;
    }
    // sync scroll toc with content
    scrollTocViaContent(tocEl, contentEl);
  };
  window.onscroll = onscroll;
}

function isVisible(elm, mode = 'visible') {
  const rect = elm.getBoundingClientRect();
  const viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
  const res = {
    'visible': !(rect.bottom < 0 || rect.top - viewHeight >= 0),
    'below': rect.bottom > 0,
  };
  return res[mode];
}

function throttle(func, wait) {
  let previous = 0;
  return function (...args) {
    let now = Date.now();
    if (now - previous > wait) {
      func(...args);
      previous = now;
    }
  };
}


function scrollTocWithContent(tocEl, contentEl) {
  console.log('tirgger toc scroll');
  const nodes = contentEl.querySelectorAll('h1,h2,h3,h4,h5,h6');
  for (const node of nodes) {
    if (node.id && isVisible(node, 'below')) {
      // highlight toc a link
      const hash = '#' + node.id;
      const linkNodes = tocEl.querySelectorAll('a');
      for (const link of linkNodes) {
        if (link.getAttribute('href') === hash) {
          link.classList.add('selected');
          if (!isVisible(link)) {
            link.scrollIntoView();
          }
        } else {
          if (link.classList.contains('selected')) {
            link.classList.remove('selected');
          };
        }
      }
      break;
    }
  }
}
