---
title: css :has selector
date: 2023-01-17
private: true
---
# css :has() selector
> Refer: https://webkit.org/blog/13096/css-has-pseudo-class/#styling-form-states-without-js

## :has() selector example

    <style>
    figure:has(>figcaption) {
        background: blue;
    }
    figure:has(>.main) {
        background: green;
    }
    </style>
    <figure>
        <div>I'm blue</div>
        <figcaption>Maggie loves being outside off-leash.</figcaption>
    </figure>
    <figure>
        <div>I'm not blue</div>
        <div>
            <figcaption>second figcaption</figcaption>
        </div>
    </figure>
    <figure>
        <div>I'm green</div>
        <div class="main">
            <figcaption>second figcaption</figcaption>
        </div>
    </figure>
    <figure>
        <div>I'm not green</div>
        <div>
            <div class="main">
                <figcaption>second figcaption</figcaption>
            </div>
        </div>
    </figure>

## :not() selector example
I use a selector to target any **figure** that **does not** have any **element** that is **not an image**.

    figure:not(:has(:not(img)))
