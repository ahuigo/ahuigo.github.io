---
title: py gui pyqt
date: 2022-01-17
private: true
---
# py gui 
Python支持多种图形界面的第三方库，包括：

1. Tk 自带
1. wxWidgets
1. Qt 超级跨平台(推荐)
1. GTK
1. pysimplegui: https://opensource.com/article/18/8/pysimplegui


# pyqt hello world
    import sys
    from PyQt5.QtWidgets import QApplication, QWidget, QLabel
    from PyQt5.QtGui import QIcon
    from PyQt5.QtCore import pyqtSlot

    def window():
       app = QApplication(sys.argv)
       widget = QWidget()

       textLabel = QLabel(widget)
       textLabel.setText("Hello World!")
       textLabel.move(110,85)

       widget.setGeometry(50,50,320,200)
       widget.setWindowTitle("PyQt5 Example")
       widget.show()
       sys.exit(app.exec_())

    if __name__ == '__main__':
       window()