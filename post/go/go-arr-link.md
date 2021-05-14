---
title: go link atom
date: 2021-05-14
private: true
---
# go link atom
go 自己的链表：http://xiaorui.cc/archives/2923
demo： 
1. go-lib/link/link-unsafe.go

link基本用法：

    func (e *Element) Next() *Element  //返回该元素的下一个元素，如果没有下一个元素则返回nil
    func (e *Element) Prev() *Element//返回该元素的前一个元素，如果没有前一个元素则返回nil。
    func New() *List //返回一个初始化的list
    func (l *List) Back() *Element //获取list l的最后一个元素
    func (l *List) Front() *Element //获取list l的第一个元素
    func (l *List) Init() *List  //list l初始化或者清除list l
    func (l *List) InsertAfter(v interface{}, mark *Element) *Element  //在list l中元素mark之后插入一个值为v的元素，并返回该元素，如果mark不是list中元素，则list不改变。
    func (l *List) InsertBefore(v interface{}, mark *Element) *Element//在list l中元素mark之前插入一个值为v的元素，并返回该元素，如果mark不是list中元素，则list不改变。
    func (l *List) Len() int //获取list l的长度
    func (l *List) MoveAfter(e, mark *Element)  //将元素e移动到元素mark之后，如果元素e或者mark不属于list l，或者e==mark，则list l不改变。
    func (l *List) MoveBefore(e, mark *Element)//将元素e移动到元素mark之前，如果元素e或者mark不属于list l，或者e==mark，则list l不改变。
    func (l *List) MoveToBack(e *Element)//将元素e移动到list l的末尾，如果e不属于list l，则list不改变。
    func (l *List) MoveToFront(e *Element)//将元素e移动到list l的首部，如果e不属于list l，则list不改变。
    func (l *List) PushBack(v interface{}) *Element//在list l的末尾插入值为v的元素，并返回该元素。
    func (l *List) PushBackList(other *List)//在list l的尾部插入另外一个list，其中l和other可以相等。
    func (l *List) PushFront(v interface{}) *Element//在list l的首部插入值为v的元素，并返回该元素。
    func (l *List) PushFrontList(other *List)//在list l的首部插入另外一个list，其中l和other可以相等。
    func (l *List) Remove(e *Element) interface{}//如果元素e属于list l，将其从list中删除，并返回元素e的值。

但是它是线程不安全的list.

想实现纯程安全的link, 则需要加锁。

## 粗粒度锁
demo: go-lib/link/link-lock.go (线程安全，加锁的)
## 细粒度锁
参考：两种并发安全链表的实现和对比
https://www.cnblogs.com/apocelipes/p/9461405.html
demo: go-lib/link/link-lock-tiny.go (线程安全，加锁的)

# 队列
无锁队列实现
https://zhuanlan.zhihu.com/p/24432607