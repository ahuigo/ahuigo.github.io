# OS

    global.process === process 

## shell child process

    const execSync = require('child_process').execSync;	
    execSync(`kill ${process.ppid}`)

## env

    process.env.NODE_ENV
    process.env.SHELL

## process

    > process.argv
    > process.ppid
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

end:

    process.exit(1)

### process event
JavaScript程序是由事件驱动执行的单线程模型，Node.js也不例外。
1. 没有任何响应事件的函数可以执行时，Node.js就退出了。

Signal 信号

    process.on('SIGKILL', function(){

    })

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
