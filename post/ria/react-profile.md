---
title: React profile
date: 2019-09-08
---
# React performance
Refer: https://zh-hans.reactjs.org/docs/optimizing-performance.html

## Chrome Performance 标签分析
## Chrome react profile 分析

# Profiler API?
> Refer: https://zh-hans.reactjs.org/docs/profiler.html

你可以在React 任何地方 插入profiler 分析点

    <Profiler id="Navigation" onRender={callback}>
      <Navigation {...props} />
    </Profiler>
    <Profiler id="Main" onRender={callback}>
      <Main {...props} />
    </Profiler>

嵌套Profiler:

    <App>
        <Profiler id="Panel" onRender={callback}>
         <Panel {...props}>
           <Profiler id="Content" onRender={callback}>
             <Content {...props} />
           </Profiler>
           <Profiler id="PreviewPane" onRender={callback}>
             <PreviewPane {...props} />
           </Profiler>
         </Panel>
        </Profiler>
    </App>

## onRender
    function onRenderCallback(
      id, // the "id" prop of the Profiler tree that has just committed
      phase, // either "mount" (if the tree just mounted) or "update" (if it re-rendered)
      actualDuration, // time spent rendering the committed update
      baseDuration, // estimated time to render the entire subtree without memoization
      startTime, // when React began rendering this update
      commitTime, // when React committed this update
      interactions // the Set of interactions belonging to this update
    ) {
      // Aggregate or log render timings...
    }