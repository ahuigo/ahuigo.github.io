---
title: js object magic function like python
date: 2023-03-09
private: true
---
# js object magic function like python
## toString

    var o = {
        toString(){return "I'm toString"}
    }

## valueOf
## get/set
### get/set method

    var o = {
        v: 0,
        get prop(){ 
            return this.v
        },
        set prop(v){
            this.v = v
        },
    }

    o.prop+=1
    o.prop+=2

观察一下属性:

    console.log(Object.getOwnPropertyDescriptor(o, "prop"))
    {
        get: [Function: get prop],
        set: [Function: set prop],
        enumerable: true,
        configurable: true
    }


### attach set/get via `__defineGetter__`(Deprecated)
    var a = {};
    a.__defineGetter__("flag", function(){
         return this._flag||false;
    });
    a.__defineSetter__("flag", function(s){
          this._flag = s;
    });
    console.log(a.flag)
    a.flag=true
    console.log(a.flag)
    console.log(Object.getOwnPropertyDescriptor(a, "flag"))

观察一下属性：

    console.log(Object.getOwnPropertyDescriptor(a, "flag"))
    {
      get: [Function (anonymous)],
      set: [Function (anonymous)],
      enumerable: true,
      configurable: true
    }

### attach set/get via `defineProperty`
    var a={}
    function attachSetGet(obj,prop, defaultValue){
        Object.defineProperty(a, prop,{
            get: function(v){
                return this['_'+prop]??defaultValue;
            },
            set: function(v){
                return this['_'+prop]=v
            },
        })
    }
    attachSetGet(a,'flag', 0)
    console.log(a.flag)
    a.flag=1
    console.log(a.flag)
    console.log(Object.getOwnPropertyDescriptor(a, "flag"))

### Attach set/get any prop(via Proxy)
    export function withDefautValue<T>(obj:Record<string|symbol, T>, defaultValue:T){
        return new Proxy(obj, {
            get: function (target, prop, receiver) {
                return target[prop]??defaultValue;
            },
            // 这里的set 可省略
            set: function (target, prop, value, receiver) {
                target[prop] = value
                return true; // 代表set 成功无异常
            },
        })
    }

    var a={} as Record<string, number>
    a = withDefautValue(a, 0)
    console.log(a.flag)
    a.flag+=10
    console.log(Object.getOwnPropertyDescriptor(a, "flag"))
    //{ value: 10, writable: true, enumerable: true, configurable: true }

