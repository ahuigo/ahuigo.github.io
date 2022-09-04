---
title: css module
date: 2022-09-01
private: true
---
# css scope style
draft: https://drafts.csswg.org/css-cascade-6/#scoped-styles

https://css-tricks.com/early-days-for-css-scoping/

    @scope (.media) {
      :scope {
        display: grid;
        grid-template-columns: 50px 1fr;
      }
      img {
        filter: grayscale(100%);
        border-radius: 50%;
      }
      .content { ... }
    }

# deno css module
https://github.com/denoland/deno/issues/11961
https://github.com/exhibitionist-digital/ultra/issues/89

# chrome css module

    import styleSheet from "./styles.css" assert { type: "css" };
