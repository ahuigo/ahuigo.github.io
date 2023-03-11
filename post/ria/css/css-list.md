---
title: css list
date: 2023-03-11
private: true
---
# css list
## prefix
syntax:

    prefix: "»";
    prefix: "Page ";
    prefix: url(bullet.png);

example from MDN:

    <style>
        @counter-style chapters {
          system: numeric;
          symbols: "0" "1" "2" "3" "4" "5" "6" "7" "8" "9";
          prefix: "Chapter ";
        }

        .index {
          list-style: chapters;
          padding-left: 15ch;
        }
    </style>
    <ul class="index">
      <li>Alex</li>
      <li>John</li>
    </ul>

效果:

      Chapter 1. Alex
      Chapter 2. John