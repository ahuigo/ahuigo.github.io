# combination
2. $\binom mn=\binom {n-m}n$
2. $\binom m{n+1}=\binom mn+ \binom {m-1}n$
解释下, 原来是n中选m, 增加1个后, 如果选出这1个, 还需要从剩余n个中, 再选m-1个

# probility
德摩根定律: $(A\cup B)^{C}=A^{C}\cap B^{C}$

概率计算总结
1. 非A	$P(A^{c})=1-P(A)$
2. A或B	$P(A\cup B)=P(A)+P(B)-P(A\cap B)$
3. A和B	$P(A\cap B)=P(A|B)P(B)=P(B|A)P(A)$
$P(A\cap B)=P(A)P(B) {\mbox{if A and B are independent}}$
4. B的情况下A的概率	${\displaystyle P(A\mid B)={\frac {P(A\cap B)}{P(B)}}={\frac {P(B|A)P(A)}{P(B)}}}$

![math/math-probability-1.png](/img/math/math-probability-1.png)

## 独立事件
1. 两事件独立
$P(AB)=P(A)P(B)$
2. 3事件独立, 必须同时满足两个条件: 
    1. 两两独立: 
        $P(AB)=P(A)P(B)$
        $P(BC)=P(B)P(C)$
        $P(AC)=P(A)P(C)$
    2. $P(ABC)=P(A)P(B)P(C)$
3. N事件独立, 同时满足: 两两独立, 三事件独立,....

### n重伯努力事件
独立事件A重复n次试验, 恰好发生的概率是:
$\binom kn p^k (1-p)^{n-k}$

#### 二项定理
每个 ${\tbinom  nk}$ 为一个称作二项式系数的特定正整数
${\displaystyle (x+y)^{n}={n \choose 0}x^{n}y^{0}+{n \choose 1}x^{n-1}y^{1}+{n \choose 2}x^{n-2}y^{2}+\cdots +{n \choose n-1}x^{1}y^{n-1}+{n \choose n}x^{0}y^{n},}$
