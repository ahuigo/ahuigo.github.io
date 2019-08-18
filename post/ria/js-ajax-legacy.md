---
layout: page
title: js ajax legacy
category: blog
description:
---
# js ajax legacy

## prototype
	var xhr=new XMLHttpRequest();
    xhr.onload=function(ProgressEvent){}
	xhr.open("POST","http://hilo.sinaapp.com/header.php?demo",true);//默认true 异步
	xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	xhr.setRequestHeader('Accept', 'application/json');
	xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
	xhr.send("xuehui1=1&xuehui2=2");

## listener
所有的e.target 指向xhr

        # download
		xhr.addEventListener("load", uploadProcess, false); //e is ProgressEvent
		xhr.addEventListener("loadstart", func, false);
		xhr.addEventListener("loadend", func, false);
		xhr.addEventListener("error", uploadFailed, false);
		xhr.addEventListener("abort", uploadCanceled, false);

### upload progress

        # upload
		xhr.upload.addEventListener("progress", uploadProgress, false); //e is ProgressEvent

        <progress max="100" value="0"></progress>

### download progress

    xhr.onload = function(e){
        //e is ProgressEvent
        if(e.lengthComputable){
            e.loaded/e.total
        }
    }

### onreadystate

	xhr.onreadystatechange=function(e) { //e = Event
		if (xhr.readyState==4 && xhr.status==200) {
			var a=xhr.response;
            var contentType = xhr.getResponseHeader("Content-Type");
		}//redayState=!4 请求还在继续
	}

## Request
### chunk upload
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

# Response
# ResponseType:json

    url = 'https://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=http://m.weibo.cn'
	var x = new XMLHttpRequest();
	x.open('GET', url);
	x.responseType = 'json';
	x.onload = function(){
		res = x.response;
		console.log(res);//json
	}
