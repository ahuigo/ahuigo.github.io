---
layout: page
title: py-gui
category: blog
description: 
date: 2018-09-28
---
# Preface
Python支持多种图形界面的第三方库，包括：

1. Tk 自带
1. wxWidgets
1. Qt 超级跨平台
1. GTK
1. pysimplegui: https://opensource.com/article/18/8/pysimplegui

但是Python自带的库是支持Tk的Tkinter，使用Tkinter，无需安装任何包，就可以直接使用。本章简单介绍如何使用Tkinter进行GUI编程。

# turtle
tree:

    import turtle
    def tree(branchLen,t):
        if branchLen > 5:
            t.forward(branchLen)
            t.right(20)
            tree(branchLen-15,t)
            t.left(40)
            tree(branchLen-15,t)
            t.right(20)
            t.backward(branchLen)

    def main():
        t = turtle.Turtle()
        myWin = turtle.Screen()
        t.left(90)
        t.up()
        t.backward(100)
        t.down()
        t.color("green")
        tree(75,t)
        myWin.exitonclick()

triangle:

    def drawTriangle(points,color,myTurtle):
        myTurtle.fillcolor(color)
        myTurtle.up()
        myTurtle.goto(points[0][0],points[0][1])
        myTurtle.down()
        myTurtle.begin_fill()
        myTurtle.goto(points[1][0],points[1][1])
        myTurtle.goto(points[2][0],points[2][1])
        myTurtle.goto(points[0][0],points[0][1])
        myTurtle.end_fill()

# Tkinter
我们来梳理一下概念：

1. 我们编写的Python代码会调用内置的Tkinter，Tkinter封装了访问Tk的接口；
2. Tk是一个图形库，支持多个操作系统，使用Tcl语言开发；
2. Tk会调用操作系统提供的本地GUI接口，完成最终的GUI。

所以，我们的代码只需要调用Tkinter提供的接口就可以了。

## 第一个GUI程序
使用Tkinter十分简单，我们来编写一个GUI版本的“Hello, world!”。


第1二步是从Frame派生一个Application类，这是所有Widget的父容器：

	from tkinter import *
	class Application(Frame):
		def __init__(self, master=None):
			Frame.__init__(self, master)
			self.pack()
			self.createWidgets()

		def createWidgets(self):
			self.helloLabel = Label(self, text='Hello, world!')
			self.helloLabel.pack()
			self.quitButton = Button(self, text='Quit', command=self.quit)
			self.quitButton.pack()

在GUI中，每个Button、Label、输入框等，都是一个Widget。

1. Frame则是可以容纳其他Widget的Widget，所有的Widget组合起来就是一棵树。
2. pack()方法把Widget加入到父容器中，并实现布局。
3. pack()是最简单的布局，grid()可以实现更复杂的布局。
4. 在createWidgets()方法中，我们创建一个Label和一个Button，当Button被点击时，触发self.quit()使程序退出。

第三步，实例化Application，并启动消息循环：

	app = Application()
	# 设置窗口标题:
	app.master.title('Hello World')
	# 主消息循环:
	app.mainloop()

GUI程序的主线程负责监听来自操作系统的消息，并依次处理每一条消息。因此，如果消息处理非常耗时，就需要在新线程中处理。

## 输入文本

我们再对这个GUI程序改进一下，加入一个文本框，让用户可以输入文本，然后点按钮后，弹出消息对话框。

	from tkinter import *
	import tkinter.messagebox as messagebox

	class Application(Frame):
		def __init__(self, master=None):
			Frame.__init__(self, master)
			self.pack()
			self.createWidgets()

		def createWidgets(self):
			self.nameInput = Entry(self)
			self.nameInput.pack()
			self.alertButton = Button(self, text='Hello', command=self.hello)
			self.alertButton.pack()

		def hello(self):
			name = self.nameInput.get() or 'world'
			messagebox.showinfo('Message', 'Hello, %s' % name)

	app = Application()
	# 设置窗口标题:
	app.master.title('Hello World')
	# 主消息循环:
	app.mainloop()

当用户点击按钮时，触发hello()，通过self.nameInput.get()获得用户输入的文本后，使用tkMessageBox.showinfo()可以弹出消息对话框。