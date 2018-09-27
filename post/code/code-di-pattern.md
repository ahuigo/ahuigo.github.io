---
title: Dependency Injector(IoC)
date: 2018-09-27
---
# Dependency Injector(IoC)
依赖注入（Dependency Injection）又称控制反转（Inversion of Control）主要用来实现不同模块或类之间的解耦，可以根据需要动态地把某种依赖关系注入到对象中

> 参考: http://imweb.io/topic/5618a9d05d6f37745e8f498a

DI 分为两部分：依赖Dependency（参数）, 注入Injector(方法)。
Injector 需要为注射的方法传入合适的参数

    /**
    * Constructor DependencyInjector
    * @param {Object} - object with dependencies
    */
    var DI = function (dependency) {
        this.dependency = dependency;
    };

    // Should return new function with resolved dependencies
    DI.prototype.inject = function (func) {
        // Your code goes here
    }

## 测试代码
    var deps = {
      'dep1': function () {return 'this is dep1';},
      'dep2': function () {return 'this is dep2';},
      'dep3': function () {return 'this is dep3';},
      'dep4': function () {return 'this is dep4';}
    };

    var di = new DI(deps);

    var myFunc = di.inject(function (dep3, dep1, dep2) {
      return [dep1(), dep2(), dep3()].join(' -> ');
    });

    Test.assertEquals(myFunc(), 'this is dep1 -> this is dep2 -> this is dep3');

## Injector

    /**
     * Constructor DependencyInjector
     * @param {Object} - object with dependencies
     */
    var DI = function (dependency) {
      this.dependency = dependency;
    };

    // Should return new function with resolved dependencies
    DI.prototype.inject = function (func) {

      var deps = /^[^(]+\(([^)]+)/.exec(func.toString());

     //  构建参数绑定数组
      deps = deps ? deps[1]
        .split(/\s?,\s?/)
        .map(
            function (dep) {
                return this.dependency[dep];
            }.bind(this)
        ) : [];

      // 通过apply将依赖参数传入函数
      return function () {
        return func.apply(this, deps);
      };

    }

## python di
Python 半残废的DI

    class DI():
        def __init__(this, deps):
            this.deps = deps

        def inject(this, func):
            from functools import partial
            return partial(func, **this.deps)
            

    di = DI({'dep1':lambda: 'dep1', 'dep2':lambda: 'dep2'})
    def func(dep2, dep1):
        print(dep1(), dep2())

    di.inject(func)() # 不可以多传一个参数，比如dep3