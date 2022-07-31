---
title: deno bundle
date: 2022-07-11
private: true
---
# deno bundle
bundle to a single file:
1. includes all dependencies of the specified input. 
2. exclude unused dependencies

For example:

    $ deno bundle https://deno.land/std@$STD_VERSION/examples/colors.ts colors.bundle.js
    Bundle https://deno.land/std@$STD_VERSION/examples/colors.ts
    Download https://deno.land/std@$STD_VERSION/examples/colors.ts
    Download https://deno.land/std@$STD_VERSION/fmt/colors.ts
    "colors.bundle.js" (9.83KB)

# Bundling for the Web
The output of deno bundle is intended for consumption in Deno and not for use in a web browser or other runtimes. That said, depending on the input it may work in other environments.

If you wish to bundle for the web, we recommend other solutions such as esbuild.

# deno compile
like bundle, but compile ts to binary instead

    $ deno compile -o color https://deno.land/std@$STD_VERSION/examples/colors.ts colors.bundle.js
    Compile https://deno.land/std/examples/colors.ts
    Emit a

## Arguments can be partially embedded.

    > deno compile --allow-read --allow-net https://deno.land/std/http/file_server.ts -p 8080
    > ./file_server --help

## Cross Compilation
    $ deno compile -h
    --target <target>
        Target OS architecture [possible values: x86_64-unknown-linux-gnu,
        x86_64-pc-windows-msvc, x86_64-apple-darwin, aarch64-apple-darwin]