---
title: ultra css solutions
date: 2023-02-10
private: true
---
# ultra css solutions
ultra 现已支持多种css使用方案:
https://ultrajs.dev/styling

## css style block
这种写法一般不会产生全局污染，组件umount时 style block会被注销。

    ()=>{
        return <div>
        <style>{`
            .c1 button{
                color:red;
            }
        `}</style>
        <div class="c1"><button>OK</button></div>
        </div>
    }

## emotion(简化style block)
    import { css } from '@emotion/react'

    const paragraph = css`
      color: turquoise;
        &:hover {
            background-color: ${token.colorBgTextHover};
        }

      a {
        border-bottom: 1px solid currentColor;
        cursor: pointer;
      }
    `
    render(
      <p css={paragraph}>
        Some text. <a>A link with a bottom border.</a>
      </p>
    )

umijs 也支持

          className={css`
            &:hover {
              background-color: ${token.colorBgTextHover};
            }
          `}
## twind 原子css

## stitches: styled component
    import { styled } from '@stitches/react';

    const Button = styled('button', {
      backgroundColor: 'gainsboro',
      borderRadius: '9999px',
      fontSize: '13px',
      padding: '10px 15px',
      '&:hover': {
        backgroundColor: 'lightgray',
      },
    });

    const globalStyles = globalCss({
        '*': { margin: 0, padding: 0 },
    });

    () => {
        globalStyles();
        return <div ... />
    };
