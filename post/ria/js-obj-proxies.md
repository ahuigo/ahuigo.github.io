# 用js proxies 继承别的对象
Proxies enable creation of objects with the full range of behaviors available to host objects. 
Can be used for interception, object virtualization, logging/profiling, etc

// Proxying a normal object

    var target = {};
    var handler = {
      get: function (receiver, name) {
        return `Hello, ${name}!`;
      }
    };

    var p = new Proxy(target, handler);
    p.world === "Hello, world!";

// Proxying a function object

    var target = function () { return "I am the target"; };
    var handler = {
      apply: function (receiver, ...args) {
        return "I am the proxy";
      }
    };

    var p = new Proxy(target, handler);
    p() === "I am the proxy";

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