---
layout: page
title:
category: blog
description:
---
# Preface

# clipboard
> http://stackoverflow.com/questions/400212/how-do-i-copy-to-the-clipboard-in-javascript

先选中，再执行copy

	<p>
	  <textarea class="js-copytextarea">Hello I'm some text</textarea>
	</p>
	<script>
	document.onclick = function(){
		document.querySelector('textarea').select();
		var s = document.execCommand('copy');
		console.log(s);
	}
	</script>
