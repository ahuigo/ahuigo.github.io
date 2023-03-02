---
title: js obj reflect
date: 2021-01-08
private: true
---
# js obj reflect
## hasProp?
    const duck = {
      name: 'Maurice',
      color: 'white',
      greeting: function() {
        console.log(`Quaaaack! My name is ${this.name}`);
      }
    }

    Reflect.has(duck, 'color'); // true

## set and get
Adding a new property to the object

    Reflect.set(duck, 'eyes', 'black');
    Reflect.get(duck, 'eyes');
    duck.eyes// 'black';

## ownKeys
Returning the object's own keys

    Reflect.ownKeys(duck);
    //等价: Object.keys(duck);
    // [ "eyes","name", "color", "greeting" ]

## apply

    function f(){
        console.log(...arguments);
    }
    // f.apply(null, [1,2,3])
    Reflect.apply(f,null,[1,2,3])

