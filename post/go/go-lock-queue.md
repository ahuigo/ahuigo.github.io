---
title: golang 原子队列实现(无锁)
date: 2020-07-22
private: true
---
# golang 原子队列实现(无锁)
本文参考：
    // cas vs mutex 性能https://github.com/golang/go/issues/17604
    // 无锁队列的实现 https://coolshell.cn/articles/8239.html
    // 原子操作 https://studygolang.com/articles/19638
    MPE

相关代码：
1. go-lib/lock/cas/atom-cas.go
## 不要对stack栈变量执行原子操作
    $ go build -o x.exe atom-cas.go
    $ go tool objdump -s .Queue.PushTailCAS x.exe
    TEXT command-line-arguments.Queue.PushTailCAS(SB) gofile../Users/ahui/www/go-lib/lock/cas/atom-cas.go
      atom-cas.go:47	0x4232			65488b0c2500000000	MOVQ GS:0, CX						[5:9]R_TLS_LE
      atom-cas.go:47	0x423b			483b6110		CMPQ 0x10(CX), SP
      atom-cas.go:47	0x423f			0f86fd010000		JBE 0x4442
      atom-cas.go:47	0x4245			4883ec70		SUBQ $0x70, SP
      atom-cas.go:47	0x4249			48896c2468		MOVQ BP, 0x68(SP)
      atom-cas.go:47	0x424e			488d6c2468		LEAQ 0x68(SP), BP
      atom-cas.go:47	0x4253			488d0500000000		LEAQ 0(IP), AX						[3:7]R_PCREL:type.command-line-arguments.Queue
      atom-cas.go:47	0x425a			48890424		MOVQ AX, 0(SP)
      atom-cas.go:47	0x425e			e800000000		CALL 0x4263						[1:5]R_CALL:runtime.newobject
      atom-cas.go:47	0x4263			488b442408		MOVQ 0x8(SP), AX
      atom-cas.go:47	0x4268			4889442460		MOVQ AX, 0x60(SP)
      atom-cas.go:47	0x426d			833d0000000000		CMPL $0x0, 0(IP)					[2:6]R_PCREL:runtime.writeBarrier+-1
      atom-cas.go:47	0x4274			0f8596010000		JNE 0x4410
      atom-cas.go:47	0x427a			488b542478		MOVQ 0x78(SP), DX
      atom-cas.go:47	0x427f			488910			MOVQ DX, 0(AX)
      atom-cas.go:47	0x4282			0f10842480000000	MOVUPS 0x80(SP), X0
      atom-cas.go:47	0x428a			0f114008		MOVUPS X0, 0x8(AX)
      atom-cas.go:47	0x428e			0f10842490000000	MOVUPS 0x90(SP), X0
      atom-cas.go:47	0x4296			0f114018		MOVUPS X0, 0x18(AX)
      atom-cas.go:47	0x429a			0f108424a0000000	MOVUPS 0xa0(SP), X0
      atom-cas.go:47	0x42a2			0f114028		MOVUPS X0, 0x28(AX)
      atom-cas.go:47	0x42a6			eb03			JMP 0x42ab
      atom-cas.go:49	0x42a8			4889c8			MOVQ CX, AX

我们注意到

[https://github.com/golang/go/issues/17604] 指出：

> The compiler moves q to the heap because atomic.CompareAndSwapInt32 is implemented in assembly. Escape analysis has to conservatively assume that any pointer passed to assembly escapes.

> We could mark atomic.CompareAndSwapInt32 as noescape, but there's really no point. If you're calling atomic.CompareAndSwapInt32 on something on the stack, you're doing something wrong. There's no need for atomic operations on stack variables.

也就是说，由于原子函数 atomic.CompareAndSwapInt32 是汇编的，逃逸分析（escape analysis）会保守假设任何传值都要escape 逃逸到heap。
我们可以标记atomic.CompareAndSwapInt32 as noescape, 但没有意义