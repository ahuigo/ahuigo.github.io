---
title: 二叉堆
date: 2019-02-11
---
https://github.com/bnmnetp/pythonds/blob/master/trees/binheap.py 给了一个最小堆的例子
1. 插入过程是一个向上冒泡pearUp 的过程
1. 删除过程是一个向上下沉pearDown 的过程

e.g.
```
class BinHeap:
    def __init__(self):
        self.heapList = []
        self.currentSize = 0

    def buildHeap(self,alist):
        self.currentSize = len(alist)
        self.heapList = alist[:]

        i = len(alist)//2 -1
        while (i >= 0):
            self.percDown(i)
            print(i, self.heapList)
            i = i - 1
                        
    def percDown(self,i):
        heapList = self.heapList
        while True:
            child = 2*i+1
            if child >= self.currentSize:
                break
            if child+1<self.currentSize and heapList[child+1] < heapList[child]:
                child += 1
            if heapList[i] > heapList[child]:
                # swap
                heapList[i],heapList[child] = heapList[child],heapList[i] 
            else:
                break
            i = child

    def percUp(self,i):
        heapList = self.heapList
        while (i-1) // 2 >= 0:
            parent = (i-1)//2
            if heapList[i] < heapList[parent]:
                heapList[i], heapList[parent] = heapList[parent],heapList[i]
            else:
                break
            i = parent

    def insert(self,k):
        self.heapList.append(k)
        self.currentSize = self.currentSize + 1
        self.percUp(self.currentSize-1)

    def delMin(self):
        retval = self.heapList[0]
        self.heapList[0] = self.heapList[self.currentSize-1]
        self.currentSize = self.currentSize - 1
        self.heapList.pop()
        self.percDown(0)
        return retval
        
    def isEmpty(self):
        if currentSize == 0:
            return True
        else:
            return False

bh = BinHeap()
bh.insert(5)
bh.insert(7)
bh.insert(3)
bh.insert(11)

print(bh.delMin())
print(bh.delMin())
print(bh.delMin())
print(bh.delMin())
```