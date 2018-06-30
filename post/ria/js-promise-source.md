# promise source
promise=defered = $.Defered()

    p = new Promise((resolve,reject)=>
        setTimeout(v=>resolve(v),1,22)     // push eventLoop  callback
    )
    log = v=>console.log(v+1)
    p.then(log);           

    for(i of Array(2000)){console.log(i)}; //线程阻塞，long time run. 线程空闲才会执行eventLoop 中的callback

resolve(v):

    p.memory = v
    if(!p.firing)
        p.fire()

then(rsolveFilter, rejectFilter):

    p['resolve']=resolveFilter
    if(!p.root['reject'])
        p.root['reject']=rejectFilter

    if(p.memory && !p.firing)
        p.fire()

    p.sub_p = new Promise()
    p.sub_p.root = p 
    return sub_p

p.fire():

    p.firing = true
    sub_v = p['resolve'](p.memory)     //call log(v)
    if(p.sub_p){
        sub_p.resolve(sub_v)
    }
    p.firing = false

