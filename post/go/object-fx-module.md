---
title: fx module
date: 2021-11-20
private: true
---
# fx module
refer to: https://levelup.gitconnected.com/writing-fx-modules-517193b9c4f0

Let’s try to simplify it, when Fx creates a new object (we call it OBJ1, hereafter) it looks up for the dependencies that OBJ1 needs.

Case1: No dependencies required, `OBJ1` is created in the application context.
Case2: Fx finds the needed dependencies in the application context, injects them and OBJ1 is created.

Where did all of this happen? It happened inside a fx.provide call, which in turn is part of a module whose responsibility is to create OBJ1 and provide it to the application context when the New method is called in the Fx lifecycle. (Fx Documentation)

e.g.

    package loggerfx
    var Module = fx.Options(
        fx.Provide(ProvideLogger),
    )

    // cmd
    func main() {
        fx.New(
            fx.Provide(http.NewServeMux),
            fx.Invoke(server.New),
            fx.Invoke(registerHooks),
            loggerfx.Module,
        ).Run()
    }