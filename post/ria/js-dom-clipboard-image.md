---
title: Js clipboard image
date: 2019-11-13
private: true
---
# Js clipboard image
```html
<canvas style="border:1px solid grey;" id="mycanvas">
<script>

window.addEventListener("paste", (e)=>{
    var items = e.clipboardData.items;
    for (var item of items) {
        if (item.type.indexOf("image") >=0){
            var blob = item.getAsFile();
            console.log(blob, URL.createObjectURL(blob));

            /**
             * load image blob
             */
            var canvas = document.getElementById("mycanvas");
            var ctx = canvas.getContext('2d');
            var img = new Image();
            img.onload = function(){
                canvas.width = this.width;
                canvas.height = this.height;
                ctx.drawImage(img, 0, 0);
            };

            img.src = URL.createObjectURL(blob);
        }
    }
}, false);


</script>
```

## zclipboard 封装
```js
class Zclipboard{
    static retrieveImageFromClipboardAsBlob(pasteEvent, callback){
        var items = pasteEvent.clipboardData.items;
        for (var item of items) {
            if (item.type.indexOf("image") >=0){
                var blob = item.getAsFile();
                this.blobAsBase64Url(blob).then(url=>callback(url,blob));
            }
        }
    }
    static blobAsBase64Url(blob){
        return new Promise((resolve, reject)=>{
            var reader = new FileReader();
            reader.readAsDataURL(blob); 
            reader.onloadend = function() {
                var base64data = reader.result;                
                resolve(base64data);
            }
        })
    }

    static handlePasteImage(callback){
        return window.addEventListener("paste", (e)=>{
            this.retrieveImageFromClipboardAsBlob(e, (url,blob)=>{
                callback(url,blob); //ele.src=url
            });
        }, false);
    }
    static removePasteListener(listener){
        window.removeEventListener('paste', listener)
    }
}

export default Zclipboard;
```