---
title: framework
date: 2022-06-22
private: true
---

# framework

www/dev.ts

    import dev from "$fresh/dev.ts";
    await dev(import.meta.url, "./main.ts");

dev: import { dev } from "./src/dev/mod.ts";
