---
title: Node File System API
---
# node 下的文件 API
默认buffer 

## watchFile, watch

    fs.watchFile('./a.js', ()=>{
        console.log('file changed')
    })
    fs.watch('.', ()=>{
        console.log('dir changed')
    })

## readFile
同步与异步

    var fs = require('fs');

    fs.readFile('sample.txt', 'utf8', (err, data)=>{});
    var data = fs.readFileSync('sample.txt', 'utf8');

    var data = fs.readFileSync('sample.txt').toString();

### read image

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

## writeFile, writeFileSync
write 不区分buffer/string: new Buffer('使用Stream写入二进制数据...\n', 'utf-8')

    var fs = require('fs');
    var data = 'Hello, Node.js';
    fs.writeFileSync('output.txt', data);
    fs.writeFile('output.txt', data, function (err) {})

## write, writeSync

    fs.writeSync(fd, buffer, offset)
    fs.writeSync(1, 'aa'); //process.stdout.fd
    fs.writeSync(1, Buffer.from('aa')); //process.stdout.fd

## appendFile appendFileSync

    fs.appendFile('message.txt', 'data to append', function (err) {
        if (err) throw err;
        console.log('Saved!');
    });
    fs.appendFileSync('message.txt', 'data to append');

to stdout stream:

    var fs = require('fs');
    var fd = fs.openSync('/tmp/tmp.js', 'r');
    var s = fs.createReadStream(null, {fd: fd});
    s.pipe(process.stdout);//stdout is stream, not fd

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

    fs.createWriteStream("append.txt", {flags:'a'});
    process.stdin/stdout
    fs.createReadStream(null, {fd: fd});
        var fd = fs.openSync('/tmp/tmp.js', 'r');

    stream.write(index + "\n");
    stream.end();

### read stream
读，data事件可能会有多次，每次传递的chunk是流的一部分数据。

    var fs = require('fs');
    // 打开一个流:
    var rs = fs.createReadStream('a.txt', 'utf-8');

sync:

    rs.read().toString()

async

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

### write stream

要以流的形式写入文件，只需要不断调用write()方法，最后以end()结束：

    var fs = require('fs');
    var ws1 = fs.createWriteStream('out.txt', 'utf-8');
    ws1.write('使用Stream写入文本数据...\n');
    ws1.write('END.');
    ws1.end('more end');

### pipe
就像可以把两个水管串成一个更长的水管一样， 比如复制文件的程序：

    var fs = require('fs');
    var rs = fs.createReadStream('sample.txt');
    var ws = fs.createWriteStream('copied.txt');
    rs.pipe(ws);
    rs.bytesRead
    //readable.pipe(writable, { end: false }); 防止readable end事件自动关闭writable

koa append: https://github.com/koajs/examples/tree/master/upload

    const file = ctx.request.files[0];
    const reader = fs.createReadStream(file.path);
    const stream = fs.createWriteStream('out.txt', {flags: 'a'});
    reader.pipe(stream);

#### await pipe

    ws.bytesWritten
    ps.bytesWritten
    var bytesRead = await new Promise(function(resolve, reject) {
        const ps = rs.pipe(ws)
        ps.once('finish', ()=>resolve(rs.bytesRead));
        ps.on('finish', ()=>resolve(ws.bytesWritten));
        ps.on('error', reject); // or something like that
    });

#### get bytesWrite

    var through = require('through2')
    var countStream = through(function(chunk, enc, next) {
      this.bytesWritten += Buffer.byteLength(chunk)
      this.push(chunk, enc)
      next()
    })

    var byteCountStream = countStream()
    const ps = localReadStream.pipe(byteCountStream).pipe(remoteWriteStream)

    remoteWriteStream.once('finish', function() {
      console.log('GC Bytes', byteCountStream.bytesWritten)
    })

# Dir 文件系统

## readdir

    fs.readdirSync('.')
    fs.readdir('.', (err, files)=>{})

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

# stdin,stdout,stderr
    stdin=process.stdin

    // console.log() == stdout.write()
    stdout=process.stdout

    // console.err() == stderr.write()
    stderr=process.stderr

## stdin

    // 异步读取用户输入
    stdin=process.stdin
    stdin.setEncoding('utf8');
    stdin.resume()
    console.log("Input sth.:")
    stdin.on('data', function(chunk) {
        console.log('start!', Buffer.from(chunk));
        # stop listen input
        process.stdin.pause();
    });
