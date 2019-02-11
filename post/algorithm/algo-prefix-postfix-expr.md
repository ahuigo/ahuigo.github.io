---
title: 前缀、中缀、后缀表达式
date: 2019-02-09
---
# 前缀、中缀、后缀表达式
有三种表达式
1. 前缀prefix: + 3 * 5 6
2. 中缀infix: 3+5*6
3. 后缀postfix: 3 5 6 * +

对于人类来说，中缀宜读，对于计算机来说，前缀、后缀宜读。那么他们如何转化呢？

可以采用堆栈的思想: 操作符号先压入栈 opertor，然后相同或较低的优先级出现的时候再出栈。

    def infix2postfix(expr):
        priority = '(+-*/'
        operator = []
        tokens = []
        for token in expr.split(' '):
            if token == '(':
                operator.append(token)
            elif token == ')':
                while operator:
                    t = operator.pop()
                    if t != '(':
                        tokens.append(t)
                    else:
                        break
            elif token in priority:
                while operator and  priority.index(token) <= priority.index(operator[-1]) :
                    tokens.append(operator.pop())
                operator.append(token)
            else:
                tokens.append(token)

        while operator:
            tokens.append(operator.pop())

        print(''.join(tokens))
    
    infix2postfix("( A + B ) * ( C + D )")
    infix2postfix("( A + B ) * C")
    infix2postfix("A + B * C")

## 中序求值

    A B + C *
        A: A
        B: A B 
        +: (A+B)
        C: (A+B) C
        *: (A+B)*C

## 前序求值
需要两个栈: 符号栈，数值栈

    * + A B C
        *: *    []
        +: * +  []
        A: * +  [A]
        B: *    [A+B]
        C:      [(A+B)*C]


# 参考
- 中缀，前缀和后缀表达式 
https://facert.gitbooks.io/python-data-structure-cn/3.%E5%9F%BA%E6%9C%AC%E6%95%B0%E6%8D%AE%E7%BB%93%E6%9E%84/3.9.%E4%B8%AD%E7%BC%80%E5%89%8D%E7%BC%80%E5%92%8C%E5%90%8E%E7%BC%80%E8%A1%A8%E8%BE%BE%E5%BC%8F/