---
title: gawk func
date: 2024-09-30
private: true
---
# gawk func

## Define func
定义声明必须在语句快中，函数定义则在语句块外

    read -r -d '' CONTENT <<-'EOF'
    BEGIN {
        Name = "Alex"
    }

    function say(age=80) {
        cmd = "nl"
        print("Name:",Name, age) | cmd
    }

    BEGIN{
        say(10)
    }
    EOF
    gawk -f <(echo -E "$CONTENT")

## 动态函数
`@vm()`　表示调用名为vm 变量值的函数

    function trans(text, sl, tl, hl, isVerbose, toSpeech, returnPlaylist, returnIl, vm)
    {
        vm = engineMethod("Translate")
        return @vm(text, sl, tl, hl, isVerbose, toSpeech, returnPlaylist, returnIl)
    }
