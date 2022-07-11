---
title: deno vendor
date: 2022-07-11
private: true
---
# deno vendor
`deno vendor <specifiers>` will download all remote dependencies of the specified modules into a **local vendor** folder. 
For example:

    # Vendor the remote dependencies of main.ts
    $ deno vendor main.ts

    $ tree
    .
    ├── main.ts
    └── vendor
        ├── deno.land
        ├── import_map.json
        └── raw.githubusercontent.com

then use the vendored dependencies in your program.

    deno run --no-remote --import-map=vendor/import_map.json main.ts

Note that you may specify multiple modules and remote modules when vendoring.

    deno vendor main.ts test.deps.ts https://deno.land/std/path/mod.ts