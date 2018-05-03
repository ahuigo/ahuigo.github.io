//Example 浮层:

	Object.prototype.extend = function( defaults) {
		for (var i in defaults) {
			if (!this[i]) {
				this[i] = defaults[i];
			}
		}
	};
	AddFloatLayer('test', 5);
	function AddFloatLayer(txt, time) {
		var node = document.createElement("div");
		node.innerText = txt;
		node.style.extend( {
			position:'fixed',
			top: '50%',
			left: '50%',
			height:'3em',
			width:'4em',
			'text-align': 'center',
			'font-size':'3em',
			'margin': '-1.5em -2em', /*set to a negative number 1/2 of your height*/
			border: '1px solid #ccc',
			'background-color': '#f3f3f3'
		});
		document.body.appendChild(node);
		if(typeof time === 'number'){
			setTimeout(function(){
				node.parentNode.removeChild(node);
			}, time*1000);
		}
	}
