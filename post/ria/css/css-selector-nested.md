---
title: css nested
date: 2024-06-27
private: true
---
# css nested
https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_nesting/Using_CSS_nesting
https://developer.chrome.com/docs/css-ui/css-nesting

## child selector
```
/* Without nesting selector */
parent {
  /* parent styles */
  child {
    /* child of parent styles */
  }
}

/* With nesting selector */
parent {
  /* parent styles */
  & child {
    /* child of parent styles */
  }
}

/* the browser will parse both of these as */
parent {
  /* parent styles */
}
parent child {
  /* child of parent styles */
}
```
## Combinators
CSS Combinators can also be used with or without the & nesting selector.

```
<h2>Heading</h2>
<p>This is the first paragraph.</p>
<p>This is the second paragraph.</p>
<style>
h2 {
  color: tomato;
  + p {
    color: white;
    background-color: black;
  }
}
/* this code can also be written with the & nesting selector */
/* 
h2 {
  color: tomato;
  & + p {
    color: white;
    background-color: black;
  }
}
</style>
*/
```
## Compound selectors

```
    .a {
    /* styles for element with class="a" */
    .b {
        /* styles for element with class="b" which is a descendant of class="a" */
    }
    &.b {
        /* styles for element with class="a b" */
    }
    }

    /* the browser parses this as */
    .a {
    /* styles for element with class="a" */
    }
    .a .b {
    /* styles for element with class="b" which is a descendant of class="a" */
    }
    .a.b {
    /* styles for element with class="a b" */
    }
```
## Appended nesting selector
The `&` nesting selector can also be appended to a nested selector which has the effect of reversing the context.

```
.foo {
  /* .foo styles */
  .bar & {
    /* .bar .foo styles(.foo 是.bar的后代) */
  }
}
```

second example:

```
<div class="wrapper">
  <article class="card">
    <h2>Card 1</h2>
    <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit.</p>
  </article>
  <article class="card featured">
    <h2>Card 2</h2>
    <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit.</p>
  </article>
  <article class="card">
    <h2>Card 3</h2>
    <p>Lorem ipsum dolor, sit amet consectetur adipisicing elit.</p>
  </article>
</div>
<style>
.wrapper {
  display: flex;
  flex-direction: row;
  gap: 0.25rem;
  font-family: system-ui;
}

.card {
  padding: 0.5rem;
  border: 1px solid black;
  border-radius: 0.5rem;
  & h2 {
    /* equivalent to `.card h2` */
    color: slateblue;
    .featured & {
      /* equivalent to `:is(.card h2):is(.featured h2)` */
      color: tomato;
    }
  }
}

</style>
```

## nested child and grandson
    .nesting {
      color: hotpink;
      &div {
        color: red;
      }
      > .is {
        color: rebeccapurple;

        > .awesome {
          color: deeppink;
        }
      }
    }

## group css
> https://developer.chrome.com/docs/css-ui/css-nesting

Without nesting:

    .demo .triangle,
    .demo .square {
      opacity: .25;
      filter: blur(25px);
    }

    // or, using :is()

    /* grouped with :is() */
    .demo :is(.triangle, .square) {
      opacity: .25;
      filter: blur(25px);
    }

With nesting, here are two valid ways:

    .demo {
      & .triangle,
      & .square {
        opacity: .25;
        filter: blur(25px);
      }
    }
    // or
    .demo {
      .triangle, .square {
        opacity: .25;
        filter: blur(25px);
      }
    }

anoter group example

    .demo .lg:is(.triangle, .circle) {
      opacity: .25;
      filter: blur(25px);
    }
    //or
    .demo {
      .lg {
        &.triangle, &.circle {
          opacity: .25;
          filter: blur(25px);
        }
      }
    }
