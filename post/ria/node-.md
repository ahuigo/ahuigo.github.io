---
title: 为什么用Node
date: 2018-10-04
---
# 为什么用Node
2017，我们从Node.js的版本号大飞跃谈起
http://www.techug.com/post/2017-node-js.html

# global
node 没有window, 但是有global

    global.console
    global.process === process 

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