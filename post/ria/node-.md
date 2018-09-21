# 为什么用Node
2017，我们从Node.js的版本号大飞跃谈起
http://www.techug.com/post/2017-node-js.html

# global
node 没有window, 但是有global

    global.console
    global.process === process 

# dir 文件系统
## path

    const path = require('path')
    path.resolve(__dirname, '../') 
    path.basename(__filename) 

## rm

    fs.rmdirSync(dir)
    fs.unlinkSync(file)

## dir/file/line info
    __dirname # current js file's dir
    __filename # file path

    fs.existsSync('a.csv')

__line:

        Object.defineProperty(global, '__stack', {
            get: function(){
                var orig = Error.prepareStackTrace;
                Error.prepareStackTrace = function(_, stack){ return stack; };
                var err = new Error;
                Error.captureStackTrace(err, arguments.callee);
                var stack = err.stack;
                Error.prepareStackTrace = orig;
                return stack;
            }
        });

        Object.defineProperty(global, '__line', {
            get: function(){
                return __stack[1].getLineNumber();
            }
        });

    console.log(__line);

## mkdir

    fs.mkdirSync()

### tmp
file: 

    var tmp = require('tmp');

    var tmpobj = tmp.fileSync();
        console.log('File: ', tmpobj.name);
        console.log('Filedescriptor: ', tmpobj.fd);

dir:

    var tmpobj = tmp.dirSync();
    console.log('Dir: ', tmpobj.name);

    // Manual cleanup
    tmpobj.removeCallback();//fd 

mkdtemp specify:

    fs.mkdtempSync('tmp/aa.txt')
        tmp/aa.txt7FxN


# http server

    var
        fs = require('fs'),
        url = require('url'),
        path = require('path'),
        http = require('http');

    // 从命令行参数获取root目录，默认是当前目录:
    var root = path.resolve(process.argv[2] || '.');

    console.log('Static root dir: ' + root);

    // 创建服务器:
    var server = http.createServer(function (request, response) {
        // 获得URL的path，类似 '/css/bootstrap.css':
        var pathname = url.parse(request.url).pathname;
        // 获得对应的本地文件路径，类似 '/srv/www/css/bootstrap.css':
        var filepath = path.join(root, pathname);
        // 获取文件状态:
        fs.stat(filepath, function (err, stats) {
            if (!err && stats.isFile()) {
                console.log('200 ' + request.url);
                response.writeHead(200);
                fs.createReadStream(filepath).pipe(response);
            } else {
                console.log('404 ' + request.url);
                response.writeHead(404);
                response.end('404 Not Found');
            }
        });
    });

    server.listen(8080);