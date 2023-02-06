---
title: css :has selector
date: 2023-01-17
private: true
---
# css :has() selector
> Refer: https://webkit.org/blog/13096/css-has-pseudo-class/#styling-form-states-without-js

## :has() selector example

    <style>
    figure:has(figcaption) {
        background: white;
    }
    </style>
    <figure>
        <img src="dog.jpg" alt="black dog smiling in the sun">
        <figcaption>Maggie loves being outside off-leash.</figcaption>
    </figure>

## :not() selector example
I use a selector to target any **figure** that **does not** have any **element** that is **not an image**.

    figure:not(:has(:not(img)))
