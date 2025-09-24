import random
class Node:
    """SkipList 节点：包含 key 和多级 forward 指针"""
    def __init__(self, key, level):
        self.key = key
        # forward[i] 指向该节点在第 i 层的下一个节点
        self.forward = [None] * (level + 1)

class SkipList:
    """SkipList 主类"""
    def __init__(self, max_level=16, p=0.5):
        self.max_level = max_level  # 最大层数
        self.p = p                  # 生成新层的概率
        self.header = Node(None, max_level)
        self.level = 0              # 当前最高层

    def random_level(self):
        """随机生成节点层数"""
        lvl = 0
        while random.random() < self.p and lvl < self.max_level:
            lvl += 1
        return lvl

    def insert(self, key):
        """插入 key（若已存在则忽略）update[i]是i层的header， header.forward[i]是i层下一节点"""
        update = [None] * (self.max_level + 1)
        curr = self.header

        # 从最高层向下，找到每层插入位置的前驱节点
        for i in range(self.level, -1, -1):
            while curr.forward[i] and curr.forward[i].key < key:
                curr = curr.forward[i]
            update[i] = curr

        # 检查是否已存在
        curr = curr.forward[0]
        if curr and curr.key == key:
            return

        # 随机决定新节点的层数
        lvl = self.random_level()
        print(f"\ninsert k:{key}, lvl:{lvl}, self.lvl:{self.level}")
        for i in range(self.level, -1, -1):
            ni = update[i]
            print(f"{i}:{ni.key if ni else None}")
        if lvl > self.level:
            # 更新 header 在更高层的前驱引用为自己
            for i in range(self.level + 1, lvl + 1):
                update[i] = self.header
            self.level = lvl

        # 创建并插入新节点
        node = Node(key, lvl)
        for i in range(lvl + 1):
            node.forward[i] = update[i].forward[i]
            update[i].forward[i] = node
        print("update i=> forward")
        self.dump()

    def dump(self):
        curr = self.header
        for i in range(self.level, -1, -1):
            ls = []
            curr2 = curr.forward[i]
            ls.append(curr2.key if curr2 else None)
            while curr2.forward[i]: 
                curr2 = curr2.forward[i]
                ls.append(curr2.key if curr2 else None)
            print(f"{i}:{ls}")

    def search(self, key):
        """查找 key，找到返回节点，否则返回 None"""
        curr = self.header
        for i in range(self.level, -1, -1):
            while curr.forward[i] and curr.forward[i].key < key:
                curr = curr.forward[i]
        curr = curr.forward[0]
        if curr and curr.key == key:
            return curr
        return None

    def delete(self, key):
        """删除 key（若存在）"""
        update = [None] * (self.max_level + 1)
        curr = self.header

        for i in range(self.level, -1, -1):
            while curr.forward[i] and curr.forward[i].key < key:
                curr = curr.forward[i]
            update[i] = curr

        curr = curr.forward[0]
        if not curr or curr.key != key:
            return  # 不存在，直接返回

        # 删除各层的指针
        for i in range(self.level + 1):
            if update[i].forward[i] != curr:
                break
            update[i].forward[i] = curr.forward[i]

        # 如果最高层已经没有元素，则层数 -1
        while self.level > 0 and not self.header.forward[self.level]:
            self.level -= 1

    def __repr__(self):
        """简易打印 0 层的链表，用于调试"""
        nodes = []
        curr = self.header.forward[0]
        while curr:
            nodes.append(str(curr.key))
            curr = curr.forward[0]
        return "->".join(nodes)

# 演示
if __name__ == "__main__":
    import sys
    skl = SkipList(max_level=4, p=0.5)
    data = [3, 6, 7, 9, 12, 19, 17, 26, 21, 25]

    print("插入数据:", data)
    for x in data:
        skl.insert(x)
    sys.exit()
    print("当前链表（0层）:", skl)

    # 查找
    key = 19
    found = skl.search(key)
    print(f"查找 {key}:", "找到" if found else "未找到")

    # 删除
    skl.delete(19)
    print(f"删除 {key} 后（0层）:", skl)
    print(f"再次查找 {key}:", "找到" if skl.search(key) else "未找到")
