# flask start
## flask route

    @app.route('/')
    def abc(): 
        pass

### flask route
url_for 只能用于启动时的context, 用来确定url:
1. abc 函数的访问url
2. 静态地址的访问url: 

    print(url_for('static', filename='stylex.css')) # static 是关键字
    with app.test_request_context():
        print(url_for('abc',a=1,b=2)); # /?a=1&b=2


## Response

    ```python
    @app.route('/')
    def abc(): 
        return 1; #不能返回数字型
    ```

## request
from flask import request

    request.args
    request.form post
    request.data raw 不正常的content-type
    request.files
