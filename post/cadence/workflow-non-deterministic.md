---
title: non deterministic workflow
date: 2021-12-22
private: true
---
# what is decision task
https://stackoverflow.com/questions/62904129/what-exactly-is-a-cadence-decision-task/63964726#63964726
Some more facts about decision
1. Workflow Decision is to orchestrate those other entities like activity/ChildWorkflow/Timer/etc.

2. Decision(workflow) task is to communicate with Cadence service, telling what is to do next. For example, start/cancel some activities, or complete/fail/continueAsNew a workflow.

3. There is always at most one outstanding(running/pending) decision task for each workflow execution. It's impossible to start one while another is started but not finished yet.

3. The nature of the decision task results in some non-determinism issue when writing Cadence workflow. For more details you can refer to the article.

4. On each decision task, Cadence Client SDK can start from very beginning to "replay" the code, for example, executing activityA. However, this replay mode won't generate the decision of scheduling activityA again. Because client knows that the activityA has been scheduled already.

5. However, a worker doesn't have to run the code from very beginning. Cadence SDK is smart enough to keep the states in memory, and wake up later to continue on previous states. This is called **"Workflow Sticky Cache"**, because a workflow is sticky on a worker host for a period.

# non deterministic workflow
https://github.com/uber/cadence/blob/master/docs/non-deterministic-error.md

## Some Internals of Cadence workflow
A Cadence workflow can be viewed as a long running process on a distributed operating system(OS). 
1. The **process’s state and dispatching** is owned by **Cadence server**, and customers’ **workers** provide **CPU/memory resources to execute** the process’s code. 
2. For most of the time, this process(workflow) is owned by a worker and running like in other normal OS. 
3. But because this is a distributed OS, the **workflow ownership** can be **transferred** to other workers and continue to run from the previous state. Unlike other OS, this is not restarting from the beginning. This is how workflow is fault tolerant to certain host failures.

**Non-deterministic** issues arise during this workflow ownership transfer. 
1. Cadence is designed with event sourcing, meaning that it persists each workflow state mutation as "history event", instead of the whole workflow state machine. 
2. After switching to another worker, the workflow state machine has to be rebuilt. The process of rebuilding the state machine is called “history replay”. Any failure during this history replay is a “non-deterministic error”.

Even if a workflow ownership doesn’t change, history replay is also required under some circumstances:

A workflow stack(of an execution) lives in worker’s memory, a worker can own many workflow executions. So a worker can run out of memory, it has to kick off some workflow executions (with LRU) and rebuild them when necessary.

Sometimes the stack can be stale because of some errors.

In Cadence, Workflow ownership is called "stickiness".

Worker memory cache for workflow stacks is called "sticky cache".

https://github.com/uber/cadence/tree/master/docs