---
title: Js 的并行，并发
date: 2019-04-27
---
# Js 的并行并发
Js 的并行支持可以用worker 来搞定，但是有一些限制：

    var promises = [obj1, obj2].map(function(obj){
    return db.query('obj1.id').then(function(results){
        obj1.rows = results
        return obj1
    })
    })
    Promise.all(promises).then(function(results) {
        console.log(results)
    })
