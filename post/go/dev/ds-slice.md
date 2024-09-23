---
title: golang slice inner
date: 2024-09-19
private: true
---
# golang slice inner
## slice 生成函数
Go 语言中包含三种初始化切片的方式：

    arr[0:3] or slice[0:3]
    slice := []int{1, 2, 3}
    slice := make([]int, 10)

编译器的slice生成函数：　cmd/compile/internal/types.NewSlice ：

    func NewSlice(elem *Type) *Type {
        if t := elem.Cache.slice; t != nil {
            if t.Elem() != elem {
                Fatalf("elem mismatch")
            }
            return t
        }

        t := New(TSLICE)
        // Extra 字段包含切片内元素类型，程序在运行时可动态获取extra（反射）。
        t.Extra = Slice{Elem: elem}
        elem.Cache.slice = t
        return t
    }

上述方法返回结构体中的 Extra 字段是一个只包含切片内元素类型的结构，也就是说切片内元素的类型都是在编译期间确定的，编译器确定了类型之后，会将类型存储在 Extra 字段中帮助程序在运行时动态获取。

## slice 数据结构 
编译期间的切片是 cmd/compile/internal/types.Slice 类型的，但是在运行时切片可以由如下的 reflect.SliceHeader 结构体表示，其中:

    type SliceHeader struct {
        // Data 是一片连续的内存空间(逻辑上)
        Data uintptr
        Len  int
        Cap  int
    }

## 使用下标创建
编译器会将 `arr[0:3] 或者 slice[0:3]` 等语句转换成 OpSliceMake 操作，我们可以通过下面的代码来验证一下：

    package opslicemake
    func newSlice() []int {
        arr := [3]int{1, 2, 3}
        slice := arr[0:1]
        return slice
    }

通过 `GOSSAFUNC=newSlice ` 变量编译上述代码可以得到一系列 SSA 中间代码，其中 `slice := arr[0:1]` 语句在 “decompose builtin” 阶段对应的代码如下所示：

    v27 (+5) = SliceMake <[]int> v11 v14 v17
    name &arr[*[3]int]: v11
    name slice.ptr[*int]: v11
    name slice.len[int]: v14
    name slice.cap[int]: v17

SliceMake 操作会接受四个参数(元素类型、数组指针、切片大小和容量), 它返回的新切片会指向原切片。

## 字面量创建
当我们使用字面量 `[]int{1, 2, 3}` 创建新的切片时，cmd/compile/internal/gc.slicelit 函数在编译期间展开后 代码片段：

    var vstat [3]int
    vstat[0] = 1
    vstat[1] = 2
    vstat[2] = 3
    var vauto *[3]int = new([3]int)
    *vauto = vstat
    slice := vauto[:]

解释一下：

    根据切片中的元素数量对底层数组的大小进行推断并创建一个数组；
    将这些字面量元素存储到初始化的数组中；
    创建一个同样指向 [3]int 类型的数组指针；
    将静态存储区的数组 vstat 赋值给 vauto 指针所在的地址；
    通过 [:] 操作获取一个底层使用 vauto 的切片(下标法是建切片的底层方法)；

## make 初始化
但是当我们使用 make 关键字创建切片时，很多工作都需要运行时的参与；调用方必须向 make 函数传入切片的大小以及可选的容量，类型检查期间的 cmd/compile/internal/gc.typecheck1 函数会校验入参：

    func typecheck1(n *Node, top int) (res *Node) {
        switch n.Op {
        ...
        case OMAKE:
            args := n.List.Slice()

            i := 1
            switch t.Etype {
            case TSLICE:
                if i >= len(args) {
                    yyerror("missing len argument to make(%v)", t)
                    return n
                }

                l = args[i]
                i++
                var r *Node
                if i < len(args) {
                    r = args[i]
                }
                ...
                if Isconst(l, CTINT) && r != nil && Isconst(r, CTINT) && l.Val().U.(*Mpint).Cmp(r.Val().U.(*Mpint)) > 0 {
                    yyerror("len larger than cap in make(%v)", t)
                    return n
                }

                n.Left = l
                n.Right = r
                n.Op = OMAKESLICE
            }
        ...
        }
    }

上述函数不仅会检查 len 是否传入，还会保证传入的容量 cap 一定大于或者等于 len。

### 堆/栈内存分配
除了校验参数之外，当前函数会将 OMAKE 节点转换成 OMAKESLICE，中间代码生成的 cmd/compile/internal/gc.walkexpr 函数会依据下面两个条件转换 OMAKESLICE 类型的节点：

    切片的大小和容量是否足够小；
    切片是否发生了逃逸，最终在堆上初始化

当切片发生逃逸或者非常大时，运行时需要 runtime.makeslice 在堆上初始化切片，如果当前的切片不会发生逃逸并且切片非常小的时候，make([]int, 3, 4) 会被直接转换成如下所示的代码：

    var arr [4]int
    n := arr[:3]

上述代码会初始化数组并通过下标 `[:3]` 得到数组对应的切片，这两部分操作都会在编译阶段完成，编译器会在栈上或者静态存储区创建数组并将 `[:3]` 转换成上一节提到的 OpSliceMake 操作。

### runtime.makeslice
runtime.makeslice 主要计算切片占用的内存空间并在堆上申请一片连续的内存(元素大小x切片Cap)

    func makeslice(et *_type, len, cap int) unsafe.Pointer {
        mem, overflow := math.MulUintptr(et.size, uintptr(cap))
        if overflow || mem > maxAlloc || len < 0 || len > cap {
            mem, overflow := math.MulUintptr(et.size, uintptr(len))
            if overflow || mem > maxAlloc || len < 0 {
                panicmakeslicelen()
            }
            panicmakeslicecap()
        }

        return mallocgc(mem, et, true)
    }

虽然编译期间可以检查出很多错误，但是在创建切片的过程中如果发生了以下错误会直接触发运行时错误并崩溃：

    内存空间的大小发生了溢出；
    申请的内存大于最大可分配的内存；
    传入的长度小于 0 或者长度大于容量；

最后调用的 runtime.mallocgc 
1. 如果遇到了比较小的对象会直接初始化在 Go 语言调度器里面的 P 结构中，
2. 而大于 32KB 的对象会在堆上初始化，后面的 Go 语言的内存分配器再讲

### 构建结构体 reflect.SliceHeader 
构建reflect.SliceHeader属于 runtime.makeslice 的调用方，该函数仅会返回指向底层数组的指针，调用方会在编译期间构建切片结构体：

    func typecheck1(n *Node, top int) (res *Node) {
        switch n.Op {
        ...
        case OSLICEHEADER:
        switch 
            t := n.Type
            n.Left = typecheck(n.Left, ctxExpr)
            l := typecheck(n.List.First(), ctxExpr)
            c := typecheck(n.List.Second(), ctxExpr)
            l = defaultlit(l, types.Types[TINT])
            c = defaultlit(c, types.Types[TINT])

            n.List.SetFirst(l)
            n.List.SetSecond(c)
        ...
        }
    }

OSLICEHEADER 操作会创建我们在上面介绍过的结构体 reflect.SliceHeader，其中包含数组指针、切片长度和容量，它是切片在运行时的表示：

    type SliceHeader struct {
        Data uintptr
        Len  int
        Cap  int
    }

因为大多数对切片类型的操作并不需要直接操作原来的 runtime.slice 结构体，所以 reflect.SliceHeader 的引入能够减少切片初始化时的少量开销

# slice 操作
## 访问元素
### len+cap
使用 len 和 cap 时，cmd/compile/internal/gc.state.expr 函数会在 SSA 生成阶段阶段将它们分别转换成 OpSliceLen 和 OpSliceCap：

    func (s *state) expr(n *Node) *ssa.Value {
        switch n.Op {
        case OLEN, OCAP:
            switch {
            case n.Left.Type.IsSlice():
                op := ssa.OpSliceLen
                if n.Op == OCAP {
                    op = ssa.OpSliceCap
                }
                return s.newValue1(op, types.Types[TINT], s.expr(n.Left))
            ...
            }
        ...
        }
    }

访问切片中的字段可能会触发 “decompose builtin” 阶段的优化，len(slice) 或者 cap(slice) 在一些情况下会直接替换成切片的长度或者容量，不需要在运行时获取：

    (SlicePtr (SliceMake ptr _ _ )) -> ptr
    (SliceLen (SliceMake _ len _)) -> len
    (SliceCap (SliceMake _ _ cap)) -> cap

### index slice
访问切片中元素使用的 OINDEX 操作也会在中间代码生成期间转换成对地址的直接访问：

    func (s *state) expr(n *Node) *ssa.Value {
        switch n.Op {
        case OINDEX:
            switch {
            case n.Left.Type.IsSlice():
                p := s.addr(n, false)
                return s.load(n.Left.Type.Elem(), p)
            ...
            }
        ...
        }
    }

## 追加和扩容
cmd/compile/internal/gc.state.append 方法会根据返回值是否会覆盖原变量，选择进入两种流程.
 
如果 append 返回的新切片不需要赋值回原有的变量，就会进入如下的处理流程：

    // append(slice, 1, 2, 3)
    ptr, len, cap := slice
    newlen := len + 3
    if newlen > cap {
        // 对切片进行扩容并将新的元素依次加入切片。
        ptr, len, cap = growslice(slice, newlen)
        newlen = len + 3
    }
    *(ptr+len) = 1
    *(ptr+len+1) = 2
    *(ptr+len+2) = 3
    return makeslice(ptr, newlen, cap)

如果　append 后的切片会覆盖原切片，这时 cmd/compile/internal/gc.state.append 方法会使用另一种方式展开关键字：

    // slice = append(slice, 1, 2, 3)
    a := &slice
    ptr, len, cap := slice
    newlen := len + 3
    if uint(newlen) > uint(cap) {
       newptr, len, newcap = growslice(slice, newlen)
       vardef(a)
       *a.cap = newcap
       *a.ptr = newptr
    }
    newlen = len + 3
    *a.len = newlen
    *(ptr+len) = 1
    *(ptr+len+1) = 2
    *(ptr+len+2) = 3


### growslice 扩容
运行时根据切片的当前容量选择不同的策略进行扩容：
1. 如果期望容量大于当前容量的两倍就会使用期望容量；
2. 如果当前切片的长度小于 1024 就会将容量翻倍；
3. 如果当前切片的长度大于 1024 就会每次增加 25% 的容量，直到新容量大于期望容量；

code:

    func growslice(et *_type, old slice, cap int) slice {
        newcap := old.cap
        doublecap := newcap + newcap
        if cap > doublecap {
            newcap = cap
        } else {
            if old.len < 1024 {
                newcap = doublecap
            } else {
                for 0 < newcap && newcap < cap {
                    newcap += newcap / 4
                }
                if newcap <= 0 {
                    newcap = cap
                }
            }
        }
    }

#### 内存对齐
然后，还需要根据切片中的元素大小对齐内存，当数组中元素所占的字节大小为 1、8 或者 2 的倍数时，运行时会使用如下所示的代码对齐内存：

	var overflow bool
	var lenmem, newlenmem, capmem uintptr
	switch {
	case et.size == 1: //et是元素类型，size 是元素大小
		lenmem = uintptr(old.len)
		newlenmem = uintptr(cap)
		capmem = roundupsize(uintptr(newcap))
		overflow = uintptr(newcap) > maxAlloc
		newcap = int(capmem)
	case et.size == sys.PtrSize:
		lenmem = uintptr(old.len) * sys.PtrSize
		newlenmem = uintptr(cap) * sys.PtrSize
		capmem = roundupsize(uintptr(newcap) * sys.PtrSize)
		overflow = uintptr(newcap) > maxAlloc/sys.PtrSize
		newcap = int(capmem / sys.PtrSize)
	case isPowerOfTwo(et.size):
		...
	default:
		...
	}
    // ...省略：如果计算新容量时发生了内存溢出或者请求内存超过上限，就会直接崩溃退出程序

runtime.roundupsize 函数会将待申请的内存向上取整，取整时会使用 runtime.class_to_size 数组
(使用该数组中的整数可以提高内存的分配效率并减少碎片，后面内存分配一节详细介绍该数组的作用)：

    var class_to_size = [_NumSizeClasses]uint16{
        0,
        8,
        16,
        32,
        48,
        64,
        80,
        ...,
    }

如果切片中元素不是指针类型，那么会调用 runtime.memclrNoHeapPointers 将超出切片当前长度的位置清空并在最后使用 runtime.memmove 将原数组内存中的内容拷贝到新申请的内存中。这两个方法都是用目标机器上的汇编指令实现的:

	var overflow bool
	var newlenmem, capmem uintptr
	switch {
	...
	default:
		lenmem = uintptr(old.len) * et.size
		newlenmem = uintptr(cap) * et.size
		capmem, _ = math.MulUintptr(et.size, uintptr(newcap))
		capmem = roundupsize(capmem)
		newcap = int(capmem / et.size)
	}
	...
	var p unsafe.Pointer
	if et.kind&kindNoPointers != 0 {
		p = mallocgc(capmem, nil, false)
		memclrNoHeapPointers(add(p, newlenmem), capmem-newlenmem)// 将超出切片当前长度的位置清空
	} else {
		p = mallocgc(capmem, et, true)
		if writeBarrier.enabled {
			bulkBarrierPreWriteSrcOnly(uintptr(p), uintptr(old.array), lenmem)
		}
	}

    // 将原数组内存中的内容拷贝到新申请的内存中
	memmove(p, old.array, lenmem) 

    // 返回新切片
	return slice{p, old.len, newcap}

runtime.growslice 函数最终会返回一个新的切片，其中包含了新的数组指针、大小和容量，这个返回的三元组最终会覆盖原切片。

    var arr []int64
    arr = append(arr, 1, 2, 3, 4, 5) 
    // size=5*8=40
    // 不过因为切片中的元素大小等于 sys.PtrSize，所以运行时会调用 runtime.roundupsize 向上取整内存的大小到 48 字节，所以新切片的容量为 48 / 8 = 6。

## 拷贝切片
copy(a, b) 涉及编译期间的 cmd/compile/internal/gc.copyany , 分两种情况进行处理拷贝操作.

如果当前 copy 不是在运行时调用的，copy(a, b) 会被直接转换成下面的代码：

    n := len(a)
    if n > len(b) {
        n = len(b)
    }
    if a.ptr != b.ptr {
        memmove(a.ptr, b.ptr, n*sizeof(elem(a))) 
    }

如果copy是在运行时,编译器会使用 runtime.slicecopy 替换运行期间调用的 copy，(底层都是调用memmove　)：

    func slicecopy(to, fm slice, width uintptr) int {
        if fm.len == 0 || to.len == 0 {
            return 0
        }
        n := fm.len
        if to.len < n {
            n = to.len
        }
        if width == 0 {
            return n
        }
        ...

        size := uintptr(n) * width
        if size == 1 {
            *(*byte)(to.array) = *(*byte)(fm.array)
        } else {
            // memmove 实现内存复制
            memmove(to.array, fm.array, size)
        }
        return n
    }

