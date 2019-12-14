---
title: vscode prettier
date: 2019-12-11
private: true
---
# vscode prettier
除了 vscode 配置 setting.json.  
还有一个优先级更高的, 根目录下的：`.prettierrc`

    const fabric = require('@umijs/fabric');

    module.exports = {
        ...fabric.prettier,
        "tabWidth": 4,
    };


## language

    "prettier.disableLanguages": [
            "json",
            "markdown",
    ]