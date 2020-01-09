---
title: Ts root directory
date: 2020-01-08
private: true
---
# Ts root directory
调立@ 为要路径

    {
        "compilerOptions": {
            "paths": {
                "@/*": ["./src/*"]
            }
            "outDir": "build/dist",
            "module": "esnext",
            "target": "esnext",
            "lib": ["esnext", "dom"],
            "sourceMap": true,
            "baseUrl": ".",
            "jsx": "react",
            "allowSyntheticDefaultImports": true,
            "moduleResolution": "node",
            "forceConsistentCasingInFileNames": true,
            "noImplicitReturns": true,
            "suppressImplicitAnyIndexErrors": true,
            "noUnusedLocals": true,
            "allowJs": true,
            "experimentalDecorators": true,
            "strict": true,
        },
    }
