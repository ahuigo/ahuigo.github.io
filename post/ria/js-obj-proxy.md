---
title: 用js proxy 继承别的对象
date: 2018-10-04
---
# proxy
## magic set/get的问题
参考js-obj-magic 的object set/get有两个问题：
1. 需要明确指定set/get prop 的值，不能拦截所有的prop
1. 需要一个缓存对象：`this['_'+prop]=v`，如果这样写就会死循环：`this[prop]=v`

而proxy 就可以避免这些问题

## set/get
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

get 与 in 的区别

    const handler = {
      get: function(oriobj, prop) {
        return prop in oriobj ?
          oriobj[prop] :
          37;
      }
    };

    const p = new Proxy({}, handler);
    console.log('c' in p, p.c);
    //  false, 37


### set validator
    let validator = {
      set: function(obj, prop, value) {
        if (prop === 'age') {
          if (!Number.isInteger(value)) {
            throw new TypeError('The age is not an integer');
          }
        }

        obj[prop] = value;

        // Indicate success
        return true;
      }
    };

    const person = new Proxy({}, validator);

    person.age = 100;
    console.log(person.age); // 100
    person.age = 'young';    // Throws an exception

### get

    location = new Proxy(window.location, {
        get: function(target, property) {
            if (property === 'replace') {
            return function(url) {
                console.log("Intercepted location.replace call with url:", url);
                // You can add your custom logic here
            };
            }
            return target[property];
        }
    });

## apply

    var target = function (...args) { 
        console.log(args)
        return "I am the target "+`(${args.length}) (${args})`; 
    };
    var handler = {
      apply: function (receiver, thisBinding, args) {
        console.log(receiver(...args))
        return "I am the proxy";
      }
    };

    var p = new Proxy(target, handler);
    p(1,2,3) === "I am the proxy";

### apply for function
Note: Proxy apply 可重新定义function自己, 仅代理function`instanceof Function`有效

    function f(){
        console.log('origin')
    }
    f._name="Alex"
    f._call=function(){
        console.log(this._name, ...arguments)
    }

    const fn = new Proxy(f, {
        // target是f自己
        // _this 指fn自己的thisBinding
        apply: (target, _thisBinding, args) => target._call(_thisBinding,...args)
    })
    fn.call({x:'this'},1,2,3)

## constructor
This example uses the construct and apply handlers.

    function extend(sup, base) {
      var descriptor = Object.getOwnPropertyDescriptor( base.prototype, 'constructor');
      base.prototype = Object.create(sup.prototype);
      var handler = {
        construct: function(target, args) {
          var obj = Object.create(base.prototype);
          this.apply(target, obj, args);
          return obj;
        },
        apply: function(target, that, args) {
          sup.apply(that, args);
          base.apply(that, args);
        }
      };
      var proxy = new Proxy(base, handler);
      descriptor.value = proxy;
      Object.defineProperty(base.prototype, 'constructor', descriptor);
      return proxy;
    }

    var Person = function(name) {
      this.name = name;
    };

    var Boy = extend(Person, function(name, age) {
      this.age = age;
    });

    Boy.prototype.gender = 'M';

    var Peter = new Boy('Peter', 13);

    console.log(Peter.gender);  // "M"
    console.log(Peter.name);    // "Peter"
    console.log(Peter.age);     // 13

## other hooks
There are traps available for all of the runtime-level meta-operations:

    var handler =
    {
      // target.prop
      get: ...,
      // target.prop = value
      set: ...,
      // 'prop' in target
      has: ...,
      // delete target.prop
      deleteProperty: ...,
      // target(...args)
      apply: (target, thisBindings, ...args),
      // new target(...args)
      construct: ...,
      // Object.getOwnPropertyDescriptor(target, 'prop')
      getOwnPropertyDescriptor: ...,
      // Object.defineProperty(target, 'prop', descriptor)
      defineProperty: ...,
      // Object.getPrototypeOf(target), Reflect.getPrototypeOf(target),
      // target.__proto__, object.isPrototypeOf(target), object instanceof target
      getPrototypeOf: ...,
      // Object.setPrototypeOf(target), Reflect.setPrototypeOf(target)
      setPrototypeOf: ...,
      // for (let i in target) {}
      enumerate: ...,
      // Object.keys(target)
      ownKeys: ...,
      // Object.preventExtensions(target)
      preventExtensions: ...,
      // Object.isExtensible(target)
      isExtensible :...
    }

## Implement `__proto__`
> `__proto__` is deprecated in es6 and deno. 

    if(!'__proto__' in Object){
        Object.getPrototypeOf(Object).__proto__ = funtion(){
            return Object.getPrototypeOf(this)
        }
    }
