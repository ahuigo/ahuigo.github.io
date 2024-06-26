---
title: ABC(AbstractClass)抽象基类
date: 2024-06-21
private: true
---
# ABC(AbstractClass)

## 创建ABC
> 一个具有派生自 ABCMeta 的元类的类无法被实例化，除非它全部的抽象方法和特征属性均已被重载

### ABC创建
可以通过简单地从 ABC 派生的方式创建抽象基类，这将避免时常令人混淆的元类用法，例如:

    from abc import ABC
    class MyABC(ABC):
        pass

    # 指定tuple的基类是MyABC
    MyABC.register(tuple) 
    assert issubclass(tuple, MyABC)
    assert isinstance((), MyABC)
### ABCMeta创建
ABC 的类型仍然是 ABCMeta，你也可以通过传入 metaclass 关键字并直接使用 ABCMeta 来定义抽象基类，例如:

    from abc import ABCMeta
    class MyABC(metaclass=ABCMeta):
        pass

## @abc.abstractmethod 声明抽象方法的装饰器
抽象方法是在抽象基类中定义的，但没有实现。任何继承抽象基类的子类都必须提供这个方法的实现

    from abc import ABC, abstractmethod

    class AbstractClassExample(ABC):
        @abstractmethod
        def do_something(self):
            pass

    class AnotherSubclass(AbstractClassExample):
        def do_something(self):
            super().do_something()
            print("The subclass is doing something")

    x = AnotherSubclass()
    x.do_something()