---
title: css @apply
date: 2023-03-14
private: true
---
# css @apply
> https://hospodarets.com/css_apply_rule
@apply 已经被chrome放弃支持，
可使用::part() 代替，它支持继承
## Define  rule
Let’s just define set of properties:

    :root {
        --pink-theme: {
            color: #6A8759;
            background-color: #F64778;
        }
    }

nested rules:

    :root {
      --zero-size: {
        width: 0;
        height: 0;
      };
    
    
      --triangle-to-bottom: {
        @apply --zero-size;
        border-style: solid;
      };
    }

## use rule

    body{
      @apply --pink-theme;
    }