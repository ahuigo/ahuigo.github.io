---
title: TypeScript 装饰器
date: 2018-10-04
---
# TypeScript 装饰器

    function addAge(constructor: Function) {
        constructor.prototype.age = 18;
    }
    ​
    function method(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
        console.log(target);
        console.log(Hello.prototype);
        console.log("prop " + propertyKey);
        console.log("desc " + JSON.stringify(descriptor) + "\n\n");
    };
    ​
    function configurable(value: boolean) {
        return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
            descriptor.configurable = value;
        };
    }
    ​
    @addAge
    class Hello{
        name: string;
        age: number;
        constructor() {
            console.log('hello');
            this.name = 'yugo';
        }
        ​
        @method
        hello(){
            return 'instance method';
        }
        ​
        @method
        static shello(){
            return 'static method';
        }
        ​
        @configurable(false)
        get own_name(){
            return this.name;
        }
    }