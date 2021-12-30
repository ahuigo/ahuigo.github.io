---
title: system worker
date: 2021-12-23
private: true
---
# system worker
# main.go
m is cadenceManager:

    m.StartAllWorkflowWorkers()
    m.StartWorkflowWorker(wf_name)
        
        funcs:
           mainWf= m.GetCadenceWorkflowFunc(name)
           failWf= m.GetCadenceWorkflowFailureHandler(name)
        cadence.RegisterWorkflowWorkerAndStart(name, fns)
            workflow.RegisterWithOptions(fns, workflow.RegisterOptions{Name: name})
            worker.Start()


## activity

    common/orche/statements.go
        582: f = workflow.ExecuteActivity(ctx, a.Name, inputParam)
            


# make Start
1. cadence
2. mojito
3. cadence-system-worker
