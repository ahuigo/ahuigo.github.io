---
date: 2018-08-25
title: Node 执行shell 的方法
---
# Node 执行shell 的方法
child_process 提供了很多执行shell 的包:
- exec+ util.promisify
- execSync
- spawn
- spawnSync

## process(sys)
    process.argv
    process.chdir('/')
    process.cwd()
        __dirname

## exec
    const { exec } = require('child_process');
    exec('cat *.js bad_file | wc -l', (err, stdout, stderr) => {
        if (err) {
            // node couldn't execute the command
            return;
        }

        // the *entire* stdout and stderr (buffered)
        console.log(`stdout: ${stdout}`);
        console.log(`stderr: ${stderr}`);
    });

### util promise

    const util = require('util');
    const exec = util.promisify(require('child_process').exec);

    async function ls() {
      const { stdout, stderr } = await exec('ls');
      console.log('stdout:', stdout);
      console.log('stderr:', stderr);
    }
    ls();

### execSync
    const { execSync } = require('child_process');
    // stderr is sent to stdout of parent process
    // you can set options.stdio if you want it to go elsewhere
    let stdout = execSync('ls -l').toString();
    let stdout = execSync('ls -l')+'';

## spawn(stream)

    const { spawn } = require('child_process');
    const child = spawn('ls', ['-lh', '/usr']);

    // use child.stdout.setEncoding('utf8'); if you want text chunks
    child.stdout.on('data', (chunk) => {
      // data from standard output is here as buffers
    });

    // since these are streams, you can pipe them elsewhere
    child.stderr.pipe(dest);

    child.on('close', (code) => {
      console.log(`child process exited with code ${code}`);
    });

### spawnSync
    const { spawnSync} = require('child_process');
    const child = spawnSync('ls', ['-lh', '/usr']);

    console.log('error', child.error);
    console.log('stdout ', child.stdout);
    console.log('stderr ', child.stderr);