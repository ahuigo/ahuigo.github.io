---
title: npm peer dependency
date: 2023-04-10
private: true
---
# npm peer dependency
为了避免子包多版本依赖，可以项目中指定：

    "peerDependencies": {
        "foo": "*"
    },
    "peerDependenciesMeta": {
        "foo": { "transitive": true }
    }