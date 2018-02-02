# insall
    pip install --editable .
    -e, --editable <path/url>   Install a project in editable mode (i.e. setuptools "develop mode")
                              from a local project path or a VCS url.

# run
example: flaskr.py

    from flask import Flask
    app = Flask(__name__)

    @app.cli.command('ahui')
    def initdb_command():
        print('Initialized the database.')

    @app.route('/')
    def hello_world():
        return 'Hello, World!'

run:

    $ FLASK_APP=flaskr flask ahui;  # ahui 是自定义的cli
    $ FLASK_APP=hello python -m flask run; # run 是自带的cli
    $ FLASK_APP=flaskr flask initdb; # http server
    $ FLASK_APP=flaskr flask initdb --host='0.0.0.0' --port=8001; # exteExternally Visible Server
    $ FLASK_APP=flaskr flask initdb --host=0 --port=8001; # exteExternally Visible Server
    new file:   flaskr/flaskr.db

使用示例有几种方法：
1. FLASK_APP='flaskr' 
    1. 先在当前目录下查找 import flaskr 包: \
    `app = flaskr.py/app`
    2. 如果没有找到就会找安装包\
    `python freeze|grep -i flaskr`
2. FLASK_APP='flaskr.factory:create_app()' 与第一种不同，获取到的：app变量是发生http请求时，才生成的\
    `app = __import__('flaskr.factory').create_app()`

## debug
其它常量:

    FLASK_DEBUG=1

This does the following things:

    it activates the *automatic reloader*
    it activates the debugger
    it enables the debug mode on the Flask application.

更多的话，见实际的项目