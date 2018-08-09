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

		var id = tNode.sn + h.innerText;
		tNode.href = "#"+id.encodeURIComponentUnicode();
		tNode.title = h.innerText;
        h.id = id;
        h.innerText = tNode.sn +' '+ 
            h.innerText.charAt(0).toUpperCase()+
            h.innerText.slice(1)
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
    div.onclick = function(e){
      e = e || event;
      var from = findParent('a',e.target || e.srcElement);
      if (from){
        e.preventDefault()
        var hash = decodeURI(from.hash)
        document.getElementById(hash.substr(1)).scrollIntoView()
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

function getTNode(l, toc, sn_pre){
  var node;
  if(sn_pre === undefined ) sn_pre = '';
  l = parseInt(l); 
if(l<1 || toc.l >=l ) return;
  if(toc.list === undefined){ toc['list'] =[];}

  if(toc.l===l-1){
     node = toc.list[toc.list.length]= {l:l}
     node.sn = sn_pre + toc.list.length + '.';
     return node;
  }else{
     if(toc.list.length === 0){
       toc.list[0]= {l:toc.l+1};
    }
    node = toc.list[toc.list.length-1];
    return getTNode(l, node, sn_pre + toc.list.length + '.');
  }
}
