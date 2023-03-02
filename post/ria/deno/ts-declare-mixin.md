---
title: ts declare mixin
date: 2023-03-01
private: true
---
# Mixin
## Mixin classes
类不能合并，但是可以动态继承: https://www.typescriptlang.org/docs/handbook/mixins.html
refer to: ts-declare-mixin

    type Constructor = new (...args: any[]) => {};
    
    function Scale<TBase extends Constructor>(Base: TBase) {
      return class Scaling extends Base {
        _scale = 1;

        setScale(scale: number) {
          this._scale = scale;
        }
    
        get scale(): number {
          return this._scale;
        }
      };
    }

    // base class
    class Sprite {
      name = "";
      x = 0;
      y = 0; 
      constructor(name: string) {
        this.name = name;
      }
    }
    // extend class (dynamic)
    const EightBitSprite = Scale(Sprite);
    const flappySprite = new EightBitSprite("Bird");
    flappySprite.setScale(0.8);
    console.log(flappySprite.scale);

## Base class 约束, Constrained Class
上例的Constructor 还没有约束，来改造一下

    type GConstructor<T = {}> = new (...args: any[]) => T;

    // 这允许创建仅适用于受限基类的类：
    type Positionable = GConstructor<{ setPos: (x: number, y: number) => void }>;
    type Spritable = GConstructor<Sprite>;
    type Loggable = GConstructor<{ print: () => void }>;

然后你可以创建 mixin

    function Jumpable<TBase extends Positionable>(Base: TBase) {
      return class Jumpable extends Base {
        jump() {
          //  base must has setPos defined 
          this.setPos(0, 20);
        }
      };
    }

## 原型Mixin
    class Jumpable {
      jump() {}
    }
    
    class Duckable {
      duck() {}
    }
    
    // Including the base
    class Sprite {
      x = 0;
      y = 0;
    }
    
    // an interface which merges the expected mixins with the same name `Sprite`
    interface Sprite extends Jumpable, Duckable {}

    // Apply the mixins into the base class
    applyMixins(Sprite, [Jumpable, Duckable]);
    
    let player = new Sprite();
    player.jump();
    console.log(player.x, player.y);
    
    // This can live anywhere in your codebase:
    function applyMixins(derivedCtor: any, constructors: any[]) {
      constructors.forEach((baseCtor) => {
        Object.getOwnPropertyNames(baseCtor.prototype).forEach((name) => {
          Object.defineProperty(
            derivedCtor.prototype,
            name,
            Object.getOwnPropertyDescriptor(baseCtor.prototype, name) || Object.create(null)
          );
        });
      });
    }

## Static Property Mixins
> https://github.com/microsoft/TypeScript/issues/17829
> https://www.typescriptlang.org/docs/handbook/mixins.html#static-property-mixins-17829

类不能约束继承的父类

    function base<T>() {
        class Base {
            static prop: T;
        }
        return Base;
    }

    // error: T not in scope in `base<T>`
    class Gen<T> extends base<T>() {}
    class Spec extends Gen<string> {}

    <string>Spec.prop;

可以通过增加改成　function 实现父类T约束

    function base<T>() {
      class Base {
        static prop: T;
      }
      return Base;
    }
    
    function derived<T>() {
      class Derived extends base<T>() {
        static anotherProp: T;
      }
      return Derived;
    }
    
    class Spec extends derived<string>() {}
    
    Spec.prop; // string
    Spec.anotherProp; // string