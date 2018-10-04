---
title: nodemon like watch dog
date: 2018-10-04
---
# nodemon like watch dog
nodemon --config nodemon.json app.js
nodemon app.js
nodemon -h

    $ cat nodemon.json
    {
        "restartable": "rs",
        "ignore": [
            ".git",
            "node_modules/**/node_modules"
        ],
        "verbose": true,
        "execMap": {
            "js": "node --harmony"
        },
        "env": {
            "NODE_ENV": "development",
            "DEBUG": "*,-nodemon:*,-nodemon,-knex:pool"
        },
        "ext": "js json"
    }