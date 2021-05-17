---
title: 定制go协程
date: 2021-05-12
private: true
---
# 定制go协程
todo: https://blog.golang.org/context

$ vi /Users/ahui/go/pkg/mod/go.uber.org/cadence@v0.16.0/internal/internal_workflow.go +565 

    func getState(ctx Context) *coroutineState {
        s := ctx.Value(coroutinesContextKey)
        state := s.(*coroutineState)
        if state.dispatcher.closed {
            runtime.Goexit()
        }
        return state
    }

    func select(){
        for {
			if hasResult() {
                return
			}
			state.yield(fmt.Sprintf("blocked on %s.Receive", c.name))
		}

    }

ctx 的生成：
$ vi /Users/ahui/go/pkg/mod/go.uber.org/cadence@v0.16.0/internal/internal_coroutines_test.go +565 


    func createRootTestContext() (ctx Context) {
        env := new(WorkflowUnitTest).NewTestWorkflowEnvironment()
        interceptors, envInterceptor := newWorkflowInterceptors(env.impl, env.impl.workflowInterceptors)
        return newWorkflowContext(env.impl, interceptors, envInterceptor)
    }
    func newWorkflowContext(env workflowEnvironment, interceptors WorkflowInterceptor, envInterceptor *workflowEnvironmentInterceptor) Context {
        rootCtx := WithValue(background, workflowEnvironmentContextKey, env)
        rootCtx = WithValue(rootCtx, workflowEnvInterceptorContextKey, envInterceptor)
        rootCtx = WithValue(rootCtx, workflowInterceptorsContextKey, interceptors)

        var resultPtr *workflowResult
        rootCtx = WithValue(rootCtx, workflowResultContextKey, &resultPtr)

        // Set default values for the workflow execution.
        wInfo := env.WorkflowInfo()
        rootCtx = WithWorkflowDomain(rootCtx, wInfo.Domain)
        rootCtx = WithWorkflowTaskList(rootCtx, wInfo.TaskListName)
        rootCtx = WithExecutionStartToCloseTimeout(rootCtx, time.Duration(wInfo.ExecutionStartToCloseTimeoutSeconds)*time.Second)
        rootCtx = WithWorkflowTaskStartToCloseTimeout(rootCtx, time.Duration(wInfo.TaskStartToCloseTimeoutSeconds)*time.Second)
        rootCtx = WithTaskList(rootCtx, wInfo.TaskListName)
        rootCtx = WithDataConverter(rootCtx, env.GetDataConverter())
        rootCtx = withContextPropagators(rootCtx, env.GetContextPropagators())
        getActivityOptions(rootCtx).OriginalTaskListName = wInfo.TaskListName

        return rootCtx
    }



