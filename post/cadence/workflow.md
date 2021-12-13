---
title: workflow flow
date: 2021-12-06
private: true
---
# cadenceClient
cmd/samples/common/sample_helper.go 可知道如何构建cadence client

    //  yarpc service client to cadence front service
    cadenceService:='cadence-frontend'
    clientName:="cadence-client"
    dispatcher = yarpc.NewDispatcher(yarpc.Config{
		Name: clientName,
		Outbounds: yarpc.Outbounds{
			cadenceService: {Unary: grpc.NewTransport().NewSingleOutbound(b.hostPort)},
		},
	})
    cfg := b.dispatcher.ClientConfig(cadenceService)
    service := compatibility.NewThrift2ProtoAdapter(cfg) // cadence/compatibiity/thrift2proto.go

    //cadence client 
    client.NewClient(
		service,
		b.domain,
		&client.Options{}
    )

# workflow flow
准备workflow /activity 

    func helloWorldActivity(ctx context.Context, name string) (string, error) {
        logger := activity.GetLogger(ctx)
        logger.Info("helloworld activity started1")
        return "Hello " + name + "!", nil
    }
    func helloWorldWorkflow(ctx workflow.Context, name string) error {
        ao := workflow.ActivityOptions{
            ScheduleToStartTimeout: time.Minute,
            StartToCloseTimeout:    time.Minute,
            HeartbeatTimeout:       time.Second * 20,
        }
        ctx = workflow.WithActivityOptions(ctx, ao)

        logger := workflow.GetLogger(ctx)
        var helloworldResult string
        err := workflow.ExecuteActivity(ctx, helloWorldActivity, name).Get(ctx, &helloworldResult)
        if err != nil {
            logger.Error("Activity failed.", zap.Error(err))
            return err
        }


start workflow worker(register workflow)

    // domain=domainName
    // tasklist=groupName
    worker := worker.New(h.Service, domainName, groupName, options) //cadence/worker.go
        //helloWorkflow
        worker.RegisterWorkflowWithOptions(w.registry1, workflow.RegisterOptions{Name: w.alias})
        // helloWorldActivity
        worker.RegisterActivityWithOptions(act.registry1)
    // starts workflow worker [and activity worker]
    worker.Start()

start workflow:

    swo := client.StartWorkflowOptions{
		ID:                              "helloworld_" + uuid.New(),
		TaskList:                        ApplicationName,
	}
    wf, err := cadenceClient.StartWorkflow(ctx, swo, "", args...)


