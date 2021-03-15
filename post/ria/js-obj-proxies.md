---
title: 用js proxies 继承别的对象
date: 2018-10-04
---
# object set/get

## obj set 

    var person = {
        firstName: "John",
        lastName : "Doe",
        language : "",
        set lang(lang) {
            this.language = lang;
        }
    };

    // Set an object property using a setter:
    person.lang = "en";

## obj get

    const obj = {
        log: ['a', 'b', 'c'],
        get latest() {
            if (this.log.length === 0) {
            return undefined;
            }
            return this.log[this.log.length - 1];
        }
    };

    console.log(obj.latest);

## object define

    var o = {}
    Object.defineProperty(o, 'b', {
        get() { 
            return this._b; 
        },
        set(newValue) { 
            console.log(newValue)
            this._b = newValue; 
        },
        enumerable: true,
        configurable: true
    });

    o.b = 38
    console.log(o.b)

# proxy
## get

    const target = {
        message1: "hello",
        message2: "everyone"
    };

    const handler3 = {
    get: function (target, prop, receiver) {
        if (prop === "message2") {
            return "world";
        }
        return target[prop];
    },
    };

    const proxy3 = new Proxy(target, handler3);
    console.log(proxy3.message1); // hello
    console.log(proxy3.message2); // world

get 与 in 的区别

    const handler = {
      get: function(obj, prop) {
        return prop in obj ?
          obj[prop] :
          37;
      }
    };

    const p = new Proxy({}, handler);
    console.log('c' in p, p.c);
    //  false, 37

## set validator
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

## extend a function apply

    var target = function () { return "I am the target"; };
    var handler = {
      apply: function (receiver, ...args) {
        return "I am the proxy";
      }
    };

    var p = new Proxy(target, handler);
    p() === "I am the proxy";

## Extend constructor
This example uses the construct and apply handlers.

    function extend(sup, base) {
      var descriptor = Object.getOwnPropertyDescriptor(
        base.prototype, 'constructor'
      );
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

# todo
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
      apply: ...,
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