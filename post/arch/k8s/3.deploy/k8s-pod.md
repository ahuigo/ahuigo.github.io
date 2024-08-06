---
title: k8s pod
date: 2024-08-06
private: true
---
# k8s pod crud
可以不创建deployment ，直接创建pod

## create pod
    $ kubectl run pod-test --image=busybox --requests "cpu=50m" --limits "cpu=100m" --command -- /bin/sh -c "while true; do
sleep 2; done"
    deployment.apps "pod-test" created