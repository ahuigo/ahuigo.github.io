投票类网站的排序算法
======
# Preface

## Delicious 
按用户投票数算法 by 阮一峰

## Hacknews
{P-1} / (T+2)^G :
1. P 是投票数: 减1是去掉发贴人的投票
2. T: 距离发帖的Time（单位为小时）, 这个是权重的影响非常之大
3. G: 表示"重力因子"（gravityth power），即将帖子排名往下拉的力量，默认值为1.8

## Reddit
1. t = 发贴时间 - 2005年12月8日7:46:43(单位秒)
2. x = 赞成票 - 反对票
3. y = 投票方向(1:正 0:平 -1:负)
3. z = 帖子的受肯定（否定）的程度
```
    z = 1   # if x=0
    z = |x| # if x!=0
```
4. score = log(z) + yt/45000

结：帖子越新t 越大，投票数越多z越大

## Stack Overflow
```s
log(Qviews)x4+ Qscore x Qanswers/5 + sum(Ascores) 
----------------------------------------------
    [(Qage + Qupdated)/2 + 1]^1.5
```

分几个部分
1. log(Qviews)x4        问题浏览量
2. Qscore x Qanswers/5  问题得分x回答量/5 
    1. Qscore = VoteUp - VoteDown
3. sum(Ascores) 回答得分
4. Qage（距离问题发表的时间）和Qupdated（距离最后一个回答的时间s）
    1. [(Qage + Qupdated)/2 + 1]^1.5

总结：
与参与度（Qviews和Qanswers）和质量（Qscore和Ascores）成正比，与时间（Qage和Qupdated）成反比。

## 牛顿冷却定律, Newton's Law of Cooling
热文排名关心：投票数与时间。时间有一个自然冷却的作用：
1. 任一时刻，所有的文章都有一个"当前温度"
2. 如果一个用户对某篇文章投了赞成票，该文章的温度就上升一度。
3. 随着时间流逝，所有文章的温度都逐渐"冷却"。

建立"温度"与"时间"之间的函数关系, 即被后人称作"牛顿冷却定律"（Newton's Law of Cooling）:
1. 物体的冷却速度，与其当前温度与室温之间的温差成正比, 不同的物质有不同的α值 降温速度
2. 数学公式就是: T'(t) = -α(T(t)-H)
    1. T'(t) 是温度变化率
    2. H是室温
3. 对公式积分(见阮一峰blog)，且假定室温H为0度，我们得到:
T=T0xe^(-α(t-t0))
<img src="https://chart.googleapis.com/chart?cht=tx&chl=T%3DT_%7B0%7De%5E%7B-%5Calpha(t-t_%7B0%7D)%7D&chs=40">

4. 用在排名算法上就是：\
本期得分 = 上一期得分 x exp(-(冷却系数) x 间隔的小时数)

## 威尔逊区间
不考虑时间, 考虑好评率有个问题：样本数少时，好评率可能非常高。于是：
1. 第一步，计算每个项目的"好评率"（即赞成票的比例）。
2. 第二步，计算每个"好评率"的置信区间（以95%的概率）。
3. 第三步，根据置信区间的下限值，进行排名。这个值越大，排名就越高。

这样做的原理是，置信区间的宽窄与样本的数量有关:
1. 比如，A有8张赞成票，2张反对票；B有80张赞成票，20张反对票。这两个项目的赞成票比例都是80%，但是B的置信区间（假定[75%, 85%]）会比A的置信区间（假定[70%, 90%]）窄得多，因此B的置信区间的下限值（75%）会比A（70%）大，所以B应该排在A前面

2. 置信区间的实质，就是进行可信度的修正，弥补样本量过小的影响。

3. 二项分布的置信区间有多种计算公式，最常见的是"正态区间"（Normal approximation interval），教科书里几乎都是这种方法。但是，它只适用于样本较多的情况（np > 5 且 n(1 − p) > 5），对于小样本，它的准确性很差。

4. 1927年，美国数学家 Edwin Bidwell Wilson提出了一个修正公式，被称为"威尔逊区间"，很好地解决了小样本的准确性问题。

    ![Wilson_score_interval]
    在上面的公式中 ![P]，表示样本的"赞成票比例"，n表示样本的大小，![z_(1-a/2)]表示对应某个置信水平的z统计量，这是一个常数，可以通过查表或统计软件包得到。一般情况下，在95%的置信水平下，z统计量的值为1.96。

    1. 威尔逊置信区间的均值为\
    ![Wilson_mean]　　

    2. 它的下限值为: \
    ![Wilson_lower]　　

    3. 可以看到，当n的值足够大时，这个下限值会趋向。如果n非常小（投票人很少），这个下限值会大大小于。实际上，起到了降低"赞成票比例"的作用，使得该项目的得分变小、排名下降。

Reddit的评论排名，目前就使用这个算法。

## 贝叶斯平均, Bayesian average
"威尔逊区间" 有个缺点下限值会将赞成票的比例大幅拉低: 新项目或者冷门的项目，排名可能会长期靠后。

IMDB 给出的算法是：\
如果要比较两部电影的好坏，至少应该请同样多的观众观看和评分。既然文艺片的观众人数偏少，那么应该设法为它增加一些观众。
- WR=( v/(n+m) ) x R + ( m/(n+m) ) x C
1. WR， 加权得分（weighted rating）。
1. R，该电影的用户投票的平均得分（Rating）。
1. v，该电影的投票数（votes）。
1. m，排名前250名的电影的最低投票数（现在为3000）。
1. C， 所有电影的平均得分（现在为6.9）

仔细研究这个公式，你会发现，IMDB为每部电影增加了3000张选票，并且这些选票的评分都为6.9。这样做的原因是
1. 假设所有电影都至少有3000张选票，那么就都具备了进入前250名的评选条件；
2. 然后假设这3000张选票的评分是所有电影的平均得分（即假设这部电影具有平均水准）；
3. 最后，用现有的观众投票进行修正，长期来看，v/(v+m)这部分的权重将越来越大，得分将慢慢接近真实情况。

把这个公式写成更一般的形式：\
![Bayesian average]\
1. C，投票人数扩展的规模，是一个自行设定的常数，与整个网站的总体用户人数有关，可以等于每个项目的平均投票数。
1. n，该项目的现有投票人数。
1. x，该项目的每张选票的值。
1. m，总体平均分，即整个网站所有选票的算术平均值。

这种算法被称为"贝叶斯平均"（Bayesian average）。因为某种程度上，它借鉴了"贝叶斯推断"（Bayesian inference）的思想： 
1. 既然不知道投票结果，那就先估计一个值，然后不断用新的信息修正，使得它越来越接近正确的值。
2. 在这个公式中，m（总体平均分）是"先验概率"，每一次新的投票都是一个调整因子，使总体平均分不断向该项目的真实投票结果靠近。

[Bayesian average]: https://chart.googleapis.com/chart?cht=tx&chl=%5Cbar%7Bx%7D%3D%5Cfrac%7BC%5Ctimes%20m%2B%5CSigma%20%5E%7Bn%7D_%7Bi%3D1%7Dx_%7Bi%7D%7D%7Bn%2BC%7D&chs=80

## 周期top K
比如最近一个小时的top K.
1. 建一张长度为：sorted sets, 其中最早发表的post 时间被定义为f0, 最小score为score0
2. 当某篇post score 变化时：
    1. 如果f0 超期，就直接删除，并加入post, 并更新f0
    2. 如果大于score0, 就直接删除，并加入post, 并更新score0

## Preference
[阮一峰:投票算法]

[Wilson_mean]: https://chart.googleapis.com/chart?cht=tx&chl=%5Cfrac%7B%5Chat%7Bp%7D%2B%5Cfrac%7B1%7D%7B2n%7Dz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%7D%7B1%2B%5Cfrac%7B1%7D%7Bn%7Dz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%7D&chs=100

[Wilson_lower]: https://chart.googleapis.com/chart?cht=tx&chl=%5Cfrac%7B%5Chat%7Bp%7D%2B%5Cfrac%7B1%7D%7B2n%7Dz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D-z_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%5Csqrt%7B%5Cfrac%7B%5Chat%7Bp%7D(1-%5Chat%7Bp%7D)%7D%7Bn%7D%2B%5Cfrac%7Bz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%7D%7B4n%5E%7B2%7D%7D%7D%7D%7B1%2B%5Cfrac%7B1%7D%7Bn%7Dz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%7D&chs=150

[Wilson_score_interval]: https://chart.googleapis.com/chart?cht=tx&chl=%5Cfrac%7B%5Chat%7Bp%7D%2B%5Cfrac%7B1%7D%7B2n%7Dz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%5Cpm%20z_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%5Csqrt%7B%5Cfrac%7B%5Chat%7Bp%7D(1-%5Chat%7Bp%7D)%7D%7Bn%7D%2B%5Cfrac%7Bz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%7D%7B4n%5E%7B2%7D%7D%7D%7D%7B1%2B%5Cfrac%7B1%7D%7Bn%7Dz%5E%7B2%7D_%7B1-%5Cfrac%7B%5Calpha%7D%7B2%7D%7D%7D&chs=180

[P]: https://chart.googleapis.com/chart?cht=tx&chl=%5Chat%7Bp%7D&chs=20

[z_(1-a/2)]: https://chart.googleapis.com/chart?cht=tx&chl=z_%7B1-%5Calpha%2F2%7D&chs=25

[阮一峰:投票算法]: 
http://www.ruanyifeng.com/blog/2012/03/ranking_algorithm_newton_s_law_of_cooling.html