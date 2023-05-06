---
title: console ban, dev tools detect
date: 2023-04-30
private: true
---
# console ban

## detect dev tools1
根据窗口检查，不是很准确。

    /*
        https://github.com/sindresorhus/devtools-detect
        By Sindre Sorhus
    */
    const devtools={isOpen:false,orientation:undefined,};
    const threshold=170;
    const emitEvent=(isOpen,orientation)=>{
        globalThis.dispatchEvent(new globalThis.CustomEvent('devtoolschange',{detail:{isOpen,orientation,},}));
    };
    const main=({emitEvents=true}={})=>{
        const widthThreshold=globalThis.outerWidth - globalThis.innerWidth >threshold;
        const heightThreshold = globalThis.outerHeight - globalThis.innerHeight > threshold;
        const orientation=widthThreshold?'vertical':'horizontal';
        if(!(heightThreshold && widthThreshold) && (
            (globalThis.Firebug && globalThis.Firebug.chrome && globalThis.Firebug.chrome.isInitialized)
            || widthThreshold || heightThreshold)
        ){
            if((!devtools.isOpen||devtools.orientation!==orientation) && emitEvents){
                emitEvent(true,orientation);
            }
            devtools.isOpen=true;
            devtools.orientation=orientation;
        }else{
            if(devtools.isOpen&&emitEvents){
                emitEvent(false,undefined);
            }
            devtools.isOpen=false;
            devtools.orientation=undefined;
        }
    };
    main({emitEvents:false});
    setInterval(main,500);
    export default devtools;

## console.log twice in devtool
利用dev tools 额外调用console.log （总共两次）。

    // https://github.com/fz6m/console-ban/tree/master
    var chromeBan = function(fire) {
    location.hash='f00';
      var  newError =new Error;
      Object.defineProperty(newError, "message", {
          get: function() {
            location.hash += '#fire2'// twice in dev tools
          }
      });  
      console.log(newError)  
    };
    chromeBan();
