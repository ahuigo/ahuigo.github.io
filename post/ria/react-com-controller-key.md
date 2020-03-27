---
title: React 受控组件
date: 2020-03-19
private: 
---
# React 受控组件
1. 当组件被初始化以后，为受控状态：受外部属性值控制
2. 当修改dom时，组件会变成非受控组件: 不受外部属性值控制
   1. key变化时，会初始化组件useState，销毁旧组件:
      1. 每个组件都有一个key, 这个key可手动指定，否则是react自动在parse AST时生成(对于数组来说，默认key基于array index，此时会遇到更新bug)

eg:key变化时，会初始化组件useState，销毁旧组件

    import React,{useState} from 'react';
    const Div=({v})=>{
        let dom;
        console.log(v,'=>Div')
        return <div 
            // key={v}
            ref={(node)=>{
                if(node){
                    dom=node
                }
            } } onClick={()=>{
                dom.innerHTML='变成非受控组件：'+`v=${v},`+Math.random()
                console.log(dom)
            }}>v:{v}</div>
    }
    const DnamicNode=({v, setV})=>{
        console.log(v)
    return <div>
            <input
            key={v}
            defaultValue={v} onKeyUp={(e:React.KeyboardEvent)=>{
                    if(e.key==='Enter'){
                        const v = e.target.value;
                        setV(v)
                    }
            }}/>

        </div>};
    export default (): React.ReactNode => {
        const [v, setV] = useState('')
        const reset = ()=>{
            setV('')
        }
        const props ={v, setV}

        return <div>
            <div onClick={reset}>rese value:{v}</div>
            {/* {DnamicNode({v, setV})} */}
            {/* <DnamicNode {...props}/> */}
            <DnamicNode  {...props}/>
            <DnamicNode  {...props}/>
            <DnamicNode  {...props}/>
            <DnamicNode  {...props}/>
            <Div v={v} />
            {/* <DnamicNode key={'b'} {...props}/>
            <DnamicNode key={'c'} {...props}/>
            <DnamicNode key={'d'} {...props}/> */}
        </div>
    }

ref改变时，生成新组件，同时销毁旧组件，继续受外部属性值控制:

下面的例子表明，key变化时，会初始化组件

    import React,{useState, useEffect} from 'react';
    const DnamicNode=({v})=>{
        const i = useState(Math.random())[0]
        useEffect(()=>{
            return ()=>console.log('destruct',i)
        },[])
        return <div>{v},inner={i} </div>
    };
    export default (): React.ReactNode => {
        const [v, setV] = useState(0)
        return <div>
            <div onClick={()=>setV(v+1)}>rese value:{v}</div>
            <DnamicNode key={v} v={v}/>
        </div>
    }
