---
title: k8s ctl
date: 2021-12-25
private: true
---
# k8s ctl
    $ kubectl apply -n <namespace> -f <servicename>
    $ kubectl edit deployments.apps -n <namespace> <servicename>

    $ kubectl get pod -n <namespace>
    $ kubectl exec -it  -n <namespace> <servicename>-7994cf9f84-44x7b bash
    $ kubectl logs -n <namespace>  <servicename>-7994cf9f84-44x7b
        $ kubectl logs -n <namespace> -f <servicename>-7994cf9f84-44x7b

