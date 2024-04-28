---
title: lambda function
date: 2024-03-28
private: true
---
# lambda eval
1. deno/v8 isolate: jslib/pwa/js-worker/isolate/readme.md
2. go docker: https://github.com/openfaas/faas?

## run python
### python exec
```python
code = '''
def main(a,b):
    return a+b

main
'''

f = exec(code) # like js eval(code)
add = eval('main')
print(add(1, 2))
print(f,add)
```
### deno run python(native)
deno run -A --unstable test.ts

    import { python } from "https://deno.land/x/python/mod.ts";
    const np = python.import("numpy");
    const plt = python.import("matplotlib.pyplot");
    const xpoints = np.array([1, 8]);
    const ypoints = np.array([3, 10]);
    plt.plot(xpoints, ypoints);
    plt.show();

### deno/v8 wasm for python(Pyodide)
https://pythondev.readthedocs.io/wasm.html
- [x] pyodide browser
- [] pyodide deno(WIP, https://github.com/pyodide/pyodide/issues/3420)

## js exec
refer to:
- post/ria/js-func-eval.md

### resource limit
Besides using the container as sugessted in comments:

    --max-old-space-size (max size of the old space (in Mbytes))
            type: size_t  default: --max-old-space-size=0
    --max-heap-size (max size of the heap (in Mbytes) both max_semi_space_size and max_old_space_size take precedence. All three flags cannot be specified at the same time.)
            type: size_t  default: --max-heap-size=0

e.g.:

    deno run --v8-flags='--max-heap-size=50,--max-old-space-size=50' a.ts