---
title: callable object
date: 2023-02-22
private: true
---
# define callable object
> Refer to: https://medium.com/@adrien.za/creating-callable-objects-in-javascript-fbf88db9904c
构造方式有很多种

## base guide
先了解几个概念: Function, constructor
### Function 构造
    > a=new Function('...args', 'return console.log(...args)')
    [Function: anonymous]
    > a(1,2,3)
    1 2 3

也可不带参数：

    window.foo=(args)=>Math.max(...args)
    const fn=new Function("return window.foo(arguments)")
    console.log(fn(1,2,3)) //3

### Class constructor
在js-func.md 我提到过constructor 默认是返回的this. 不过也可以return　别的对象

    const obj={name2:"alex",age:20}
    class A{
        constructor() {
            this.name="ahuigo"
            this.age=10
            return obj
        }
    }
    const a= new A()
    console.log(a.name, a.age, a===obj) // undefined 20 true

#### 返回基本类型, 就会返回this
如果返回基本类型：undefined, null,number,string等, 就会返回默认this

    const obj="abc"
    class A{
        constructor() {
            return obj
        }
    }
    console.log(new A()===obj) // false

#### 派生类this会被父类改变
    const obj={name2:"alex",age:20}
    class A{
      constructor() {
        this.name="ahuigo"
        this.age=10
        return obj
      }
    }
    class B extends A{
      constructor() {
        super()
        console.log(this===obj) //true
        this.name="ahuigo2"
        this.age=11
      }

    }
    const b= new B()
    console.log(b, b===obj) // { name2: "alex", age: 11, name: "ahuigo2" } true

## Via `bind`+`Function`
利用bind将this绑定到新生成的thisFunc
> f2=f1.bind(f1) 两者f1与f2不是同一个对象

    class Callable extends Function {
      constructor() {
        //1. this 指向新生成的函数thisFunc
        super('...args', 'return this._store._call(...args)')
        // Or without the spread/rest operator:
        // super('return this._store._call.apply(this._store, arguments)')

        // 2. thisFunc.person="Hank"
        this._store = this.bind(this)
        this._store.person = 'Hank'

        //3. return thisFunc with props
        return this._store
      }
      _call(arg) {
        return `parent:${this.person} ${arg || ''}`
      }
    }

    class AnotherCallable extends Callable {
      constructor() {
        super()
        this.person = 'Dean'
      }

      suffix(arg) {
        return `${this.person} ${arg || ''}`
      }

      _call(arg) {
        return `child:${this.person} ${arg || ''}`
      }
    }

    var obj1 = new AnotherCallable()
    console.log([obj1.person, obj1.suffix('suffix'), obj1('callable')])

    console.log(obj1 instanceof Function)  // true
    console.log(obj1 instanceof Callable)  // true
    console.log(obj1 instanceof AnotherCallable)  // true

## Via arguments.callee
arguments.callee 指向caller，即实例this

    class Callable extends Function {
      constructor() {
        super('return arguments.callee._call.apply(arguments.callee, arguments)')
        // we can also use the spread operator instead of apply:
        // super('return arguments.callee._call(...arguments)')
      }
    
      _call(...args) {
        console.log(this, args)
      }
    }

## Via Closure & Prototype Way
下例通过`Object.setPrototype`将props, 也就是`new.target.prototype`绑定到新的closure:
> `new.target===this.constructor` 就是子类
> 不要单独使用`console.log(new)` 这是一个关键字，会有语法错误

    class Callable extends Function {
      constructor() {
        var closure = function(...args) { return closure._call(...args) }
        // Or without the spread/rest operator:
        // var closure = function() {
        //   return closure._call.apply(closure, arguments)
        // }
        return Object.setPrototypeOf(closure, new.target.prototype)
        // return Object.setPrototypeOf(closure, <子类>.prototype)
      }
    
      _call(...args) {
        console.log(this, args)
      }
    }

> You can use `this.constructor.prototype` instead of `new.target.prototype`, 
> but then you must first call `super` to create the `this` object, which is wasteful.

## Via Proxy
利用proxy apply定义了this的函数体

    class Callable extends Function {
      constructor() {
        super()    
        console.log(this.constructor === Base)  // true
        console.log(this.constructor === new.target)  // true

        return new Proxy(this, {
            // target 指向第一个proxy参数this, 即function 实例的this
            // _this 是实际调用函数时的bindThis，没有binding就是undefined
          apply: (target, _thisBinding, args) => target._call(...args)
        })
      }
    
      _call(...args) {
        console.log('parent:', args)
      }
    }

    class Base extends Callable{
      _call(...args) {
        console.log('child:', args)
      }
    }
    new Base()(1,2,3)

Note: Proxy apply 可重新定义function自己, 参考js-obj-proxy.md

## ts support
    class AjaxFactory extends Callable{
      constructor() {
        super()
      }
      _call(url:string, init?:RequestInit) {
        return fetch(url, init)
      }
    }
    type AjaxFactoryF = AjaxFactory & AjaxFactory['_call']
    export AjaxFactory as AjaxFactoryF
    /*
    or:
    interface AjaxFactoryF extends AjaxFactory {
        (url:string, init?:RequestInit):Promise<Response>
    }
    */

    const fc=<AjaxFactoryF>(new AjaxFactory())
    fc('http://x.com').then

不确定是否可再简化一下?
https://stackoverflow.com/questions/69584444/how-to-write-a-generic-function-that-calls-a-method-of-an-object
中实现了constructor new 类型

    class STRING_TYPE {
      name(): string {
        return "one";
      }
    }
    class NUMBER_TYPE {
      name(): number {
        return 1;
      }
    }

    type AnyClass<R> = new (...args: any[]) => R

    // 约束Kclass返回类型, 并用 ReturnType<InstanceType<Klass> 推断类型
    const foo = <
      Return extends { name: () => any },
      Klass extends AnyClass<Return>,
      >(classType: Klass): ReturnType<InstanceType<Klass>['name']> =>
      new classType().name()

    foo(NUMBER_TYPE) // number
    foo(STRING_TYPE) // string

### Function 与class 合并
方法：加一个 alias 中间变量AjaxFactoryAlias ，给中间变量带上扩展的类型 AjaxFactoryF

    type AjaxFactoryF = AjaxFactory & AjaxFactory['_call']
    type AjaxArgs0 = ConstructorParameters<typeof AjaxFactory>
    const AjaxFactoryAlias = AjaxFactory as new (...args: AjaxArgs0)=>AjaxFactoryF

    export {AjaxFactoryAlias as AjaxFactory}
    // export default AjaxFactory as new ()=> AjaxFactoryF

类似的Function 与 list typeof methods 合并

    type FetchFn = typeof fetchFn
    type FetchFnExt= FetchFn & {
        get: FetchFn;
        post: FetchFn;
        delete: FetchFn;
        put: FetchFn;
        patch: FetchFn;
    }
## Via add prop to func
> Note: `func.name` 是只读属性，不可更改
> 这种方法得到的func默认this不是自己，必须`f2=f1.bind(f1)`after `add props to f1`

通过type 定义function 对象:

    type VerifyAgeFunc = {
        (age: number): boolean;
        usedBy: string;
    };

    const verifyAge = <VerifyAgeFunc>((age: number) => (age > 18 ? true : false));
    verifyAge.usedBy = "Admin"; 

通过 interface 定义function 对象:

    interface Foo {
      (): void;
      bar(): string;
    }

    let foo = <Foo>()=>{
        console.log("I'm function")
    }
    foo.bar=()=>{
        console.log("I'm method")
        return "abc"
    }
    foo()
    foo.bar()