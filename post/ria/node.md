# global
node 没有window, 但是有global

    global.console
    global.process === process 

## process

    > process.argv
    > process.version;
    'v5.2.0'
    > process.platform;
    'darwin'
    > process.arch;
    'x64'
    > process.cwd(); //返回当前工作目录
    '/Users/michael'
    > process.chdir('/private/tmp'); // 切换当前工作目录
    undefined
    > process.cwd();
    '/private/tmp'

### process event
JavaScript程序是由事件驱动执行的单线程模型，Node.js也不例外。
1. 没有任何响应事件的函数可以执行时，Node.js就退出了。

#### nextTick
如果我们想要在下一次事件响应中执行代码，可以调用process.nextTick()：

    // process.nextTick()将在下一轮事件循环中调用:
    process.nextTick(function () {
        console.log('nextTick callback!');
    });
    console.log('nextTick was set!');

#### exit事件
    //程序即将退出时的回调函数:
    process.on('exit', function (code) {
        console.log('about to exit with code: ' + code);
    });

# fs, 文件系统

## dir

    __dirname # current js file's dir
    __filename # file path
    require('path').basename(__filename);


## readFile
同步与异步

    var fs = require('fs');

    fs.readFileSync('sample.txt', 'utf-8', callback);
    var data = fs.readFileSync('sample.txt', 'utf-8');

### txt
    var fs = require('fs');
    fs.readFile('sample.txt', 'utf-8', function (err, data) {
        if (err) {
            console.log(err);
        } else {
            console.log(data);
        }
    });

### image

    fs.readFile('sample.png', function (err, data) {
        if (err) {
            console.log(err);
        } else {
            console.log(data);
            console.log(data.length + ' bytes');
        }
    });

默认是二进制的buffer, 可以convert:

    // Buffer -> String
    var text = data.toString('utf-8');
    // String -> Buffer
    var buf = Buffer.from(text, 'utf-8');

## writeFile
write 不区分buffer/string: new Buffer('使用Stream写入二进制数据...\n', 'utf-8')

    var fs = require('fs');
    var data = 'Hello, Node.js';
    fs.writeFileSync('output.txt', data);
    fs.writeFile('output.txt', data, function (err) {})

## stat 文件信息

    fs.stat('sample.txt', function (err, stat) {
        if (!err) {
            // 是否是文件:
            console.log('isFile: ' + stat.isFile());
            // 是否是目录:
            console.log('isDirectory: ' + stat.isDirectory());
            if (stat.isFile()) {
                // 文件大小:
                console.log('size: ' + stat.size);
                // 创建时间, Date对象:
                console.log('birth time: ' + stat.birthtime);
                // 修改时间, Date对象:
                console.log('modified time: ' + stat.mtime);
            }
        }
    });

## stream
读，data事件可能会有多次，每次传递的chunk是流的一部分数据。

    var fs = require('fs');
    // 打开一个流:
    var rs = fs.createReadStream('sample.txt', 'utf-8');

    rs.on('data', function (chunk) {
        console.log('DATA:')
        console.log(chunk);
    });

    rs.on('end', function () {
        console.log('END');
    });

    rs.on('error', function (err) {
        console.log('ERROR: ' + err);
    });

要以流的形式写入文件，只需要不断调用write()方法，最后以end()结束：

    var fs = require('fs');
    var ws1 = fs.createWriteStream('output1.txt', 'utf-8');
    ws1.write('使用Stream写入文本数据...\n');
    ws1.write('END.');
    ws1.end('more end');

### pipe
就像可以把两个水管串成一个更长的水管一样， 比如复制文件的程序：

    var fs = require('fs');
    var rs = fs.createReadStream('sample.txt');
    var ws = fs.createWriteStream('copied.txt');
    rs.pipe(ws);
    //readable.pipe(writable, { end: false }); 防止readable end事件自动关闭writable


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