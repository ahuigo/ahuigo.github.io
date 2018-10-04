---
title: Agent
date: 2018-10-04
---
# Agent
http://mirror.eggjs.org/zh-cn/core/cluster-and-ipc.html

agent 单进程:
1. 多个worker 写同一份日志容易冲突
2. 只想一个进程处理

app.js 的代码会执行在 Worker 进程上，他们通过框架封装的 messenger 对象进行进程间通讯（IPC）

    // agent.js
    module.exports = agent => {
      // 也可以通过 messenger 对象发送消息给 App Worker
      // 但需要等待 App Worker 启动成功后才能发送，不然很可能丢失
      agent.messenger.on('egg-ready', () => {
        const data = { ... };
        agent.messenger.sendToApp('xxx_action', data);
      });
    };

    // app.js
    module.exports = app => {
      app.messenger.on('xxx_action', data => {
        // ...
      });
    };

## worker vs agent
1. Worker 进程负责用户请求和定时任务的处理。 而 Egg 的定时任务也提供了只让一个 Worker 进程运行的能力，
2. 能够通过定时任务解决的问题不要放到 Agent 上执行。

## IPC
    广播消息： agent => all workers
                      +--------+          +-------+
                      | Master |<---------| Agent |
                      +--------+          +-------+
                     /    |     \
                    /     |      \
                   /      |       \
                  /       |        \
                 v        v         v
      +----------+   +----------+   +----------+
      | Worker 1 |   | Worker 2 |   | Worker 3 |
      +----------+   +----------+   +----------+

    指定接收方： one worker => another worker
                      +--------+          +-------+
                      | Master |----------| Agent |
                      +--------+          +-------+
                     ^    |
         send to    /     |
        worker 2   /      |
                  /       |
                 /        v
      +----------+   +----------+   +----------+
      | Worker 1 |   | Worker 2 |   | Worker 3 |
      +----------+   +----------+   +----------+

 Master 和 Worker/Agent 之间 ipc:

    const cluster = require('cluster');

    if (cluster.isMaster) {
      const worker = cluster.fork();
      worker.send('hi there');
      worker.on('message', msg => {
        console.log(`msg: ${msg} from worker#${worker.id}`);
      });
    } else if (cluster.isWorker) {
      process.on('message', (msg) => {
        process.send(msg);
      });
    }

为了方便调用，我们封装了一个 messenger 对象挂在 app / agent 实例上，提供一系列友好的 API。

### send

    app.messenger.broadcast(action, data)：发送给所有的 agent / app 进程（包括自己）
    app.messenger.sendToApp(action, data): 发送给所有的 app 进程
    app.messenger.sendToAgent(action, data): 发送给 agent 进程
    agent.messenger.sendRandom(action, data): agent 会随机发送消息给一个 app 进程（由 master 来控制发送给谁）
    app.messenger.sendTo(pid, action, data): 发送给指定进程

### receive

    app.messenger.on(action, data => {
    // process data
    });
    app.messenger.once(action, data => {
    // process data
    });

e.g.

    // app.js
    module.exports = app => {
      // 注意，只有在 egg-ready 事件拿到之后才能发送消息
      app.messenger.once('egg-ready', () => {
        app.messenger.sendToAgent('agent-event', { foo: 'bar' });
        app.messenger.sendToApp('app-event', { foo: 'bar' });
      });
    }