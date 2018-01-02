function imgGif(){
	var img = document.createElement('div');
	img.innerHTML = '<img src="http://ww1.sinaimg.cn/large/5fd4a962jw9e3xe7pc5meg20g4067aqn.gif" style=" left:10px;position: absolute; top: 20px; z-index: 99999;width:100%; ">';
	img.onmouseover=function(){
		this.style.display="none";
		window.setTimeout(
			function(obj){
				obj.style.display="block";
				
			},2000,this
		);
	};
	document.body.appendChild(img);
};
imgGif();
