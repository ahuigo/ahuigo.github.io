---
layout: page
title:
category: blog
description:
---
# Preface

# ajax

## prototype
	var xhr=new XMLHttpRequest();
    xhr.onload=function(ProgressEvent){}
	xhr.open("POST","http://hilo.sinaapp.com/header.php?demo",true);//默认true 异步
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.setRequestHeader('Accept', 'application/json');
	xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	xhr.send("xuehui1=1&xuehui2=2");

Detect Ajax：

	$_SERVER['HTTP_X_REQUESTED_WITH']
	$_SERVER['HTTP_ACCEPT'] === 'application/json';

1. `Content-Type:text/plain + POST `只会传`RAW_POST_DATA` ,
2. `application/x-www-form-urlencode` 才会传`$_POST`, 
3. `enctype="multipart/form-data"` 则包括`POST+FILES`

	$GLOBALS['HTTP_RAW_POST_DATA'] or $HTTP_RAW_POST_DATA; # 这个在php7中被废弃了
    file_get_contents('php://input'); # 不是php://stdin

## debug
每次请求xhr 最好新建一下xhr. 或者销毁覆盖`xhr` 过去的变量

	var xhr = new XMLHttpRequest();
	xhr.addEventListener('load',func);//多次addEventListener 产生多个listener

## jquery

    $.getJSON('/api/products').done(function (data) {
        vm.products = data.products;
    }).fail(function (jqXHR, textStatus) {
        alert('Error: ' + jqXHR.status);
    });

# listener
所有的e.target 指向xhr

        # download
		xhr.addEventListener("load", uploadProcess, false); //e is ProgressEvent
		xhr.addEventListener("loadstart", func, false);
		xhr.addEventListener("loadend", func, false);
		xhr.addEventListener("error", uploadFailed, false);
		xhr.addEventListener("abort", uploadCanceled, false);


## upload progress

        # upload
		xhr.upload.addEventListener("progress", uploadProgress, false); //e is ProgressEvent

        <progress max="100" value="0"></progress>

## download progress

    xhr.onload = function(e){
        //e is ProgressEvent
        if(o.e.lengthComputable){
            e.loaded/e.total
        }
    }

## onreadystate

	xhr.onreadystatechange=function(e) { //e = Event
		if (xhr.readyState==4 && xhr.status==200) {
			var a=xhr.response;
            var contentType = xhr.getResponseHeader("Content-Type");
		}//redayState=!4 请求还在继续
	}

## chunk upload
demo: [js-lib/chunk/](js-lib/chunk/)
refer: http://stackoverflow.com/questions/7853467/uploading-a-file-in-chunks-using-html5

	function sendRequest() {
		var blob = document.getElementById('fileToUpload').files[0];
		const BYTES_PER_CHUNK = 2000; // 2kb chunk sizes.
		const SIZE = blob.size;
		var start = 0;
		var end = BYTES_PER_CHUNK;
		while( start < SIZE ) {
			var chunk = blob.slice(start, end);
			uploadFile(chunk);
			start = end;
			end = start + BYTES_PER_CHUNK;
		}
	}

	function uploadFile(blobFile) {
		var fd = new FormData();
		fd.append("fileToUpload", blobFile);
		fd.append("var", 'value');

		var xhr = new XMLHttpRequest();
		xhr.open("POST", "upload.php");
		xhr.send(fd);
	}

# FormData
> 上传文件时，不能用 xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
> 而必须使用默认的: Content-Type:multipart/form-data; boundary=----WebKitFormBoundaryfyRdj8roosVVWIsH

## fromnode
Via FormData and formnode:

    formobj = document.getElementById('form1')
	fd = new FormData(formobj);
    fd = formobj.getFormData()

    for (var pair of formData.entries()) {
        console.log(pair[0]+ ', ' + pair[1]); 
    }

## file
Via FormData and file:

	var files = document.getElementById('photos').files;
	var formData = new FormData();
	for (var i = 0; i < files.length; i++) {
	  var file = files[i];
	  formData.append('photos[]', file, file.name);
	}

	// HTML 文件类型input，由用户选择
	formData.append("userfile", fileInputElement.files[0]);
	formData.append("userfile", fileInputElement.files[0], name);

	// In jquery
	$.each(files, function(key, value) {
        formData.append(key, value);
    });

## blob

	// JavaScript file-like 对象
	var content = '<a id="a"><b id="b">hey!</b></a>'; // 新文件的正文...
	var blob = new Blob([content], { type: "text/xml"});
	formData.append("webmasterfile", blob);

## Add form listener:

	$('form').submit(function(event) {
        event.preventDefault();

		//ajax....uploading code
		var oReq = new XMLHttpRequest();
		oReq.open("POST", "stash.php", true);
		oReq.onload = function(oEvent) {
			if (oReq.status == 200) {... }
		};
		oReq.send(formData);
    });

> here is an demo:
http://stackoverflow.com/questions/166221/how-can-i-upload-files-asynchronously

## FormData Jquery

	$.ajax({
		url: '/admin/banlance/sendbanlance?act=addTask',
		data: fd,
		contentType: false,//这两行必须加
		processData: false,//
		method: 'POST'
	}).done(function(data){})

# Response
# ResponseType
https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=http://m.weibo.cn

	var x = new XMLHttpRequest();
	x.open('GET', searchUrl);
	x.responseType = 'json';
	x.onload = function(){
		res = x.response;
		console.log(res);//json
	}
