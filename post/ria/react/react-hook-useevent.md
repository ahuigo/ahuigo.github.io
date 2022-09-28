---
title: react hook useEvent
date: 2022-06-28
private: true
---
# react hook useEvent
> refer: https://zhuanlan.zhihu.com/p/514751791
useEvent 本质就是：
1. 利用useRef 存储更新fn
1. 利用useLayoutEffect 保持引用不变性

e.g

     // ✅ Always the same function (even if `text` changes)
     const onClick = useEvent(() => {
        sendMessage(text);
     });


但是实际上useEvent 比useLayoutEffect更提前。

# hook 执行顺序 lifecycle
参考：[React useEvent RFC 细节分析：为何 useLayoutEffect 仍然不符合预期](https://juejin.cn/post/7103105521288232997)

我们有父Father/子Child组件

    // Father Component
    console.log('father render')
    useEffect(()=>{
        console.log('father useEffect')
    })
    useLayoutEffect(()=>{
        console.log('father useLayoutEffect')
    })

    // Child Component
    console.log('child render')
    useEffect(()=>{
        console.log('child useEffect')
    })
    useLayoutEffect(()=>{
        console.log('child useLayoutEffect')
    })

执行顺序是:

    // demo: https://codesandbox.io/s/test-useevent2-hti995?file=/src/App.js
    fahter render
        child render
            child useLayoutEffect
            father useLayoutEffect
        child useEffect
    father useEffect


useEvent 的顺序

    fahter render
    father useEvent
        child render
        child useEvent
                child useLayoutEffect
                father useLayoutEffect
        child useEffect
    father useEffect