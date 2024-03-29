---
title: deno type check
date: 2022-07-06
private: true
---
# deno lint
> https://docs.deno.com/runtime/manual/tools/linter

## lint command
Deno ships with a built-in code linter for JavaScript and TypeScript.

    # lint all JS/TS files in the current directory and subdirectories
    deno lint
    # lint specific files
    deno lint myfile1.ts myfile2.ts
    # lint all JS/TS files in specified directory and subdirectories
    deno lint src/
    # print result as JSON
    deno lint --json
    # read from stdin
    cat file.ts | deno lint -
    # deno lint --config=...

For more detail, run deno lint --help.

## list lint rules
https://lint.deno.land/

## Ignore directives
### Files
To ignore whole file, placed this at the top of the file:

    // deno-lint-ignore-file

You can also ignore certain diagnostics in the whole file

    // deno-lint-ignore-file no-explicit-any no-empty
    function foo(): any {
        // ...
    }

### ignore line
To ignore certain diagnostic `// deno-lint-ignore <codes...>` directive should be placed before offending line. 

    // deno-lint-ignore no-explicit-any
    function foo(): any {
        // ...
    }

or

    // @ts-ignore: inject APP_ENV to window
    // @ts-ignore-next
    window.APP_ENV = 'development';

### ignore typescript(deno support it partially)
ignore typescript check

    // @ts-ignore: trust me
    {/** @ts-ignore */}
    <div abc={`abc12`}></div>

    # including JavaScript if you have check JS enabled, by using the no-check pragma:
    // @ts-nocheck

## configuration 

    // deno.json
     "lint": {
        "files": {
          "include": ["src/"],
          "exclude": ["src/testdata/"]
        },
        "rules": {
          "tags": ["recommended"],
          "include": ["ban-untagged-todo","no-unused-vars"],
          "exclude": ["no-explicit-any"]
        }
      },

# class type

## prop init type with exclamation mark(!)
`!` not check uninitiated value's type

    class A{
        _onAfterRepaint!: () => void;
    }