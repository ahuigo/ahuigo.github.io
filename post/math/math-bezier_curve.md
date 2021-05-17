---
layout: page
title: math-bezier_curve
category: blog
private:
date: 2018-09-27
---
# Preface

Bézier_curve 贝塞尔曲线

https://zh.wikipedia.org/wiki/%E8%B2%9D%E8%8C%B2%E6%9B%B2%E7%B7%9A

2点确定一个点(随着t变化)

	<img class="mwe-math-fallback-image-inline tex" alt="\mathbf{B}(t)=\mathbf{P}_0 + (\mathbf{P}_1-\mathbf{P}_0)t=(1-t)\mathbf{P}_0 + t\mathbf{P}_1 \mbox{ , } t \in [0,1]" src="//upload.wikimedia.org/math/0/5/c/05c4210c69ffb1358ceb8eb83a1a06fe.png">

3点确定2个点

4点确定3个点


## 实现：

    function factorial(n, s = 1) {
        while (n > 1) s *= n--;
        return s;
    }
    function combinations(n,i){
        let s = 1;
        let r = i;
        while(r<n) s*=++r;
        return s/factorial(n-i)
    }
    /**
     * @param nodes，曲线关键点
     * @param n，曲线虚拟点数
     **/
    function getBezierCurve3DPoints(nodes, n=100){
        const points = [];
        for(let t=0; t<=1; t+=1/n){
            nodesLength = nodes.length
            const point = [0,0,0];
            for(let i=0; i<nodes.length; i++){
                const node =nodes[i];
                point[0] += combinations(n,i)* ((1-t)**(n-i)) * (t**i) * node[0];
                point[1] += combinations(n,i)* ((1-t)**(n-i)) * (t**i) * node[1];
                point[2] += combinations(n,i)* ((1-t)**(n-i)) * (t**i) * node[2];
            }
            points.push(point)
        }
        return points;
    }

    // test
    const p0 = [0,100,0]
    const p1 = [0,50,0]
    const p2 = [50,0,0]
    const p3 = [100,0,0]

    const res = (getBezierCurve3DPoints([p0,p1,p2,p3],100))
    for(let r of res){
        console.log(r)
    }
