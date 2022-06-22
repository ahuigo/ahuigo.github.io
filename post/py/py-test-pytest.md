---
title: py-test
date: 2018-10-04
---
# Preface
test framework list:
- pytest   比unittest 好的一点是：可以选择测试范围 (Recommended)
- unittest 单元测试, py-unittest
    - doctest, 不太常用
- nose

function:
1. be able to continue through a test function after a failure

# mock
https://medium.com/@yeraydiazdiaz/what-the-mock-cheatsheet-mocking-in-python-6a71db997832

# pytest

## test case
```
    # content of test_sample.py
    def func(x):
        return x + 1

    def test_answer():
        assert func(3) == 5
```
assert 还支持提示信息:

    assert func(3) == 5, "expected value is 5"

## test case rule
name rule:

    file: test_*.py|*_test.py
    clsss: Test*
        method/func: test* 一般还是test_*
    directory: test*, 一般写tests

用于命令行配置: vi setup.cfg

    [tool:pytest]
    minversion = 3.0
    testpaths = tests


### class case
class rule:
1. class 不能有`__init__`
2. 测试class 的过程像是做遍历: for method in class().methods(): test(method())

example

    # content of test_class.py
    class TestClass:
        def test_one(self):
            x = "this"
            assert 'h' in x

        def test_two(self):
            x = "hello"
            assert hasattr(x, 'check')

        def setup_class(cls):
            print('setup_class init')

        def teardown_class(cls):
            print('teardown_class: end')

# run test

    py -m pytest
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

### test file

    pytest test_a.py

### verbose output
    pytest -s
    -s is equivalent to --capture=no

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

# flask test
conftest.py 通过fixture 生成需要的上下文环境

    @pytest.fixture
    def app():
        app = Flask('flask_test', root_path=os.path.dirname(__file__))
        return app


    @pytest.fixture
    def app_ctx(app):
        with app.app_context() as ctx:
            yield ctx


    @pytest.fixture
    def req_ctx(app):
        with app.test_request_context() as ctx:
            yield ctx


    @pytest.fixture
    def client(app):
        return app.test_client()

然后利用上下文：

    # file: test_reqctx.py
    def test_context_binding(app):
        @app.route('/')
        def index():
            return 'Hello %s!' % flask.request.args['name']

        with app.test_request_context('/?name=World'):
            assert index() == 'Hello World!'

其实是基于上下文app:

    from flask import Flask
    app = Flask('myapp')

    @app.route('/')
    def hi():
        return 'hi'

    with app.test_request_context('/?name=W'):
        assert hi() == 'hi lo'

