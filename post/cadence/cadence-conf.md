---
title: cadence conf load
date: 2021-12-25
private: true
---
# cadence conf load
config/config_template.yaml

    cmd/server/cadence/cadence.go +78
        err := config.Load(env, configDir, zone, &cfg)
        server := newServer(svc, &cfg)

    cmd/server/cadence/server.go +216
        params.PersistenceConfig = s.cfg.Persistence +112
        case frontendService: +216
            daemon, err = frontend.NewService(&params)
    service/frontend/service.go +182
        serviceResource, err := resource.New(params)
        params.PersistenceConfig
            Persistence.AdvancedVisibilityStore\


    cmd/server/cadence/server.go +173
        advancedVisStoreKey := s.cfg.Persistence.AdvancedVisibilityStore
        log.Fatalf("not able to find advanced visibility store in config: %v", advancedVisStoreKey)
