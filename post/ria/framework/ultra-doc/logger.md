---
title: deno logger
date: 2022-12-22
private: true
---
# deno logger
    import { crayon, log as logging, sprintf } from "./deps.ts";

    await logging.setup({
    //assign handlers to loggers  
    // https://medium.com/deno-the-complete-reference/using-logger-in-deno-44c5b2372bf3
    loggers: {
        default: {
            level: "DEBUG",
            handlers: ["console"],
        },
        client: {
            level: "DEBUG",
            handlers: ["console"]
        }
    },
    });

