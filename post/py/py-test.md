# Preface
test framework list:
- pytest   比unittest 好的一点是：可以选择测试范围
- unittest 单元测试, py-unittest
    - doctest, 不太常用
- nose

function:
1. be able to continue through a test function after a failure

# pytest

## test case
```
    # content of test_sample.py
    def func(x):
        return x + 1

    def test_answer():
        assert func(3) == 5
```
## test case rule
name rule:

    file: test_*.py|*_test.py
    clsss: Test*
        method/func: test* 一般还是test_*
    directory: test*, 一般写tests

### class case
class rule:
1. class 不能有`__init__`
2. 测试class 的过程像是做遍历: for method in class().methods(): test(method())

    # content of test_class.py
    class TestClass:
        def test_one(self):
            x = "this"
            assert 'h' in x

        def test_two(self):
            x = "hello"
            assert hasattr(x, 'check')

## run test

    py.test               # run all tests below current dir(test_*.py|*_test.py), or *test** directory
    py.test test_mod.py   # run tests in module
    py.test somepath      # run all tests below somepath
    py.test -k stringexpr # only run tests with names that match the
                          # the "string expression", 
                          e.g. "class_pattern and [not] method_pattern " 
                          e.g. "method/func_pattern " 
                          e.g. "MyClass and not method"
                            # will select TestMyClass.test_something
                            # but not TestMyClass.test_method_simple
    py.test test_mod.py::test_func # only run tests that match the "node ID",
                       # e.g "test_mod.py::test_func" will select only test_func in test_mod.py

### output

    # log
    py.test --resultlog=filepath
    # xml
    py.test --junitxml=filepath

## help
```
py.test --version # shows where pytest was imported from
py.test --fixtures # show available builtin function arguments
py.test -h | --help # show help on command line and config file options
```