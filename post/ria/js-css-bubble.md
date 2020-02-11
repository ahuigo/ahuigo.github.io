---
title: js css bubble
date: 2019-10-18
private: 
---
# js css bubble
利用border 画三角汽泡，利用before/after 将三角汽泡元素设置了隐含的子元素

    <p><button data-tooltip="I’m the tooltip text.">
    I’m a button with a tooltip</button>
    </p>
    <style type="text/css">
        p {
            margin: 4em 0;
            text-align: center;
        }
        button{
            background: #00BCD4;
            position: relative;
            z-index: 2;
            cursor: pointer;
        } 
 
        [data-tooltip]:before {
            position: absolute;
            box-sizing: border-box;
            bottom: 100%;
            left: 50%;
            margin-bottom: 15px;
            margin-left: -80px;
            padding: 8px;
            width: 160px;
            border-radius: 3px;
            background-color: hsla(0, 0%, 20%, 0.9);
            color: #fff;
            content: attr(data-tooltip);
            text-align: center;
        }

        [data-tooltip]:after {
            position: absolute;
            bottom: 100%;
            left: 50%;
            margin-left: -15px;
            border-top: 15px solid hsla(153, 88%, 50%, 0.51);
            border-right: 15px solid #000000e8;
            border-left: 15px solid #0000009e;
            content: " ";
        }
    
    </style>

封装成less:

    .label{
        cursor: pointer;
        background: #00BCD4;
        position: relative;
        z-index: 2;
        :global(.content){
            position: absolute;
            box-sizing: border-box;
            bottom: 100%;
            left: 50%;
            margin-bottom: 15px;
            margin-left: -80px;
            padding: 8px;
            width: 160px;
            border-radius: 3px;
            background-color: hsla(0, 0%, 20%, 0.9);
            color: #fff;
            content: attr(data-tooltip);
            text-align: center;
        }
        :global(.angle){
            position: absolute;
            bottom: 100%;
            left: 50%;
            margin-left: -15px;
            border-top: 15px solid hsla(153, 88%, 50%, 0.51);
            border-right: 15px solid #000000e8;
            border-left: 15px solid #0000009e;
            content: " ";
        }
    } 
