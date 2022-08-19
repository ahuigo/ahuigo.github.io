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
	var toc = {l:0};
	var hList = article.querySelectorAll('h1,h2,h3,h4,h5,h6,h7');
	for(var i=0; i< hList.length; ++i){
		var h=hList[i];
		var l=h.tagName.substr(1);
		var tNode = getTNode(l, toc);

    var id = tNode.refIndex + h.innerText;
    const hash = "#" + id.encodeURIComponentUnicode();

    tNode.href = hash;
		tNode.title = h.innerText;
    // title
    h.id = id;
    h.innerText = tNode.refIndex + ' ' +
      h.innerText.charAt(0).toUpperCase() +
      h.innerText.slice(1);
    // link
    const link = document.createElement('a');
    link.href = hash;
    link.innerText = h.innerText;
    h.replaceChildren(link);
  }
  return toc;
}

/**
 * 
 * @param {createToc} article 
 */
function createToc(article){
  var tocObj = getTocObj(article),
    div = document.createElement('div');
    div.innerHTML = genToc(tocObj);
  div.onclick = function (e) {
    return;
    const from = findParent('a', e.target);
      if (from){
        e.preventDefault()
        const hash = decodeURI(from.hash);
        document.getElementById(hash.slice(1))?.scrollIntoView()
      }

    }
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
