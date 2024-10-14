---
title: deno cmd
date: 2022-07-04
private: true
---
# deno run script

    deno run main.ts
    deno run https://mydomain.com/main.ts
    cat main.ts | deno run -

## run with arguments:

    deno run main.ts a b -c --quiet
    // main.ts
    console.log(Deno.args); // [ "a", "b", "-c", "--quiet" ]

## run with allow permissions

    deno run --allow-net net_client.ts

for more: https://deno.land/manual/getting_started/permissions#permissions-list

    file permission:
        --allow-read[=<PATH>...] or -R[=<PATH>...]
        --deny-read[=<PATH>...]
        --allow-write[=<PATH>...] or -W[=<PATH>...]
    os env:
        --deny-env[=<VARIABLE_NAME>...]
        --deny-env=AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY
    network:
        deno run --allow-net
        deno run --allow-net=github.com,jsr.io script.ts
        deno run --allow-net=example.com:80 script.ts
    

## watch mode
The files that are watched depend on the subcommand used:

- for `deno run, deno test, and deno bundle`:
    - the `entrypoint`, and all local files **the entrypoint(s) statically import(s)** will be watched.
- for `deno fmt`:
    - all **local files and directories** specified as command line arguments (or the **working directory** if no specific files/directories is passed) are watched.

Whenever one of the watched files is changed on disk, the program will automatically be restarted / formatted / tested / bundled.

    deno run --watch main.ts
    deno test --watch
    deno fmt --watch

## Other runtime flags
More flags which affect the execution environment.

    --inspect=<HOST:PORT>        activate inspector on host:port ...
    --inspect-brk=<HOST:PORT>    activate inspector on host:port and break at ...
    --location <HREF>            Value of 'globalThis.location' used by some web APIs
    --prompt                     Fallback to prompt if required permission wasn't passed
    --seed <NUMBER>              Seed Math.random()
    --v8-flags=<v8-flags>        Set V8 command line options. For help: ...

# deno repl
## eval

    $ deno repl --eval 'import { assert } from "https://deno.land/std@$STD_VERSION/testing/asserts.ts"'
    > assert(false)
    Uncaught AssertionError
        at assert (https://deno.land/std@0.110.0/testing/asserts.ts:224:11)
        at <anonymous>:2:1

## eval-file
--eval-file files are run before the --eval code.

    $ deno repl --eval-file=https://examples.deno.land/hello-world.ts,https://deno.land/std@$STD_VERSION/encoding/ascii85.ts
    Download https://examples.deno.land/hello-world.ts
    Hello, World!
    Download https://deno.land/std@$STD_VERSION/encoding/ascii85.ts
    exit using ctrl+d or close()
    > rfc1924 

## reload
URL files are cached and can be reloaded via the `--reload` flag.

# Reference
- deno documentation: https://deno.land/manual/getting_started/command_line_interface