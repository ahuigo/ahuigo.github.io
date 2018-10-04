---
layout: page
title: 哪些python lib 让你相见恨晚
category: blog
description:
---
# 哪些python lib 让你相见恨晚
https://www.zhihu.com/question/24590883/answer/119304448
python 资源大全
https://github.com/jobbole/awesome-python-cn

Lightwing 总结的：

1. 基本工具：
    1. ipython: shell 增强
        1. 具有tab补全，对象自省，强大的历史机制，内嵌的源代码编辑，集成Python调试器，%run机制，宏，创建多个环境以及调用系统shell的能力。
        2. sys? 相当于help(sys)
        3. 历史：hist -n
        4. 断点调试: from IPython import embed; embed() # 断点
    2. ipdb（ipython上的debugger，怎么能不用？难道要一直重新运行print某变量？）
    3. ipython notebook（又名jupyter，在线写代码并debug，这东西用了以后就知道自己错过了啥）
        　记住％pylab ... 这命令，这样图片之类的直接显示在网页里
    3. Fabric使用SSH直接登录服务器并执行部署命令（控制多个服务器、方便安装、更改设置、开关某service、等等）
    4. nose、mock、coverage（testing类）

2. 数据处理类：
    1. numpy, 及在numpy 基础上的
        1. pillow/gd（图片数据类，还有不少图片处理功能）
        2. matplotlib（把各种东西简单显示渲染出来）
        3. *pandas*（处理复杂数据、转化或合并数据等等。用了以后就不会再import csv之类的）
        4. scipy（统计类，也不少图片处理、优化等功能）
        5. sklearn（机器学习，好方便）
        （theano、tensorflow ,还有其它的OCR）
        6. nltk、pattern（更多语言处理工具）
        7. pyopencl、pyopengl、pycuda（这些能让numpy做复杂任务更加强更快，利用GPU）
3. 网络类：
    1. requests（python内带的http/url等库很烦人）
    2. aiohttp
    2. django、flask、twisted
    3. pika皮卡丘（不同服务器不同程序之间的沟通大大简化）
        1. pyzmq（也类似，更简单一些，功能比较有限，不过还能直接调用远程python函数－rpc）
    4. sqlalchemy、pymongo、pycouch（还有好多较为方便的数据库累的）
    5. 各种google api
　       1. 特别是appengine、compute engine api，还有maps/places/search api
　       2. 还有谷歌的pipeline、mapreduce之类的、google docs那个编辑远程表格的也不错
    6. 爬虫方面也不少有用的库，比如beautifulsoup、scrapy。
    7. 还有mechanize这种自动控制多个浏览器做事的库，利用浏览器引擎等。

4. 其他：
    1. TK, WX, QT（做界面）
    2. pyglet、pygame、等（更好处理多个界面，各令块渲染，渲染频率，这些）
    3. geopy、shapely、gdal、geos、pyproj（地图处理，可能还有些，早就忘了）
    　但是数据库一定要选择PostGIS
    4. arrow、pendulum（python内带的datetime处理太弱了）
    5. py2exe类（把代码直接编译成executable，所有人能运行）
    6. simplejson（更快）
    7. pyyaml（相对json好写）
    9. tqdm（在命令行显示progress进度，超简单）

# human vs machine
1. requests vs urllib2
2. sh vs subprocess
3. Arrow vs datetime

# Http
[python-http](/p/python-http)

# string
/p/python-str
