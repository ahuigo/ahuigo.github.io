# Data tool
作者：关丹辉
链接：https://www.zhihu.com/question/20408598/answer/25751602

## python下的数据分析模块
1. pandas：依赖numpy和sciepy(learn matplotlib to customize)，主要用于数据分析，数据预处理以及基本的作图，不涉及复杂的模型。
2. statsmodels：统计包，设计各种统计模型，包括回归、广义回归、假设检验等，结果类似于R语言，会给出各种检验结果。
3. numpy和scipy: 提供各种向量矩阵计算、优化、随机数生成等等。

以上都是一些包，如果是分析环境的话，可以考虑spyder和ipython notebook——其中ipython notebook 是可以把代码、结果以及报告同时结合在一起的东西——类似于R语言的Rmarkdown。

## python的数据可视化
1. 最常用的matplotlib，用于科学制图——基础的绘图，已经集成在pandas里。
2. 此外，ggplot2在R语言下的绘图神器，也同时支持python的哟，非常推荐。
3. python-highcharts
4. Seaborn(base matplotlib): more complex visualization approaches
5. bokeh: is a robust tool if you want to set up your own visualization server but may be overkill for the simple scenarios.
6. Plotly generates the most interactive graphs.

## 数据存储
1. 一般用数据库吧。
2. 简单, 用cPickle直接把数据保存成文本，下次使用直接load就可以。
3. 此外，python是内置了spqlite3数据库的，可以直接使用。

对于复杂的数据，可以使用数据库接口——各种的，包括hadoop。

# ipython
0. ipython: python shell
1. ipython notebook， 新名字是Jupyter notebook: 基于 IPython REPL 的 web 应用
