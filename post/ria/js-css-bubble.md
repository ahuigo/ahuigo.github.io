---
title: js css bubble
date: 2019-10-18
private: 
---
# js css bubble
利用border 画三角汽泡，利用before/after 将三角汽泡元素设置了隐含的子元素

    <p><button data-tooltip="I’m the tooltip text.">I’m a button with a tooltip</button>
    </p>
    <style type="text/css">
        *:before,
        *:after {
            box-sizing: border-box;
            /*-- box-sizing: inherit; -->*/
        }
        p {
            margin: 4em 0;
            text-align: center;
        }
        [data-tooltip] {
          position: relative;
          z-index: 2;
          cursor: pointer;
        }

        [data-tooltip]:before {
          position: absolute;
          bottom: 150%;
          left: 50%;
          margin-bottom: 5px;
          margin-left: -80px;
          padding: 7px;
          width: 160px;
          -webkit-border-radius: 3px;
          -moz-border-radius: 3px;
          border-radius: 3px;
          background-color: #000;
          background-color: hsla(0, 0%, 20%, 0.9);
          color: #fff;
          content: attr(data-tooltip);
          text-align: center;
          font-size: 14px;
          line-height: 1.2;
        }

        /* Triangle hack to make tooltip look like a speech bubble */
        [data-tooltip]:after {
          position: absolute;
          bottom: 150%;
          left: 50%;
          margin-left: -5px;
          width: 0;
          border-top: 5px solid #000;
          border-top: 5px solid hsla(0, 0%, 20%, 0.9);
          border-right: 5px solid transparent;
          border-left: 5px solid transparent;
          content: " ";
          font-size: 0;
          line-height: 0;
        }

    
    </style>