---
title: umi cli
date: 2023-03-07
private: true
---
# umi cli entrance
source:

    // node_modules/umi/bin/umi.js
    umi/packages/umi/bin/umi.js
        require('../dist/cli/cli').run()

packages/umi/src/cli/cli.ts: run()

    import { Service } from '../service/service';
    import { dev } from './dev';
    if commaond=='dev':
        process.env.NODE_ENV = 'development'
        dev()
    else:
        new Service().run2()

packages/umi/src/cli/dev.ts: 

    const child = fork({
        scriptPath: require.resolve('../../bin/forkedDev'),
    });

packages/umi/src/cli/forkedDev.ts: 

    import { Service } from '../service/service';
    await new Service().run2({
      name: DEV_COMMAND, //'dev'
      args,
    });

# umi-scripts
    scripts/
        bin/umi-scripts.js
            exec('../{name}.ts')
        father.ts
          command = `father ${args.join(' ')}`;

