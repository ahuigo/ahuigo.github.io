---
title: shell color
date: 2018-09-27
---
# shell color
https://en.wikipedia.org/wiki/ANSI_escape_code

## shell

    RED='\033[0;31m'
    NC='\033[0m' # No Color
    printf "I ${RED}love${NC} Stack Overflow\n"


## python

    class bcolors:
        ENDC = '\033[0m'
        HEADER = '\033[95m'
        OKBLUE = '\033[94m'
        RED = '\033[41m'
        OKGREEN = '\033[92m'
        WARNING = '\033[93m'
        FAIL = '\033[91m'
        BOLD = '\033[1m'
        UNDERLINE = '\033[4m'

    print(bcolors.WARNING + "Warning: xxxx" + bcolors.ENDC)
    for i in range(120): print(f'\033[{i}m'+f'中国{i}'+'\033[0m')    

## js color
    console.log('%c str1 %c str2', 'css1','css2');
    console.log('%c haha! ', 'background: #222; color: #bada55');

## color codes 语法

    "\033"+color_code

    COLOR_SEQ = "\033[33m"
    BACK_COLOR_SEQ = "\033[45m"
    BOLD_SEQ = "\033[1m"
    RESET_SEQ = "\033[0m"

### mix color codes
混合color 语法

    "\033[1;33m"
    "\033[1;33;45m"

## foreground and background color
The SGR parameters 30-37 selected the foreground color,

    BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE = range(30,38)
    print("\033[1;32m info \033[0m")

while 40-47 selected the background.

    print("\033[1;42m info \033[0m")

## color code list

    $ sh
    $ RED='\033[0;31m'
    $ NC='\033[0m' # No Color
    $ printf "I ${RED}love${NC} Stack Overflow\n"

zsh color list

    "COLOR_SEQ%sRESET_SEQ"
    "BOLD_SEQ%sRESET_SEQ"

    Code: Client: Meaning:
    [0m     -- reset; clears all colors and styles (to white on black)
    [1m     --  bold on (see below)
    [3m     --  italics on
    [4m     --  underline on
    [7m     2.50    inverse on; reverses foreground & background colors
    [9m     2.50    strikethrough on
    [22m    2.50    bold off (see below)
    [23m    2.50    italics off
    [24m    2.50    underline off
    [27m    2.50    inverse off
    [29m    2.50    strikethrough off
    [30m    --  set foreground color to black
    [31m    --  set foreground color to red
    [32m    --  set foreground color to green
    [33m    --  set foreground color to yellow
    [34m    --  set foreground color to blue
    [35m    --  set foreground color to magenta (purple)
    [36m    --  set foreground color to cyan
    [37m    --  set foreground color to white
    [39m    2.53    set foreground color to default (white)
    [40m    --  set background color to black
    [41m    --  set background color to red
    [42m    --  set background color to green
    [43m    --  set background color to yellow
    [44m    --  set background color to blue
    [45m    --  set background color to magenta (purple)
    [46m    --  set background color to cyan
    [47m    --  set background color to white
    [49m    2.53    set background color to default (black)

    FG  BG
    90	100	Bright Black (Gray)	
    91	101	Bright Red	
    92	102	Bright Green	
    93	103	Bright Yellow	
    94	104	Bright Blue	
    95	105	Bright Magenta
    96	106	Bright Cyan	
    97	107	Bright White

>  In version 2.50 and later, bold is interpreted as high-intensity


# rgb/rgba/hsl/hsv color
## color expression
mac color tool:
1. digital color meter
1. ColorSync Utility
2. chrome color picker

在计算机中经常使用rgb/rgba 三原色来表示所有的颜色。 
在做艺术设计时，经常使用另一种更多允观的HSL或者叫HSV 来表示。

对于HSL 来说， demo: https://codepen.io/AdamGiese/full/YBaOYX

    hsl(359, 100%, 50%)
    hsla(239, 100%, 50%, 0.36)

	H: Hue 色相(0~359)
	S: Saration 饱和度,(0%是灰色,100%是饱和)
	V/L: Lightness 明度/亮度. (0%是黑色，50%是普通亮度，100%白色)
    A: 透明度

    求出最大值和最小值：
    max_value = max(R, G, B)
    min_value = min(R, G, B)

    计算亮度（L）：
    L = (max_value + min_value) / 2

    计算饱和度（S）：
    如果max_value = min_value，则S = 0
    否则，如果L <= 0.5，则 S = (max_value - min_value) / (max_value + min_value)
    否则，S = (max_value - min_value) / (2 - max_value - min_value)

    计算色相（H）：
    如果max_value = min_value，则H = 0（色相未定义）
    否则，如果max_value = R，则 H = (G - B) / (max_value - min_value)
    否则，如果max_value = G，则 H = 2 + (B - R) / (max_value - min_value)
    否则，如果max_value = B，则 H = 4 + (R - G) / (max_value - min_value)
    将H的结果乘以60，并加上360（模运算），以确保结果在0到360之间。

色相表示人类能感知的颜色(rgb 两两组合的颜色)
饱和度0表示灰色: 即`(50%,50%,50%)=rgb(#888)`
明亮度表示接近黑色(0，0，0), 或者白色(1,1,1) 的程度

![Have](/img/ria.color.hue.png)

## css color

    a:hover{background: cadetblue}
    a:link{background: lightgray}
    rebeccapurple, 
    #2f363d
