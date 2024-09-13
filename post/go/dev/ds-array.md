---
title: go data array implement
date: 2024-09-13
private: true
---
# go data array 
> 本文以golang release-branch.go1.22 为例

## 数组长度推导
只能在编译期创建数组, 生成长度固定的 types.Array 结构体。

    // cmd/compile/internal/types.NewArray
    func NewArray(elem *Type, bound int64) *Type {
        if bound < 0 {
            Fatalf("NewArray: invalid bound %v", bound)
        }
        t := New(TARRAY)
        t.Extra = &Array{Elem: elem, Bound: bound}
        t.SetNotInHeap(elem.NotInHeap())
        return t
    }

`[10]T`的长度是在类型检查阶段就会被提取出来;
`[...]T` 编译器会在的 cmd/compile/internal/gc.typecheckcomplit 函数中对该数组的大小进行推导：

    func typecheckcomplit(n *Node) (res *Node) {
        ...
        if n.Right.Op == OTARRAY && n.Right.Left != nil && n.Right.Left.Op == ODDD {
            n.Right.Right = typecheck(n.Right.Right, ctxType)
            if n.Right.Right.Type == nil {
                n.Type = nil
                return n
            }
            elemType := n.Right.Right.Type

            length := typecheckarraylit(elemType, -1, n.List.Slice(), "array literal")

            n.Op = OARRAYLIT
            n.Type = types.NewArray(elemType, length)
            n.Right = nil
            return n
        }
        ...

        switch t.Etype {
        case TARRAY:
            typecheckarraylit(t.Elem(), t.NumElem(), n.List.Slice(), "array literal")
            n.Op = OARRAYLIT
            n.Right = nil
        }
    }

## 语句转换
对于不同的数组长度，负责初始化字面量的 cmd/compile/internal/gc.anylit 有2种不同的优化：

    // 当元素数量小于或者等于 4 个时，会直接将数组中的元素放置在栈上；
    // 当元素数量大于 4 个时，会将数组中的元素放置到静态区并在运行时取出；
    func anylit(n *Node, var_ *Node, init *Nodes) {
        t := n.Type
        switch n.Op {
        case OSTRUCTLIT, OARRAYLIT:
            if n.List.Len() > 4 {
                ...
            }

            fixedlit(inInitFunction, initKindLocalCode, n, var_, init)
        ...
        }
    }

当数组的元素<=4个时，cmd/compile/internal/gc.fixedlit 会负责在函数编译之前将 `[3]{1, 2, 3}` 转换成更加原始的语句：

    func fixedlit(ctxt initContext, kind initKind, n *Node, var_ *Node, init *Nodes) {
        var splitnode func(*Node) (a *Node, value *Node)
        ...

        for _, r := range n.List.Slice() {
            a, value := splitnode(r)
            a = nod(OAS, a, value)
            a = typecheck(a, ctxStmt)
            switch kind {
            case initKindStatic:
                genAsStatic(a)
            case initKindLocalCode:
                a = orderStmtInPlace(a, map[string][]*Node{})
                a = walkstmt(a)
                init.Append(a)
            }
        }
    }

当数组中元素的个数小于或者等于四个并且 cmd/compile/internal/gc.fixedlit 函数接收的 kind 是 initKindLocalCode 时，上述代码会将原有的初始化语句 `[3]int{1, 2, 3}` 拆分成一个声明变量的表达式和几个赋值表达式，这些表达式会完成对数组的初始化：

    var arr [3]int
    arr[0] = 1
    arr[1] = 2
    arr[2] = 3

但是如果当前数组的元素大于四个，cgc.anylit 会先获取一个唯一的 staticname，然后调用 gc.fixedlit 函数在静态存储区初始化数组中的元素并将临时变量赋值给数组：

    func anylit(n *Node, var_ *Node, init *Nodes) {
        t := n.Type
        switch n.Op {
        case OSTRUCTLIT, OARRAYLIT:
            if n.List.Len() > 4 {
                vstat := staticname(t)
                vstat.Name.SetReadonly(true)

                fixedlit(inNonInitFunction, initKindStatic, n, vstat, init)

                a := nod(OAS, var_, vstat)
                a = typecheck(a, ctxStmt)
                a = walkexpr(a, init)
                init.Append(a)
                break
            }

            ...
        }
    }

假设代码需要初始化 [5]int{1, 2, 3, 4, 5}，那么我们可以将上述过程理解成以下的伪代码：

    var arr [5]int
    statictmp_0[0] = 1
    statictmp_0[1] = 2
    statictmp_0[2] = 3
    statictmp_0[3] = 4
    statictmp_0[4] = 5
    arr = statictmp_0

总结起来，在不考虑逃逸分析的情况下，如果数组中元素的个数小于或者等于 4 个，那么所有的变量会直接在栈上初始化，如果数组元素大于 4 个，变量就会在静态存储区初始化然后拷贝到栈上

## 访问和赋值
### 静态类型越界检查
> 仅当数据下标能确定时，才能判断
Go 静态类型检查判断数组越界，cmd/compile/internal/gc.typecheck1 会验证访问数组的索引：

    func typecheck1(n *Node, top int) (res *Node) {
        switch n.Op {
        case OINDEX:
            ok |= ctxExpr
            l := n.Left  // array
            r := n.Right // index
            switch n.Left.Type.Etype {
            case TSTRING, TARRAY, TSLICE:
                ...
                if n.Right.Type != nil && !n.Right.Type.IsInteger() {
                    yyerror("non-integer array index %v", n.Right)
                    break
                }
                if !n.Bounded() && Isconst(n.Right, CTINT) {
                    x := n.Right.Int64()
                    if x < 0 {
                        yyerror("invalid array index %v (index must be non-negative)", n.Right)
                    } else if n.Left.Type.IsArray() && x >= n.Left.Type.NumElem() {
                        yyerror("invalid array index %v (out of bounds for %d-element array)", n.Right, n.Left.Type.NumElem())
                    }
                }
            }
        ...
        }
    }

可以看到：

    访问数组的索引是非整数时，报错 “non-integer array index %v”；
    访问数组的索引是负数时，报错 “invalid array index %v (index must be non-negative)"；
        arr[4]: invalid array index 4 (out of bounds for 3-element array)
    访问数组的索引越界时，报错 “invalid array index %v (out of bounds for %d-element array)"；
        arr[i]: panic: runtime error: index out of range [4] with length 3

越界操作由运行时的 runtime.panicIndex 和 runtime.goPanicIndex 触发程序的运行时错误并导致崩溃退出：

    TEXT runtime·panicIndex(SB),NOSPLIT,$0-8
        MOVL	AX, x+0(FP)
        MOVL	CX, y+4(FP)
        JMP	runtime·goPanicIndex(SB)

    func goPanicIndex(x int, y int) {
        panicCheck1(getcallerpc(), "index out of range")
        panic(boundsError{x: int64(x), signed: true, y: y, code: boundsIndex})
    }

### ssa 查看
当数组的访问操作 OINDEX 成功通过编译器的检查后，会被转换成几个 SSA 指令，假设我们有如下所示的 Go 语言代码，通过如下的方式进行编译会得到 ssa.html 文件：

    package check
    func outOfRange() int {
        arr := [3]int{1, 2, 3}
        i := 4
        elem := arr[i]
        return elem
    }

    $ GOSSAFUNC=outOfRange go build array.go
    dumped SSA to ./ssa.html

start 阶段生成的 SSA 代码就是优化之前的第一版中间代码，`elem := arr[i]` 对应的中间代码如下，

    //Go 为数组生成了越界检查指令 IsInBounds, 当条件不满足时触发程序崩溃的 PanicBounds 指令：
    b1:
        ...
        v22 (6) = LocalAddr <*[3]int> {arr} v2 v20
        v23 (6) = IsInBounds <bool> v21 v11
    If v23 → b2 b3 (likely) (6)

    b2: ← b1-
        v26 (6) = PtrIndex <*int> v22 v21
        v27 (6) = Copy <mem> v20
        v28 (6) = Load <int> v26 v27 (elem[int])
        ...
    Ret v30 (+7)

    b3: ← b1-
        v24 (6) = Copy <mem> v20
        v25 (6) = PanicBounds <mem> [0] v21 v11 v24
    Exit v25 (6)

编译器会将 PanicBounds 指令转换成上面提到的 runtime.panicIndex 函数

当数组下标没有越界时，编译器会将内存地址+下标、利用 PtrIndex 计算出目标元素的地址，最后使用 Load 操作将指针中的元素加载到内存中。

    b1:
        ...
        v21 (5) = LocalAddr <*[3]int> {arr} v2 v20
        v22 (5) = PtrIndex <*int> v21 v14
        v23 (5) = Load <int> v22 v20 (elem[int])
        ...

数组的赋值和更新操作 a[i] = 2 也会生成 SSA 生成期间计算出数组元素的内存地址，然后修改当前内存地址的内容. ssa 如下：

    b1:
        ...
        v21 (5) = LocalAddr <*[3]int> {arr} v2 v19
        v22 (5) = PtrIndex <*int> v21 v13
        v23 (5) = Store <mem> {int} v22 v20 v19
        ...

赋值的过程中会先确定目标数组的地址，再通过 PtrIndex 获取目标元素的地址，最后使用 Store 指令将数据存入地址中(上面的SSA 代码中可以看出这些是在编译期中进行的）