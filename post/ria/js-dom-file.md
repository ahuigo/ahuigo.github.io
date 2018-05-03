---
layout: page
title:	
category: blog
description: 
---
# Preface

# file and blob

    # cmd+click 不连续选择
    # shift+click 连续选择
    <input type="file" name="img" multiple="multiple" />

## file
fileInput.onchange 上传吧

    fileInput.value; //可以判断是束有文件( 假路径)
	file = document.getElementById('fileToUpload').files[0];
	file.size
		bytes
	file.name
		filename
	ifle.type
		image/png ....

## blob
blob

	if(navigator.appVersion.match('Chrome/'))
		blob = file.slice(start, length);
	if(navigator.appVersion.match('Firefox/'))
		blob = file.slice(start, start + length)

## FileReader

    var reader = new FileReader();
    reader.onload = function(e) {
        var data = e.target.result; // 'data:image/jpeg;base64,/9j/4AAQSk...'            
        $('img')[0].style.backgroundImage = 'url(' + data + ')';
    };
    // 以DataURL的形式读取文件:
    reader.readAsDataURL(file);

# chunk upload
分块(block)与分片(chunk)上传
> http://developer.qiniu.com/docs/v6/api/overview/up/chunked-upload.html

demo: 见ajax
[js-lib/ajax/](js-lib/ajax/)

## uploadFile

	function uploadFile(file, id){
		var chunk_size = 500;
		var start = 0;
		var blob;
		while(start < file.size){
			if(navigator.appVersion.match('Chrome/'))
				blob = file.slice(start, chunk_size);
			else if(navigator.appVersion.match('Firefox')){
				blob = file.slice(start, start + chunk_size);
			}
			uploadBlob(blob, id, start);
			$start += chunk_size;
		}
	}
	function uploadBlob(blob, id, start){
		var fd = new FormData;
		fd.append('file', blob);
		fd.append('id', id);
		fd.append('start', start);
		xhr.send(fd);
	}

## php

	$f = fopen($_POST['id'], 'w');
	fseek($f, $_POST['chunk']*$_POST['chunk_size']);
	$chunk = fopen($_FILES['file']['tmp_name'], 'r');
	stream_copy_to_stream($chunk, $f);

# md5
> Refer to: http://www.zhuwenlong.com/blog/52d6769f93dcae3050000003
