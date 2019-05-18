---
title: shell color
date: 2018-09-27
---
# shell color
https://en.wikipedia.org/wiki/ANSI_escape_code
http://pueblo.sourceforge.net/doc/manual/ansi_color_codes.html

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

## color codes

    "\033"+color_code

    COLOR_SEQ = "\033[33m"
    BACK_COLOR_SEQ = "\033[45m"
    BOLD_SEQ = "\033[1m"
    RESET_SEQ = "\033[0m"

### mix color codes

    "\033[1;33m"
    "\033[1;33;45m"

## color
The SGR parameters 30-37 selected the foreground color,

    BLACK, RED, GREEN, YELLOW, BLUE, MAGENTA, CYAN, WHITE = range(30,38)
    print("\033[1;32minfo\033[0m")

while 40-47 selected the background.

    print("\033[1;42minfo\033[0m")

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

>  In version 2.50 and later, bold is interpreted as high-intensity