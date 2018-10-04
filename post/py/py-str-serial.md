---
title: serialize
date: 2018-10-04
---
# serialize
- json
- pickle
- marshal
- joblib（比那个pickle好太多了，但是只能把object存到硬盘等，不能保存为字符串）
    1. from sklearn.externals import joblib

Python has a more primitive serialization module called *marshal*(support Python’s .pyc ):

*pickle* vs *marshal* module:

1. The pickle keeps track of the objects in case of *recursive objects*; These are not handled by marshal
2. pickle(support *user-defined* classes); marshal not
3. pickle is guaranteed to be  *backwards compatible* across Python releases.

# joblib

# pickle
我们把变量从内存中变成可存储或传输的过程称之为序列化，在Python中叫pickling，在其他语言中也被称之为serialization，marshalling，flattening等等，都是一个意思。
反之叫unpickling

    load, loads
    dump, dumps

pickle Functions:

    dump(object, file[,protocol])
        file: open('a.bin','wb'), StringIO, other.
        with pathlib.Path(file_path).open(mode='wb') as f:
            pickle.dump(object, f, pickle.HIGHEST_PROTOCOL)
    dumps(object) -> string
    load(file) -> object
        file: open('a.bin','rb'), StringIO, other.
        with pathlib.Path(file_path).open(mode='wb') as f:
            pickle.load(f)
    loads(string) -> object


e.g.

    import pickle
    >>> d = dict(name='Bob', age=20, score=88)
    >>> pickle.dumps(d)
    b'\x80\x03}q\x00(X\x03\x00\x00\x00ageq\x01K\x14X\x05\x00\x00\x00scoreq\x02KXX\x04\x00\x00\x00nameq\x03X\x03\x00\x00\x00Bobq\x04u.'
    
    # 写入-读入文件
    with open('dump.txt', 'wb') as f:
            pickle.dump(d, f)
            d = pickle.load(f)

## protocol
There are currently 4 different protocols which can be used for pickling.(default: 3)

1. Protocol version 0 is the original ASCII protocol
1. Protocol version 1 is the old binary format
1. Protocol version 2 more efficient pickling of new-style classes.
2. 3 provided by python 3.0
2. 4 provided by python3.4: support for very large objects
3. negative version is for select highest version

## What can be pickled and unpickled?
The following types can be pickled:

    base type: None, True, and False integers, floating point numbers, complex numbers, strings, bytes, bytearrays
    complex types: tuples, lists, sets, and dictionaries containing only picklable objects
    functions(include built-in)/classes defined at the top level of a module (using def, not lambda)
    instances of such classes whose __dict__ or the result of calling __getstate__() is picklable (dict 或者getstate 返回item必须是以上类型).

## cannot pickle class
when class instances/functions are pickled, their class’s *code and data* are not pickled along with them

    class Foo:
        attr = 'A class attribute'
    $ picklestring = pickle.dumps(Foo)
    b'\x80\x03c__main__\nFoo\nq\x00.'

## Pickling Class Instances
include `__dict__`, 不包括`__class__.__dict__`
```
class Foo:
    attr = 'ahui1111111111111111111'
    def __init__(self, name):
        self.name = name
import pickle
s= pickle.dumps(Foo('ahui'))
print(s)
o=pickle.loads(s)
print(o.name)
```
When a class instance is unpickled, only Restore code and `__dict__`, its `__init__()` method is not invoked.

### Handling Stateful Objects(with `state`)
example that shows how to modify pickling behavior for a class.

    class TextReader:
        """Print and number lines in a text file."""

        def __init__(self, filename):
            self.filename = filename
            self.file = open(filename)
            self.lineno = 0

        def readline(self):
            self.lineno += 1
            line = self.file.readline()
            if not line:
                return None
            if line.endswith('\n'):
                line = line[:-1]
            return "%i: %s" % (self.lineno, line)

        def __getstate__(self):
            # Copy the object's state from self.__dict__ which contains
            # all our instance attributes. Always use the dict.copy()
            # method to avoid modifying the original state.
            state = self.__dict__.copy()
            # Remove the unpicklable entries.
            del state['file']
            return state

        def __setstate__(self, state):
            # Restore instance attributes (i.e., filename and lineno).
            self.__dict__.update(state)
            # Restore the previously opened file's state. To do so, we need to
            # reopen it and read from it until the line count is restored.
            file = open(self.filename)
            for _ in range(self.lineno):
                file.readline()
            # Finally, save the file.
            self.file = file

A sample usage might be something like this:

    >>>
    >>> reader = TextReader("hello.txt")
    >>> reader.readline()
    '1: Hello world!'
    >>> reader.readline()
    '2: I am line number two.'
    >>> new_reader = pickle.loads(pickle.dumps(reader))
    >>> new_reader.readline()
    '3: Goodbye!'

# json

## custom json

    class MyEncoder(json.JSONEncoder):
        def default(self, obj):
            if isinstance(obj, numpy.integer):
                return int(obj)
            elif isinstance(obj, numpy.floating):
                return float(obj)
            elif isinstance(obj, numpy.ndarray):
                return obj.tolist()
            else:
                return super(MyEncoder, self).default(obj)

You use it like this:

    json.dumps(numpy.float32(1.2), cls=MyEncoder)

### json dump string
```
	str = json.dumps(data)
	print(json.loads(str))
>>> json.dumps('中')
'"\\u4e2d"'
>>> json.dumps('中', ensure_ascii=True)
'"\\u4e2d"'
>>> json.dumps('中', ensure_ascii=False)
'"中"'
```

### json dump to file
    with open('data.txt', 'w') as outfile:
        json.dump(data, outfile)
        json.load(outfile)

### json class
json dumps 类实例时，因为类实例not JSON serializable，得用default 指定序列化方法

	class Student(object):
		def __init__(self, name, age, score):
			self.name = name
			self.age = age
			self.score = score

	s = Student('Bob', 20, 88)
	>>> print(json.dumps(s, default=lambda std: { 'name': std.name, 'age': std.age, 'score': std.score }))
	{"age": 20, "name": "Bob", "score": 88}

其实实例属性都在__dict__中，所以更通用的是default:

    default=lambda obj: obj.__dict__

反序列化为class

	def dict2student(d):
		return Student(d['name'], d['age'], d['score'])

运行结果如下：

	>>> json_str = '{"age": 20, "score": 88, "name": "Bob"}'
	>>> print(json.loads(json_str, object_hook=dict2student))