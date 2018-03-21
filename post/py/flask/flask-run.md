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

## current app
 explicit way using the app_context() method: current_app 会根据ctx 变化而变化

    from flask import Flask, current_app

    app = Flask(__name__)
    with app.app_context():
        # within this block, current_app points to app.
        print current_app.name

## global

    from flask import g
    app = Flask(__name__)
    with app.app_context():
        g.a=1

## debug
其它常量:

    FLASK_DEBUG=1

This does the following things:

    it activates the *automatic reloader*
    it activates the debugger
    it enables the debug mode on the Flask application.

更多的话，见实际的项目

### logger
with gunicorn

    # gunicorn_error_logger = logging.getLogger('gunicorn.error')
    # app.logger.handlers.extend(gunicorn_error_logger.handlers)
    app.logger.setLevel(logging.DEBUG)

    app.logger.debug('A value for debugging')
    app.logger.warning('A warning occurred (%d apples)', 42)
    app.logger.error('An error occurred')


## request
test request

    from flask import request

    with app.test_request_context('/hello', method='POST'):
        # now you can do something with the request until the
        # end of the with block, such as basic assertions:
        assert request.path == '/hello'
        assert request.method == 'POST'

test 

    with app.request_context(environ):
        assert request.method == 'POST'

### cookie header

    username = request.cookies.get('username')
    resp = make_response(render_template(...))
    resp.set_cookie('username', 'the username')
    resp.headers['X-Something'] = 'A value'

### session
    from flask import session
    if 'username' in session: pass
    # remove the username from the session if it's there
    session.pop('username', None)
    session['username'] = request.form['username']


### upload
    from flask import request

    @app.route('/upload', methods=['GET', 'POST'])
    def upload_file():
        if request.method == 'POST':
            f = request.files['the_file']
            f.save('/var/www/uploads/uploaded_file.txt')
            f.save('/var/www/uploads/' + secure_filename(f.filename))

### redirect
    @app.route('/')
    def index():
        return redirect(url_for('login'))
        return render_template('page_not_found.html'), 404

    @app.route('/login')
    def login():
        abort(401)
        this_is_never_executed()

### 