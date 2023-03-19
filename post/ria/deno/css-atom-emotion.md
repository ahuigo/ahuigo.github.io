---
title: emotion
date: 2023-03-17
private: true
---
# emotion
> ultra 支持emotion、stitches、twind、unocss等
example:

    import { css } from '@emotion/react'

    const color = 'white'

    render(
      <div
        css={css`
          padding: 32px;
          background-color: hotpink;
          font-size: 24px;
          border-radius: 4px;
          &:hover {
            color: ${color};
          }
        `}
      >
        Hover to change color.
      </div>
    )