# Disassemble
```
def myfunc(alist):
    return len(alist)
>>> dis.dis(myfunc)
  2           0 LOAD_GLOBAL              0 (len)
              3 LOAD_FAST                0 (alist)
              6 CALL_FUNCTION            1
              9 RETURN_VALUE
```
## Bytecode
```
>>> bytecode = dis.Bytecode(myfunc)
>>> for instr in bytecode:
...     print(instr.opname)
...
LOAD_GLOBAL
LOAD_FAST
CALL_FUNCTION
RETURN_VALUE
```

## show_code and code_info
```
>>> def f(): pass
>>> print(dis.code_info(f))
Name:              f
Filename:          <stdin>
Argument count:    0
Kw-only arguments: 0
Number of locals:  0
Stack size:        1
Flags:             OPTIMIZED, NEWLOCALS, NOFREE
Constants:
   0: None

>>> dis.show_code(f)
Name:              f
Filename:          <stdin>
Argument count:    0
Kw-only arguments: 0
Number of locals:  0
Stack size:        1
Flags:             OPTIMIZED, NEWLOCALS, NOFREE
Constants:
   0: None
```
