---
title: logger
date: 2018-10-04
---
# logger
按照简洁度比较： trace > log4js > waston

# tracer log

    # console only
    var logger = require('tracer').console();

    # dailyfile
    var logger = require('tracer').dailyfile({root:'.', maxLogFiles: 10, allLogsFileName: 'myAppName',
        transport : function(data) {
            console.log(data.output);
        },
    });

    logger.log('hello');
    logger.trace('hello', 'world');
    logger.debug('hello %s',  'world', 123);
    logger.info('hello %s %d',  'world', 123, {foo:'bar'});
    logger.warn('hello %s %d %j', 'world', 123, {foo:'bar'});
    logger.error('hello %s %d %j', 'world', 123, {foo:'bar'}, [1, 2, 3, 4], Object);

    $ node example/console.js
    2012-03-02T13:35:22.83Z <log> console.js:3 (Object.<anonymous>) hello
    2012-03-02T13:35:22.85Z <trace> console.js:4 (Object.<anonymous>) hello world
    2012-03-02T13:35:22.85Z <debug> console.js:5 (Object.<anonymous>) hello world 123
    2012-03-02T13:35:22.85Z <info> console.js:6 (Object.<anonymous>) hello world 123 { foo: 'bar' }
    2012-03-02T13:35:22.85Z <warn> console.js:7 (Object.<anonymous>) hello world 123 {"foo":"bar"}


## format

    var logger = require('tracer').console(
				{
					format : "{{timestamp}} <{{title}}> {{message}} (in {{file}}:{{line}})",
					dateformat : "HH:MM:ss.L"
				});

## Log File Transport

    var fs = require('fs');

    var logger = require('tracer').console({
        transport : function(data) {
            console.log(data.output);
            fs.appendFile('./file.log', data.rawoutput + '\n', (err) => {
                if (err) throw err;
            });
        }
    });


    var d = new Date()
    let month = (d.getMonth()+1+'').padStart(2, '0')
    let date = ('0'+d.getDate()).slice(-2)
    let filepath = `./${month}-${date}-file.log`