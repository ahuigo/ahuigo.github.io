---
title: js obj reflect
date: 2021-01-08
private: true
---
# js obj reflect

    const duck = {
      name: 'Maurice',
      color: 'white',
      greeting: function() {
        console.log(`Quaaaack! My name is ${this.name}`);
      }
    }

    Reflect.has(duck, 'color'); // true

Adding a new property to the object

    Reflect.set(duck, 'eyes', 'black');
    Reflect.get(duck, 'eyes');

Returning the object's own keys

    Reflect.ownKeys(duck);
    Object.keys(duck);
    // [ "eyes","name", "color", "greeting" ]


