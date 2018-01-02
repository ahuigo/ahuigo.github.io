---
layout: page
title:	二叉查找树和红黑树
category: blog
description: 
---
# Preface

二叉查找树（Binary Search Tree），也称二叉搜索树、有序二叉树（ordered binary tree），排序二叉树（sorted binary tree），是指一棵空树或者具有下列性质的二叉树：

- 若任意节点的左子树不空，则左子树上所有结点的值均小于它的根结点的值；
- 任意节点的右子树不空，则右子树上所有结点的值均大于它的根结点的值；
- 任意节点的左、右子树也分别为二叉查找树。
- 没有键值相等的节点（no duplicate nodes）。

# 特点
1. 中序遍历的结果是有序的
2. 结点是左右子树的中值
3. 查找、插入的时间复杂度较低,为O(log n), (一般是二叉链表, 用数组的话很浪费空间). 作为基础的数据结构，可用于构建更为抽象的数据结构，如集合、multiset、关联数组等。
4. 构造树的过程即为对无序序列进行查找的过程。每次插入的新的结点都是二叉查找树上新的叶子结点，在进行插入操作时，不必移动其它结点，只需改动某个结点的指针，由空变为非空即可。搜索,插入,删除的复杂度等于树高，期望O(log n),最坏O(n)(数列有序,树退化成线性表). 所消耗的空间为O(n).

# 操作

## 查找

### 查找结点
时间复杂度为O(logN), 二叉查找树的最坏效率是O(n),但它支持动态查询,且有很多改进版的二叉查找树可以使树高为O(logn),如SBT,AVL,红黑树等.故不失为一种好的动态查找方法.

### 查找范围(min~max)
1. 先找大于等于min 的最小结点，时间复杂度是`O(logN)`
1. 从找到的结点开始，中序遍历，直到出现大于max 的结点为止，时间复杂度是`O(M)`

总的时间复杂度是: `O(logN + M)` M 为个数

## 插入
结点的插入不需要移动任何数据: 先查找结点，然后再插入结点。	
过程：从root 结点开始，小于结点就找左子树，小于结点就右子树，直到结点没有左/右子树, 就从这个结点左/右插入新的结点

![insert node](/img/binary-search-tree_insert.1.png)
![insert node](/img/binary-search-tree_insert.2.png)
![insert node](/img/binary-search-tree_insert.3.png)
![insert node](/img/binary-search-tree_insert.4.png)

## 删除
删除结点分情况：

1. 如果结点没有子树，则直接删除
1. 如果结点只有右子树或者左子树，左（右）子树 继承父结点后再删除结点
2. 如果结点同时拥有左右子树（双分支），则从左子树中找一个最大值代替此结点，也可以从右子树找一最大值代替此结点。

![del node](/img/binary-search-tree_del.1.png)
![del node](/img/binary-search-tree_del.2.png)
![del node](/img/binary-search-tree_del.3.png)

## 初始化
初始化二叉查找树的过程其实就是插入的过程，平均时间复杂度为`O(N*logN)`, 最坏时间复杂度为`O(N^2)`

# 自平衡二叉查找树
一个大致有序数列初始化为二叉查找树后，查找效率可以坏到`O(N)`, 因为它已经没有*叉*了。有人提出了很多实现自动分叉的*自平衡二叉查找树*, 比如: SBT, AVL, 红黑树。

其中，*红黑树*是在1972年由鲁道夫·贝尔发明的, 在函数式编程中, 它是最常用的持久数据结构之一(Persistent Data Structure)，特别是实现关联数组和集合. 因为这种数据结构每次添加删除搜索都能保持之前的版本，而且的时间复杂度控制在O(logN)

# 红黑树
红黑树规则比较复杂，但它的操作有着良好的最坏情况运行时间，并且在实践中是高效的: 它的每次查找、删除、插入的时间复杂度都是`O(log N)`，删除和插入所需要的空间是`O(logN)`

## 红黑树性质
红黑树是具有以下性质的二叉查找树:

1. 节点是红色或黑色。
2. 根是黑色。
3. 所有叶子都是黑色（叶子是NIL节点）。
4. 每个红色节点必须有两个黑色的子节点。(从每个叶子到根的所有路径上不能有两个连续的红色节点。)
5. 从任一节点到其每个叶子的所有简单路径都包含相同数目的黑色节点。

为什么要对红黑树做以上定义呢？原因是二叉查找树在最坏的情况下，退化成线性的有序链表，此时的查找添加节点的时间复杂度都从`O(logN)` 变成`O(N)`.	
*目标* 和其它的平衡树一样，红黑树的目标就是确保，二叉查找树能达到一种平衡: 通过基于红黑两色的调节机制，尽量把数据分布于多个分支, 避免退化成线性链表
![rb-tree-line](/img/rb-tree-line.png)

上图中，我们可以看到红黑树增加了一种不含数据的nil 结点. 

红黑树确保了 从任一结点到所有nil 的简单路径所包含的黑色结点 数量是相等的(由性质5保证)，而简单路径上的红色结点不能连续(性质4). 这确保了从根到nil 结点的所有简单路径长度不会低于树的深度的一半。也就是说，包含n个结点的RB-TREE 是最大深度为2*log(N). 
所以通过性质4+5，保证了红黑树的查找时间复杂度是`O(logN)`.

## 红黑树基本操作
红黑树作为二叉查找平衡树(BST)的一种，具备二叉树的所有性质. 查找过程和BST 是一样的。不过，红黑树(RBT) 在做插入和删除操作时，会做进一步的平衡调节，以确保其性质4 或者 5 不会被破坏。

在下面的介绍中，将要插入的节点标为N，N的父节点标为P，N的祖父节点标为G，N的叔父节点标为U。S为兄弟结点


### 插入
插入(red)节点后的平衡调节:

|编号|条件|	操作|调节结束吗|
|情形1| 新节点N位于树的根上(没有父节点)| N->B|结束|
|情形2| N 的P(父)结点是黑色 | 无|结束|
|情形3| N 的P(父)和U(叔)结点是红色 | P->B,U->B,G->R|	可能将N的红色冲突，推到了G(G需要重新判断所有情形)|
|情形4| P是红色,U是黑色或缺少,N是P的右节点 | 对P做左旋 |转换成情况5|
|情形5| P是红色,U是黑色或缺少,N是P的左节点 | 对G做右旋,PG交换颜色 |结束|

其中：N->B, 表示为将N结点改为黑色, 其它结点也采用类似的表示

#### 情形1
新节点N位于树的根上，没有父节点。在这种情形下，我们把它重绘为黑色以满足性质2。因为它在每个路径上对黑节点数目增加一，性质5符合。

	 void insert_case1(node *n) {
		 if (n->parent == NULL)
			 n->color = BLACK;
		 else
			 insert_case2(n);
	 }

#### 情形2
新节点的父节点P是黑色，所以性质4没有失效（新节点是红色的）。在这种情形下，树仍是有效的。性质5也未受到威胁，尽管新节点N有两个黑色叶子子节点；但由于新节点N是红色，通过它的每个子节点的路径就都有同通过它所取代的黑色的叶子的路径同样数目的黑色节点，所以依然满足这个性质。

	void insert_case2(node *n) {
	 if (n->parent->color == BLACK)
		 return; /* 树仍旧有效 */
	 else
		 insert_case3(n);
	}

注意: 在下列情形下我们假定新节点的父节点为红色，所以它有祖父节点；因为如果父节点是根节点，那父节点就应当是黑色。所以新节点总有一个叔父节点，尽管在情形4和5下它可能是叶子节点。

#### 情形3
 如果父节点P和叔父节点U二者都是红色，(此时新插入节点N做为P的左子节点或右子节点都属于情形3,这里右图仅显示N做为P左子的情形)则我们可以将它们两个重绘为黑色并重绘祖父节点G为红色(用来保持性质4)。现在我们的新节点N有了一个黑色的父节点P。因为通过父节点P或叔父节点U的任何路径都必定通过祖父节点G，在这些路径上的黑节点数目没有改变。但是，红色的祖父节点G的父节点也有可能是红色的，这就违反了性质4。为了解决这个问题，我们在祖父节点G上递归地进行情形1的整个过程。（把G当成是新加入的节点进行各种情形的检查）

![rb-tree](/img/rb-tree-insert.3.png)

	void insert_case3(node *n) {
	 if (uncle(n) != NULL && uncle(n)->color == RED) {
		 n->parent->color = BLACK;
		 uncle(n)->color = BLACK;
		 grandparent(n)->color = RED;
		 insert_case1(grandparent(n));
	 }
	 else
		 insert_case4(n);
	}

注意: 在余下的情形下，我们假定父节点P是其父亲G的左子节点。如果它是右子节点，情形4和情形5中的左和右应当对调。

#### 情形4
父节点P是红色而叔父节点U是黑色或缺少，并且新节点N是其父节点P的右子节点而父节点P又是其父节点的左子节点。在这种情形下，我们进行一次左旋转调换新节点和其父节点的角色; 接着，我们按情形5处理以前的父节点P以解决仍然失效的性质4。注意这个改变会导致某些路径通过它们以前不通过的新节点N（比如图中1号叶子节点）或不通过节点P（比如图中3号叶子节点），但由于这两个节点都是红色的，所以性质5仍有效。

![rb-tree](/img/rb-tree-insert.4.png)

	void insert_case4(node *n) {
		if (n == n->parent->right && n->parent == grandparent(n)->left) {
		 rotate_left(n->parent);
		 n = n->left;
		} else if (n == n->parent->left && n->parent == grandparent(n)->right) {
		 rotate_right(n->parent);
		 n = n->right;
		}
		insert_case5(n);
	}

#### 情形5
父节点P是红色而叔父节点U是黑色或缺少，新节点N是其父节点的左子节点，而父节点P又是其父节点G的左子节点。在这种情形下，我们进行针对祖父节点G的一次右旋转; 在旋转产生的树中，以前的父节点P现在是新节点N和以前的祖父节点G的父节点。我们知道以前的祖父节点G是黑色，否则父节点P就不可能是红色(如果P和G都是红色就违反了性质4，所以G必须是黑色)。我们切换以前的父节点P和祖父节点G的颜色，结果的树满足性质4。性质5也仍然保持满足，因为通过这三个节点中任何一个的所有路径以前都通过祖父节点G，现在它们都通过以前的父节点P。在各自的情形下，这都是三个节点中唯一的黑色节点。

![rb-tree](/img/rb-tree-insert.5.png)

	 void insert_case5(node *n) {
		 n->parent->color = BLACK;
		 grandparent(n)->color = RED;
		 if (n == n->parent->left && n->parent == grandparent(n)->left) {
			 rotate_right(grandparent(n));
		 } else {
			 /* Here, n == n->parent->right && n->parent == grandparent(n)->right */
			 rotate_left(grandparent(n));
		 }
	 }

注意插入实际上是原地算法，因为上述所有调用都使用了尾部递归。

### 删除
删除节点处理方法：

|编号|情况|方法|结果|
|编号1|删除节点(D)含两个子树|	从左子树找一个最大值(N), 将N结点数据copy 到D，D的颜色不变|问题变成删除结点N, N结点不含子树|
|编号2|删除节点(D)含最多1个子树, D是红色的| 删除D, 用D的儿子代替D|结束|
|编号3|删除节点(D)含最多1个子树, D是黑色的, D的儿子是红色| 删除D,用D的儿子代替D, 并将儿子改成黑色|结束|
|编号4|删除节点(D)含最多1个子树, D是黑色的, D的儿子是黑色 或者 是空儿子(nil)| 删除D, 用D的儿子代替D|还需要做平衡调节(破坏了规则5)|

	/*
	 * Precondition: n has at most one non-null child.
	 * 本函数只处理编号2,3,4
	 */
	void delete_one_child(struct node *n) {
		struct node *child = is_leaf(n->right) ? n->left : n->right;
 
		replace_node(n, child);
		if (n->color == BLACK) {
			if (child->color == RED)
				child->color = BLACK;
			else
				delete_case1(child);//child 可能是一个空nil 结点
		}
		free(n);
	}


现在需要对编号4的处理结果 做平衡调节:

|编号|条件|	操作|调节结束吗|
|情形1| N是新的根| null |结束|
|情形2| S是红色(P一定是黑色)| 对P做左旋,P与S换颜色(P->R,S->B) | 新的S节点(Sl)转成黑色了, 情况变成情形4、情形5或情形6|
|情形3| S和S的儿子都是黑色的, P是黑色| (N,S)->R |对N的调节结束，对P的调节开始, P作为调节点较N高一度|
|情形4| S和S的儿子都是黑色的, P是红色| (P->B,S->R) |结束|
|情形5| S是黑色，S的左儿子是红色，S的右儿子是黑色，N是左儿子| 对Sl 做左旋, Sl与S换色 |转为情况6:新的Sl是黑，新的Sr是红|
|情形6| S是黑色，S的右儿子是红色，N是左儿子| 对P做左旋,交换P与S(左旋新顶点)的颜色,Sr->R|	结束|


> 当对N调节结束时，如果N是nil 结点，就需要删除nil. 包括情况1,3,4,6

#### 情形1
N是新的根。在这种情形下，我们就做完了。我们从所有路径去除了一个黑色节点，而新根是黑色的，所以性质都保持着。

	void delete_case1(struct node *n) {
		if (n->parent != NULL)
				delete_case2(n);
	}

注意: 在情形2、5和6下，我们假定N是它父亲的左儿子。如果它是右儿子，则在这些情形下的左和右应当对调。

#### 情形2 
S是红色。在这种情形下我们在N的父亲上做左旋转，把红色兄弟转换成N的祖父，我们接着对调N的父亲和祖父的颜色。完成这两个操作后，尽管所有路径上黑色节点的数目没有改变，但现在N有了一个黑色的兄弟和一个红色的父亲（它的新兄弟是黑色因为它是红色S的一个儿子），所以我们可以接下去按情形4、情形5或情形6来处理。
![rb-tree](/img/rb-tree-del.2.png)

	void delete_case2(struct node *n) {
		struct node *s = sibling(n);

		if (s->color == RED) {
			n->parent->color = RED;
			s->color = BLACK;
			if (n == n->parent->left)
				rotate_left(n->parent);
			else
				rotate_right(n->parent);
		} 
		delete_case3(n);
	}


#### 情形3
N的父亲、S和S的儿子都是黑色的。在这种情形下，我们简单的重绘S为红色。结果是通过S的所有路径，它们就是以前不通过N的那些路径，都少了一个黑色节点。因为删除N的初始的父亲使通过N的所有路径少了一个黑色节点，这使事情都平衡了起来。但是，通过P的所有路径现在比不通过P的路径少了一个黑色节点，所以仍然违反性质4。要修正这个问题，我们要从情形1开始，在P上做重新平衡处理。
![rb-tree](/img/rb-tree-del.3.png)

	void delete_case3(struct node *n) {
		struct node *s = sibling(n);

		if ((n->parent->color == BLACK) &&
			(s->color == BLACK) &&
			(s->left->color == BLACK) &&
			(s->right->color == BLACK)) {
				s->color = RED;
				delete_case1(n->parent);
		} else
				delete_case4(n);
	}


#### 情形4
S和S的儿子都是黑色，但是N的父亲是红色。在这种情形下，我们简单的交换N的兄弟和父亲的颜色。这不影响不通过N的路径的黑色节点的数目，但是它在通过N的路径上对黑色节点数目增加了一，添补了在这些路径上删除的黑色节点。
![rb-tree](/img/rb-tree-del.4.png)

	void delete_case4(struct node *n) {
		struct node *s = sibling(n);

		if ((n->parent->color == RED) &&
			(s->color == BLACK) &&
			(s->left->color == BLACK) &&
			(s->right->color == BLACK)) {
				s->color = RED;
				n->parent->color = BLACK;
		} else
				delete_case5(n);
	}

#### 情形5
S是黑色，S的左儿子是红色，S的右儿子是黑色，而N是它父亲的左儿子。在这种情形下我们在S上做右旋转，这样S的左儿子成为S的父亲和N的新兄弟。我们接着交换S和它的新父亲的颜色。所有路径仍有同样数目的黑色节点，但是现在N有了一个右儿子是红色的黑色兄弟，所以我们进入了情形6。N和它的父亲都不受这个变换的影响。

![rb-tree](/img/rb-tree-del.5.png)

	void delete_case5(struct node *n) {
		struct node *s = sibling(n);

		if  (s->color == BLACK) { 
			if ((n == n->parent->left) &&
				(s->right->color == BLACK) &&
				(s->left->color == RED)) { // this last test is trivial too due to cases 2-4.
					s->color = RED;
					s->left->color = BLACK;
					rotate_right(s);
			} else if ((n == n->parent->right) &&
					   (s->left->color == BLACK) &&
					   (s->right->color == RED)) {// this last test is trivial too due to cases 2-4.
					s->color = RED;
					s->right->color = BLACK;
					rotate_left(s);
			}
		}
		delete_case6(n);
	}

#### 情形6
S是黑色，S的右儿子是红色，而N是它父亲的左儿子。在这种情形下我们在N的父亲上做左旋转，这样S成为N的父亲和S的右儿子的父亲。我们接着交换N的父亲和S的颜色，并使S的右儿子为黑色。子树在它的根上的仍是同样的颜色，所以性质3没有被违反。但是，N现在增加了一个黑色祖先: 要么N的父亲变成黑色，要么它是黑色而S被增加为一个黑色祖父。所以，通过N的路径都增加了一个黑色节点。

![rb-tree](/img/rb-tree-del.6.png)

	void delete_case6(struct node *n) {
		struct node *s = sibling(n);

		s->color = n->parent->color;
		n->parent->color = BLACK;

		if (n == n->parent->left) {
				s->right->color = BLACK;
				rotate_left(n->parent);
		} else {
				s->left->color = BLACK;
				rotate_right(n->parent);
		}
	}

同样的，函数调用都使用了尾部递归，所以算法是原地算法。此外，在旋转之后不再做递归调用，所以进行了恒定数目(最多3次)的旋转。

# 参考
- [二叉查找树]
- [红黑树]

[二叉查找树]: http://zh.wikipedia.org/wiki/%E4%BA%8C%E5%85%83%E6%90%9C%E5%B0%8B%E6%A8%B9
[红黑树]: http://zh.wikipedia.org/wiki/%E7%BA%A2%E9%BB%91%E6%A0%91
