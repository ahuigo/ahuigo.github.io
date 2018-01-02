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

        import numpy
        import numpy as np
        from numpy import *
        ....
    2. pylab 自动plot.show()

### plot sin
```
    $ ipython --matplotlib
import numpy as np
import matplotlib.pyplot as plt

X = np.linspace(-np.pi, np.pi, 256, endpoint=True)
C,S = np.cos(X), np.sin(X)

plt.plot(X,C)
plt.plot(X,S)

plt.show()
```

### Instantiating defaults, 默认设置

```
# 导入 matplotlib 的所有内容（nympy 可以用 np 这个名字来使用）
from pylab import *

# 创建并激活一个 8 * 6 点（point）的figure图，并设置分辨率为 80
figure(figsize=(8,6), dpi=80)

# 创建一个新的 1 * 1 的子图，接下来的图样绘制在其中的第 1 块（也是唯一的一块）
subplot(1,1,1)
# subplot(2,3,2); # 选择2*3=6块中的第二块

X = np.linspace(-np.pi, np.pi, 256,endpoint=True)
C,S = np.cos(X), np.sin(X)

# 绘制余弦曲线，使用蓝色的、连续的、宽度为 1 （像素）的线条
plot(X, C, color="blue", linewidth=1.0, linestyle="-")

# 绘制正弦曲线，使用绿色的、连续的、宽度为 1 （像素）的线条
plot(X, S, color="green", linewidth=1.0, linestyle="-")

# 设置横轴的上下限
xlim(-4.0,4.0)

# 设置横轴记号
xticks(np.linspace(-4,4,9,endpoint=True))
xticks(np.linspace(-4,4,8,endpoint=False))

# 设置纵轴的上下限
ylim(-1.0,1.0)

# 设置纵轴记号
yticks(np.linspace(-1,1,5,endpoint=True))

# 以分辨率 72 来保存图片
# savefig("exercice_2.png",dpi=72)

# 在屏幕上显示
show()

# move spines
ax = plt.gca()
ax.spines['right'].set_color('none')
ax.spines['top'].set_color('none')
ax.xaxis.set_ticks_position('bottom')
ax.spines['bottom'].set_position(('data',0))
ax.yaxis.set_ticks_position('left')
ax.spines['left'].set_position(('data',0))

```

### 修改颜色 样式
```
plot(X, C, color="blue", linewidth=2.5, linestyle="-")
```

### plot limit 图片边界

    xlim(X.min()*1.1, X.max()*1.1)

### plot tick,记号

    xticks( [-np.pi, -np.pi/2, 0, np.pi/2, np.pi])
    yticks([-1, 0,0.5, +1])

![python-chart-matplot-1.png](/img/python-chart-matplot-1.png)

### plot tick lables

    plt.xticks([-np.pi, -np.pi/2, 0, np.pi/2, np.pi],
           [r'$-\pi$', r'$-\pi/2$', r'$0$', r'$+\pi/2$', r'$+\pi$'])

    plt.yticks([-1, 0, +1],
           [r'$-1$', r'$0$', r'$+1$'])

#### label in detail

    for label in ax.get_xticklabels() + ax.get_yticklabels():
        label.set_fontsize(16)
        label.set_bbox(dict(facecolor='white', edgecolor='None', alpha=0.65 ))

### move spines
we'll discard the top and right by setting their color to none and we'll move the bottom and left ones to coordinate 0 in data space coordinates.

    ...
    ax = plt.gca()
    ax.spines['right'].set_color('none')
    ax.spines['top'].set_color('none')
    ax.xaxis.set_ticks_position('bottom')
    ax.spines['bottom'].set_position(('data',0))
    ax.yaxis.set_ticks_position('left')
    ax.spines['left'].set_position(('data',0))

![python-chart-matplot-2.png](/img/python-chart-matplot-2.png)

### Adding a legend

    plt.plot(X, C, color="blue", linewidth=2.5, linestyle="-", label="cosine")
    plt.plot(X, S, color="red",  linewidth=2.5, linestyle="-", label="sine")

    plt.legend(loc='upper left', frameon=False)

figure output at upper left:

    -- cosine
    -- sine

### Annotate some points
use plt.scatter, plt.scatter

    t = 2*np.pi/3
    plt.plot([t,t],[0,np.cos(t)], color ='blue', linewidth=1.5, linestyle="--")
    plt.scatter([t,],[np.cos(t),], 50, color ='blue')

    plt.annotate(r'$\sin(\frac{2\pi}{3})=\frac{\sqrt{3}}{2}$',
                 xy=(t, np.sin(t)), xycoords='data',
                 xytext=(+10, +30), textcoords='offset points', fontsize=16,
                 arrowprops=dict(arrowstyle="->", connectionstyle="arc3,rad=.2"))

    plt.plot([t,t],[0,np.sin(t)], color ='red', linewidth=1.5, linestyle="--")
    plt.scatter([t,],[np.sin(t),], 50, color ='red'); # 圆点

    plt.annotate(r'$\cos(\frac{2\pi}{3})=-\frac{1}{2}$',
                 xy=(t, np.cos(t)), xycoords='data',
                 xytext=(-90, -50), textcoords='offset points', fontsize=16,
                 arrowprops=dict(arrowstyle="->", connectionstyle="arc3,rad=.2"))
    ...

Annotation: http://matplotlib.org/1.5.1/users/annotations_intro.html

    textcoords='data'
        offset points
        offset pixels

### title

    plt.title('Center Title')
    plt.title('Left Title', loc='left')

## Figures, Subplots, Axes and Ticks

### Figures
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

### Axes
(0.3,0.3) 是偏移, (.5,.5) 是长宽

    plt.axes([0.3,0.3,.5,.5])

### Ticks
#### Tick Locators
There are several locators for different kind of requirements:

    NullLocator
        No ticks.
    IndexLocator
        Place a tick on every multiple of some base number of points plotted.

    FixedLocator
        Tick locations are fixed.

    LinearLocator
        Determine the tick locations.

    MultipleLocator
        Set a tick on every integer that is multiple of some base.

    AutoLocator
        Select no more than n intervals at nice locations.

    LogLocator
        Determine the tick locations for log axes.

All of these locators derive from the base class `matplotlib.ticker.Locator`. You can make your own locator deriving from it.

#### date ticks
http://stackoverflow.com/questions/14440171/matplotlib-x-axis-ticks-dates-formatting-and-locations
doc for AutoDateFormatter

    from pylab import *
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    import datetime

    d = datetime.timedelta(minutes=2)
    now =  datetime.datetime.now()
    times = [now + d * j for j in range(500)]
    ax = plt.gca() # get the current axes
    Y = range(500)
    X = times

    # X = np.array(X); # ok
    # Y = np.array(Y); # ok
    # plt.fill_between; # ok
    ax.fill_between(X, 0, Y, color='#4695da', alpha=0.5)
    ax.plot(X, Y)
    print(X,Y)

    xax = ax.get_xaxis() # get the x-axis
    adf = xax.get_major_formatter() # the the auto-formatter
    xax.set_major_formatter(mdates.DateFormatter('%H:%M'))
    # adf.scaled[1./24] = '%H:%M'  # set the < 1d scale to H:M
    # adf.scaled[1.0] = '%Y-%m-%d' # set the > 1d < 1m scale to Y-m-d
    # adf.scaled[30.] = '%Y-%m' # set the > 1m < 1Y scale to Y-m
    # adf.scaled[365.] = '%Y' # set the > 1y scale to Y

    plt.draw()
    show()

#### with date locator

    import datetime as dt
    dates = ['01/02/1991 10:21','01/02/1991 10:22','01/02/1991 10:23']
    x = [dt.datetime.strptime(d,'%m/%d/%Y %H:%M') for d in dates]
    y = [2,1,2] # many thanks to Kyss Tao for setting me straight here

    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates

    plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%m/%d %H:%M:%S'))
    plt.gca().xaxis.set_major_locator(mdates.MinuteLocator())
    plt.plot(x,y)
    plt.gcf().autofmt_xdate()

# shape

## line fill

    import numpy as np
    import matplotlib.pyplot as plt

    n = 256
    X = np.linspace(-np.pi,np.pi,n,endpoint=True)
    Y = np.sin(2*X)

    plt.axes([0.025,0.025,0.95,0.95])

    plt.plot(X, Y+1, color='blue', alpha=1.00)
    plt.fill_between(X, 1, Y+1, color='blue', alpha=.25)

    plt.plot(X, Y-1, color='blue', alpha=1.00)
    plt.fill_between(X, -1, Y-1, (Y-1) > -1, color='blue', alpha=.25)
    plt.fill_between(X, -1, Y-1, (Y-1) < -1, color='red',  alpha=.25)

    plt.xlim(-np.pi,np.pi), plt.xticks([])
    plt.ylim(-2.5,2.5), plt.yticks([])
    plt.show()

![python-chart-matplot-4.png](/img/python-chart-matplot-4.png)

        plt.fill_between(X, Y_from, Y_to, [Y_limit,] color='blue', alpha=1.00)

np.array()

    X = np.array()

## bar

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

## more charts
http://matplotlib.org/gallery.html#lines_bars_and_markers

## save
show() 后会清数据..

    plt.savefig('foo.png')

whitespace around the image. Remove it with:

    savefig('foo.png', bbox_inches='tight')
