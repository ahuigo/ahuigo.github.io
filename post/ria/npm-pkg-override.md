---
title: npm override transparent dependency
date: 2023-03-24
private: true
---
# npm override dependency
> go强制版本：indirect dependency引入(transitive dependency, grandson package)

specify an overrides property in your package.json to override and enforce nested dependency versions.

    {
      "overrides": {
        "bar@2.0.0": {
          "foo": "1.0.0"
        }
      }
    }

或

    {
      "overrides": {
        "awesome-typescript-loader": {
            "typescript": "latest"
        }
      }
    }