---
title: js obj reflect
date: 2021-01-08
private: true
---
# js obj reflect
reflect 用得很少，一般自带的方法就足够了

## 反射key 属性

### 反射symbol 属性:ownKeys
    var O = {a: 1};
    Object.defineProperty(O, 'b', {value: 2});
    O[Symbol('c')] = 3;

    Reflect.ownKeys(O); // 输出：['a', 'b', Symbol(c)]
    Object.keys(O); //输出:　['a']
    Object.entries(O); //输出[['a',1]]

### has: hasProp?
    const duck = {
      name: 'Maurice',
      color: 'white',
      greeting: function() {
        console.log(`Quaaaack! My name is ${this.name}`);
      }
    }

    Reflect.has(duck, 'color'); // true


### 反射 prototype属性
    obj={
        __proto__:{f1:1},
        ['__proto__']:{f2:2},
    }
    Object.getPrototypeOf(obj) //{f1}
    Reflect.getPrototypeOf(obj) //{f1}

## 反射实例化：

    function C(a, b){
        this.c = a + b;
    }
    var instance = Reflect.construct(C, [20, 22]);
    instance.c; // 42

## set and get props
Adding a new property to the object

    duck = {}
    // duck.eyes = 'black';
    Reflect.set(duck, 'eyes', 'black');
    // duck.eyes // 'black';
    Reflect.get(duck, 'eyes');

## apply

    function f(){
        console.log(...arguments);
    }
    // f.apply(null, [1,2,3])
    Reflect.apply(f,null,[1,2,3])

