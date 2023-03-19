---
title: css height 100% not work
date: 2023-03-16
private: true
---
# position
只有 static 元素它不会被“positioned”

	Inherited: no
	position:
		static; 默认(left/top 不生效, 不会被“positioned”)
		relative; 相对本元素static 的偏移, 会占用父元素的位置
            不会影响别的兄弟节点
		absolute; 相对于父级“positioned”祖先元素的偏移, 如果没有则以当前视窗为基准
            不占用位置，兄弟节点会填补位置，用z-index:-1 不会遮蔽 

		fixed; 以整个视窗为基准,不受鼠标滚动影响

		relative/absolute以parent positioned 结点为基准
            没有positioned 的话，则以: window.innerWidth/innerHeight (viewport)为基准
