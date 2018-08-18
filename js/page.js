String.URIChar = {
    '<':'%3C',
    '>':'%3E',
    '"':'%22'
}
String.prototype.encodeURIComponentUnicode = function(){
    return this.replace(/./g, function(k){return String.URIChar[k] || k;}) ;
}
document.addEventListener("DOMContentLoaded", function(event) { 
	toc = {l:0};
	hList = document.querySelectorAll('h1,h2,h3,h4,h5,h6,h7');
	for(var i=0; i< hList.length; ++i){
		var h=hList[i];
		var l=h.tagName.substr(1);
		var tNode = getTNode(l, toc);

		var id = tNode.sn + h.innerText;
		tNode.href = "#"+id.encodeURIComponentUnicode();
		tNode.title = h.innerText;
		h.id = id;
		h.innerText = id;
	}
	document.querySelector('#toc').innerHTML = createToc(toc);
});

function createToc(toc){
  var t = '' ;
  if(toc.href !== undefined) {
      t = '<li>' + '<a href="'+(toc.href)+'" >' + toc.title.replace(/[<>]/g, function(k){return k === '<' ? '&lt;' : '&gt;';}) + '</li>';
  }
  if(toc.list !== undefined){
    t += '<ol>';
    for(var i =0;  i<toc.list.length; ++i){
      t+= createToc(toc.list[i]);
    }
    t += '</ol>';
  }
  return t;
}

function getTNode(l, toc, sn_pre){
  if(sn_pre === undefined ) sn_pre = '';
  l = parseInt(l); 
  if(l<1 || toc.l >=l ) return;
  if(toc.list === undefined){ toc['list'] =[];}

  if(toc.l===l-1){
     var node = toc.list[toc.list.length]= {l:l}
     node.sn = sn_pre + toc.list.length + '.';
     return node;
  }else{
     if(toc.list.length === 0){
       toc.list[0]= {l:toc.l+1};
    }
    var node = toc.list[toc.list.length-1];
    return getTNode(l, node, sn_pre + toc.list.length + '.');
  }
}
