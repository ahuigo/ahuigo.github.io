---
title:	js dom file
---

# form
## Focus

    var isFocused = (document.activeElement === dummyEl);
    ele.focus()

## form dom
    function requestForm( method = 'post', url, data) {
        const form = document.createElement('form');
        form.method = method;
        form.action = url;

        if(data){
            for (const [key, value] of Object.entries(data)) {
                const hiddenField = document.createElement('input');
                hiddenField.type = 'hidden';
                hiddenField.name = key;
                hiddenField.value = value;
                form.appendChild(hiddenField);
            }
        }
        document.body.appendChild(form);
        form.submit();
    }

# FormData

## formData from FormNode

Via FormData and formnode:

    formobj = document.getElementById('form1')
    fd = formobj.getFormData()
    fd = new FormData(formobj);

Usage:

    new FormData (optional HTMLFormElement form)
    fd = new FormData(form);

    void append(DOMString name, File value, optional DOMString filename);
    void append(DOMString name, Blob value, optional DOMString filename);
    void append(DOMString name, DOMString value);
    fd.append('key', 'value' [,filename]);

submit form elements:

    fd = new FormData(oForm);
    for(k in obj){
    	fd.append(k, obj[k]);
    }
    //with Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryQHefs2ABc2lw02em
    // and u should not set x-www-form-urlencoded

## append file

### input file

    # cmd+click 不连续选择
    # shift+click 连续选择
    <input type="file" name="img" multiple="multiple" />

### enctype

> 上传文件时，不能用 xhr.setRequestHeader("Content-type",
> "application/x-www-form-urlencoded"); 而必须使用默认的:
> Content-Type:multipart/form-data;
> boundary=----WebKitFormBoundaryfyRdj8roosVVWIsH

    fd.append("myfile", myBlob, "filename.txt");
    fd.delete('myfile')

使用append()方法时

1. 可以通过第三个可选参数设置发送请求的头 `Content-Disposition` 指定文件名。
2. 如果不指定文件名, 将使用名字“`blob`”

## formdata operations

### loop form

    for (var pair of formData.entries()) {
        console.log(pair[0]+ ', ' + pair[1]); 
    }

    fd.append('a',1)
    fd.append('a',2)
    fd.get('a') // 只能得到一个a, 实际有多个, new FormData(formnode)其实也是多个
    fd.get('files[]') // 只能得到一个file

### object to formData

    function getFormData(object) {
        const formData = new FormData();
        Object.keys(object).forEach(key => formData.append(key, object[key]));
        return formData;
    }

## FileList
FileList object is "read-only" and has no implementation of its constructor.
不可用js构建FileList, 不过可以创建File(见后文)

### loop fileList

    var files = document.getElementById('photos').files;
    Array.from(files).forEach(file => { ... });

    // or
    for (var i = 0; i < files.length; i++) {
      var file = files[i];
      formData.append('photos[]', file, file.name);
    }

### append FileList to FormData
    function addFileList(fd: FormData, key: string, fl: FileList) {
        for (let i = 0; i < fl.length; i++) {
            const file = fl[i];
            fd.append(key, file)
        }
    }

full example via for expression

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


### file.attr

    fileInput.value; //可以判断是束有文件( 假路径)
    file = document.getElementById('fileToUpload').files[0];
    file.size bytes 数
    file.webkitRelativePath: 文件路径
    file.name: filename
    ifle.type: image/png ....

### file as string

    var fr=new FileReader(); 
    fr.onload=function(){ 
       console.log(fr.result); 
    } 
        
    fr.readAsText(this.files[0]);
    fr.readAsArrayBuffer //替代旧的readAsBinaryString
    fr.readAsDataURL

## blob

### blob as form

    // JavaScript file-like 对象
    var content = '<a id="a"><b id="b">hey!</b></a>'; // 新文件的正文...
    var blob = new Blob([content], { type: "text/xml"});
    formData.append("webmasterfile", blob);

### blob as data:url

    var blob = new Blob(['content'], { type: 'text/csv;charset=utf-8;' });
    var link = document.createElement("a");
    var url = URL.createObjectURL(blob);
    if (link.download !== undefined) { // feature detection
        link.setAttribute("href", url);
        link.setAttribute("download", 'filename.csv');
        link.style.visibility = 'hidden';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }

### blob as blob:url

比如给链接增加下载功能

    // text
    link.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));

    // blob
    var blob = new Blob(['content'], { type: 'text/csv;charset=utf-8;' });
    link.setAttribute("href", URL.createObjectURL(blob));

封装一下：

    static downloadText(filename, text) {
        var element = document.createElement('a');
        element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
        element.setAttribute('download', filename);

        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);

}

### blob as base64

    var reader = new FileReader();
    reader.readAsDataURL(blob); 
    reader.onloadend = function() {
        var base64data = reader.result;                
        console.log(base64data);
    }

### blob=file.slice

    if(navigator.appVersion.match('Chrome/'))
    	blob = file.slice(start, length);
    if(navigator.appVersion.match('Firefox/'))
    	blob = file.slice(start, start + length)

解决兼容问题：

    function blobSlice(file, start, end) {
        let blobSlice = File.prototype.mozSlice || File.prototype.webkitSlice || File.prototype.slice;
        return blobSlice.call(file, start, end);
    }

## FileReader

    var reader = new FileReader();
    reader.onload = function(e) {
        var data = e.target.result; // 'data:image/jpeg;base64,/9j/4AAQSk...'            
        $('img')[0].style.backgroundImage = 'url(' + data + ')';
    };
    reader.onloadend = function(e) {
        console.log(reader.result); // onload 只适合小blob
    }
    // 以DataURL的形式读取文件:
    reader.readAsDataURL(file);
    reader.readAsText(file); // 每次read 都要重新绑定onload

file is blob, split file to small blob

    function blobSlice(file, start, end) {
        var blobSlice = File.prototype.mozSlice || File.prototype.webkitSlice || File.prototype.slice;
        return blobSlice.call(file, start, end);
    }
    blob = blobSlice(file, start, end)
    fileReader.readAsBinaryString(blob_or_file);

# Blob

    blob = new Blob(['str'], {type : 'application/json'});
    blob.slice(start, end)

## blob2file

    function blob2file(blobData) {
        const fd = new FormData();
        fd.set('a', blobData);
        return fd.get('a');//name:blob, type:''
    }

# File

File 是继承blob的

## 生成临时file

    file = new File(['str'],'a.png', {type : 'image/png'});
    file = new File(['str'], 'a.txt' );
    file = new File([myBlob], "name");

或

    var parts = [
        new Blob(['myblob'], {type: 'text/plain'}),
        'string',
        new Uint16Array([33])
    ];
    var file = new File(parts, 'sample.txt', {
        lastModified: new Date(0), // optional - default = now
        type: "overide/mimetype" // optional - default = ''
    });

## FileReader

    reader = new FileReader()
    reader.onload = function(evt) {
        xhr.send(evt.target.result);
        console.log(reader.result) //readerAsText
        console.log(new Uint8Array(reader.result)); // readAsArrayBuffer
    };

    reader.readAsBinaryString(file);
    reader.readAsDataURL(file); //data:;base64,YQ==
    reader.readAsText(file)
    reader.readAsArrayBuffer(file)

## FileReaderSync

该接口只在workers里可用,因为在主线程里进行同步I/O操作可能会阻塞用户界面 http://jsfiddle.net/bgrins/7DjCP/

    r = new FileReaderSync().readAsDataURL(data)

# chunk upload

[js-lib/ajax/](js-lib/upload/)

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
