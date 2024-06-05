---
title: docker privilege
date: 2022-04-09
private: true
---
# docker privilege
docker 1.12起，不用`--privileged` 扩展权限了, 而是使用`--cap-add`, `--cap-drop`添加删除权限
可参考： https://docs.docker.com/engine/reference/run/#runtime-privilege-and-linux-capabilities

    docker run --cap-add=ALL --cap-drop=MKNOD ...
