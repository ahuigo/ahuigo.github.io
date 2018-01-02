# @classmethod
@classmethod make a class static method act like *object method*, except that the first arg is *class*

```
class Base(object):
    def __init__(self, val):
        print(44444444444)
        print(self)
        self.val = val

    @classmethod
    def make_obj(cls, val):
        print(222222222)
        print(cls)
        return cls(val+1)

class Derived(Base):
    def __init__(self, val):
        # In this super call, the second argument "self" is an object. <object Derived>
        # The result acts like an object of the Base class.
        print(33333333)
        print(self)
        super(Derived, self).__init__(val+2)

    @classmethod
    def make_obj(cls, val):
        print(111111111)
        print(cls)
        # In this super call, the second argument "cls" is a type. <class Derived>
        # The result acts like the Base class itself.
        return super(Derived, cls).make_obj(val)

d2 = Derived.make_obj(0) # make_obj=classmethod(make_obj)
print(d2.val)
```

Test output:

```
111111111
<class '__main__.Derived'>
222222222
<class '__main__.Derived'>
33333333
<__main__.Derived object at 0x10cc03dd8>
44444444444
<__main__.Derived object at 0x10cc03dd8>
3
```

    >>> b1 = Base(0)
    >>> b1.val
    0
    >>> b2 = Base.make_obj(0)
    >>> b2.val
    1
    >>> d1 = Derived(0)
    >>> d1.val
    2
    >>> d2 = Derived.make_obj(0) # Derived.__init__(Derived, 0)
    >>> d2.val
    3

