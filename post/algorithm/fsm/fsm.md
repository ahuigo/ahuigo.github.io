---
title: fsm有限状态机
date: 2022-09-12
private: true
---
# fsm有限状态机
在计算理论（Theory of computation）中，
1. FSM 是一切的基础，也是能力最为有限的机器。
2. 在其能力之上是 CFL（Context Free Language）
3. 然后是 Turing Machine。

## FSM
FSM(Finite State Machine) 或叫FSA(Finite State Machine Automate) 最基础的状态机

定义为：` M=(S,I,O,f,g,s0)`

    S 状态集合
    I 输入集合
    O 输出集合
    f 输入转换函数
    g 输出转换函数
    s0 初始状态

## DFA(deterministic finite automaton, DFA)
确定有限状态自动机DFA组成 $A=(Q,\Sigma ,\delta ,s,F)$

1. 一个非空有限的状态集合Q
1. 一个输入字母表 $\Sigma$ （非空有限的字符集合）
1. 一个转移函数 $\delta$ : $(Q,\Sigma)->Q$
1. 一个开始状态$s \in Q$
1. 一个接受状态的集合 F ($F\subseteq Q$)

有限状态自动机在定义方面与FSM的差别
1. 没有输出g/O 转换函数
2. F 接受状态相当于代替了g/O

> TM(Turing Machine) 图灵机包含DFA/FSM

### 补运算
只需要把接受状态和非接受状态互换, 新的DFA运算就是补运算

    状态运算：判断一个 binary string 能被 8 整除
    它的补运算：判断一个 binary string 不能被 8 整除,

## NFA, 非确定有限状态自动机
NFA（Nondeterministic Finite Automaton） 给定一个状态和一个输入，我们无法确定地转换到下一个状态

对付 NFA，我们只能用 decision tree —— 
1. 凡是一个输入可能产生多个状态的地方，有几个输出状态就分裂出几条路径，
2. 这样当所有路径都结束（要么输入走完了，要么卡在某个状态无法处理了），
3. 只要有一条路径到达接受状态，那么这个输入就满足 NFA。

NFA分支路径可能产生指数增长，很多NFA可以转换成DFA的

应用：
1. 很多regex 表达 `.*000`就可以转化成用NFA表示。
早期的 regex 会被转化成 NFA，然后再被转化成 DFA，最终能够高效地处理输入。
2. 使用 FSM 处理 regex 的代表产品如 awk，sed，re2。
3. 带反向引用的regex 无法用NFA表示，也无法用context free 表示，它是有上下文的。

# References
陈天-谈谈状态机 https://zhuanlan.zhihu.com/p/28142401