---
title: matplotlib
date: 2018-10-04
---
# matplotlib

> 原文:
http://www.labri.fr/perso/nrougier/teaching/matplotlib/
> 译文:
http://liam0205.me/2014/09/11/matplotlib-tutorial-zh-cn/

    ipython --matplotlib

When we start it with the command line argument -pylab (--pylab since IPython version 0.12), it allows interactive matplotlib sessions that have Matlab/Mathematica-like functionality.

    $ ipython --pylab; #  matplotlib 的interactive 版
    1. pylab 默认: 
        import matplotlib.*.*
        from matplotlib import *
        from matplotlib.pyplot import *

        from pylab import *
        import numpy
        import numpy as np
        from numpy import *
        ....
    2. 自动plot.show(), 限命令行
            --pylab
            --matplotlib

### plot
plot any:

    plt.plot([1,2],[1,2])
    plot(['ahui','hilo'], [1,2])

plot sin

    ```python
        $ ipython --matplotlib
    #import numpy as np
    #import matplotlib.pyplot as plt
    from pylab import *

    X = np.linspace(-np.pi, np.pi, 256, endpoint=True)
    C,S = np.cos(X), np.sin(X)

    plt.plot(X,C)
    plt.plot(X,S)

    plt.show()
    ```


### 线条颜色 样式 宽度
添加线条图例legend (label 放到左上)

    plt.plot(X, C, color="blue", linewidth=2.5, linestyle="-", label="cosine")
    plt.plot(X, S, color="red",  linewidth=2.5, linestyle="-", label="sine")
    plt.legend(loc='upper left', frameon=False)

figure output legend at upper left:

    -- cosine
    -- sine

### plot limit 图片边界

    xlim(X.min()-1, X.max()+1)

### annotate, 注释
在 2π/3 的位置上画一个点；然后，向横轴引一条垂线，以虚线标记；最后，写上标签。

    t = 2*np.pi/3
    plt.plot([t,t],[0,np.cos(t)], color ='blue', linewidth=1.5, linestyle="--")
    plt.scatter([t,],[np.cos(t),], 50, color ='blue') # size=50

    plt.annotate(r'$\sin(\frac{2\pi}{3})=\frac{\sqrt{3}}{2}$',
                 xy=(t, np.sin(t)), # 位置
                 xytext=(+10, +30), textcoords='offset points', fontsize=16, # 右上角依稀
                 arrowprops=dict(arrowstyle="->", connectionstyle="arc3,rad=.2")) # 注释形状

Annotation: http://matplotlib.org/1.5.1/users/annotations_intro.html

    textcoords='data' # 数据位置
        offset points # 点偏移
        offset pixels

### text 标注数据
按数据的位置：

    plt.text(-0.01, -0.01, '中国', ha='right', va= 'bottom')

### title

    plt.title('Center Title')
    plt.title('Left Title', loc='left')
    ax.set_title('xxx')

# Figures, Subplots, Axes and Ticks
Figures 是一个画布，一个figure 可包括多个subplot, 一个subplot默认一个坐标axis(但可以装多个axes)
- subplot 是一个子图, 将画布分成多块子画布. 
- axes, 坐标轴和子图功能类似，不过它可以放在图像的任意位置。因此，如果你希望在一副图中绘制一个小图，就可以用这个功能。

## Figures
f = figure(figsize=(8,6), dpi=80)

    Argument	Default	Description
    num	1	number of figure
    figsize	figure.figsize	figure size in in inches (width, height)
    dpi	figure.dpi	resolution in dots per inch
    facecolor	figure.facecolor	color of the drawing background
    edgecolor	figure.edgecolor	color of edge around the drawing background
    frameon	True	draw figure frame or not

close figure:

    close(f)
    close(); # current figure

将figure 分成两个subplot:

    fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(9, 4))

## subplot

    ```python
    subplot(1,1,1)
    # subplot(2,3,2); # 选择2*3=6块中的第二块

    # 以分辨率 72 来保存图片
    savefig("exercice_2.png",dpi=72)
    ```

## Axes, 坐标轴
(0.3,0.3) 是偏移, (.5,.5) 是宽长(单位是0-1), 

    # 选择一个坐标轴
    plt.axes([left,bottom,width,heigh])
    plt.axes([0.5,0.5,.5,.5]), 右上角
    plt.axes([0,0,.5,.5]), 左下角

## ticks,记号

    xticks( [-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
    yticks([-1, 0,0.5, +1])

![python-chart-matplot-1.png](/img/python-chart-matplot-1.png)

### 记号的标签
第二个参数就是标签, 常用于date+latex

    plt.xticks([-np.pi, -np.pi/2, 0, np.pi/2, np.pi],
           [r'$-\pi$', r'$-\pi/2$', r'$0$', r'$+\pi/2$', r'$+\pi$'])

    plt.yticks([-1, 0, +1],
           [r'$-1$', r'$0$', r'$+1$'])

说明:

    $\pi$ 会被识别latex 表达式

xticks与label 可一起设置：

    plt.setp(axes, xticks=[1,2,3,4], xticklabels=['x1', 'x2', 'x3', 'x4'])
    plt.setp(plt.gca(), xticks=[1,2,3,4], xticklabels=['x1', 'x2', 'x3', 'x4'])

##### Date ticks
http://stackoverflow.com/questions/14440171/matplotlib-x-axis-ticks-dates-formatting-and-locations
doc for AutoDateFormatter

    from pylab import *
    import matplotlib.dates as mdates
    from datetime import datetime, timedelta

    # datetime.strptime('12/31/1991 10:21','%m/%d/%Y %H:%M')
    X = [datetime.now() + timedelta(minutes=2) * j for j in range(500)]
    Y = range(500)

    ax = plt.gca() # get the current axes
    ax.fill_between(X, 0, Y, color='#4695da', alpha=0.5)

    xax = ax.get_xaxis() # get the x-axis
    xax.set_major_formatter(mdates.DateFormatter('%m/%d %H:%M:%S'))

    plt.gcf().autofmt_xdate() # 自动控制xdate的位置，否则可能重叠
    show()
    # 以下是默认的
    # adf = xax.get_major_formatter() # the the auto-formatter
    # adf.scaled[1./24] = '%H:%M'  # set the < 1d scale to H:M
    # adf.scaled[1.0] = '%Y-%m-%d' # set the > 1d < 1m scale to Y-m-d
    # adf.scaled[30.] = '%Y-%m' # set the > 1m < 1Y scale to Y-m
    # adf.scaled[365.] = '%Y' # set the > 1y scale to Y

其它设置，使用date tick

    ax.xaxis_date()


#### 记号: 字体大小、颜色、alpha透明...

    for label in ax.get_xticklabels() + ax.get_yticklabels():
        label.set_fontsize(16)
        label.set_bbox(dict(facecolor='white', edgecolor='None', alpha=0.65 ))

## locator
locator 代表了切割的尺度，如果数据点太多显示不全label，那么横坐标切割尺度要大
去掉坐标

    ax=plt.gca()
    ax.xaxis.set_major_locator(plt.NullLocator())

### date locator

    from matplotlib.dates import DateFormatter, WeekdayLocator,DayLocator, MONDAY
    mondays = WeekdayLocator(MONDAY)        # major ticks on the mondays
    alldays = DayLocator()              # minor ticks on the days
    weekFormatter = DateFormatter('%b %d')  # e.g., Jan 12
    dayFormatter = DateFormatter('%d')      # e.g., 12

    ax.xaxis.set_major_locator(mondays)
    ax.xaxis.set_major_formatter(weekFormatter)
    ax.xaxis.set_minor_locator(alldays)
    # ax.xaxis.set_minor_formatter(dayFormatter) 小尺度不加label, 重叠看不清

### move spines, 移动脊柱坐标
we'll discard the top and right by setting their color to none and we'll move the bottom and left ones to coordinate 0 in data space coordinates.

    ...
    ax = plt.gca() # 获取坐标对象
    # 右上坐标消失
    ax.spines['right'].set_color('none')
    ax.spines['top'].set_color('none')

    # 移动坐标到数据为0处
    ax.spines['bottom'].set_position(('data',0))
    ax.spines['left'].set_position(('data',0))

    # 设定记号位置
    ax.xaxis.set_ticks_position('bottom')
    ax.yaxis.set_ticks_position('left')

![python-chart-matplot-2.png](/img/python-chart-matplot-2.png)

# shape
- plot 线
- fill_between 面
- bar 条
- scatter 点

## fill_between

    import numpy as np
    import matplotlib.pyplot as plt

    X = np.linspace(-np.pi,np.pi,256,endpoint=True)
    Y = np.sin(2*X)

    plt.plot(X, Y+1, color='blue', alpha=1.00)
    # 1与Y+1之间
    plt.fill_between(X, 1, Y+1, color='blue', alpha=.25)

    plt.plot(X, Y-1, color='blue', alpha=1.00)
    # -1与Y-1之间，且Y-1在-1之上时
    plt.fill_between(X, -1, Y-1, (Y-1) > -1, color='blue', alpha=.25)
    plt.fill_between(X, -1, Y-1, (Y-1) < -1, color='red',  alpha=.25)

    plt.show()

![python-chart-matplot-4.png](/img/python-chart-matplot-4.png)

    plt.fill_between(X, Y_from, Y_to, [Y_limit,] color='blue', alpha=1.00)

## bar, 条形

    import numpy as np
    import matplotlib.pyplot as plt

    n = 12
    X = np.arange(n)
    Y1 = (1-X/float(n)) * np.random.uniform(0.5,1.0,n)
    plt.bar(X, +Y1, facecolor='#9999ff', edgecolor='white')

    for x,y in zip(X,Y1):
        plt.text(x+0.4, y+0.05, '%.2f' % y, ha='center', va= 'bottom')

    plt.ylim(-1.25,+1.25)
    plt.show()

## point:scatter, 画点

    n = 1024
    X = np.random.normal(0,1,n)
    Y = np.random.normal(0,1,n)
    scatter(X,Y)
    scatter([t,],[np.cos(t),], 50, color ='blue') # size=50

## pie, 饼图

    pie([1,2,3,4])

## rectangle
    plt.gca().add_patch(
        plt.Rectangle( 
            (0.1, 0.1),   # (x,y)
            0.5,          # width
            0.5,          # height
            facecolor='orange', edgecolor='blue'
        )
    )

## boxplot
box plots show data points outside 1.5 

    all_data = [np.random.normal(0, std, 100) for std in range(6, 10)]
    plt.gca().boxplot(all_data)

    plt.gca().boxplot([[1,2,3,4,2],[0,1,5,6,2]])

## more charts
http://matplotlib.org/gallery.html#lines_bars_and_markers

## save
show() 后会清数据..

    plt.savefig('foo.png')

whitespace around the image. Remove it with:

    savefig('foo.png', bbox_inches='tight')