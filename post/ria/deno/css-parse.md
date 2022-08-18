---
title: deno css parse
date: 2022-08-16
private: true
---
# deno css parse
https://deno.land/manual/jsx_dom/css

    import * as css from "https://deno.land/x/css@0.3.0/mod.ts";
    
    const ast = css.parse(`
    body {
      background: #eee;
      color: #888;
    }
    `);
    
    const [body] = ast.stylesheet.rules;
    const [background] = body.declarations;
    
    console.log(JSON.stringify(background, undefined, "  "));