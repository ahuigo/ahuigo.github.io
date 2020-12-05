---
title: mac tool 词典工具
date: 2020-10-28
private: true
---
# mac tool 词典工具
mac 自带的dict非常方便. 可以通过shortcut呼出. 也可以通过alfred2呼出
字典文件在: $ ls /Library/Dictionaries ~/Library/Dictionaries 见[mac-install]

	$ du -sh /Library/Dictionaries/*
	$ du -sh ~/Library/Dictionaries/*
    Apple Dictionary.dictionary
	New Oxford American Dictionary.dictionary
	Oxford American Writer's Thesaurus.dictionary
	Oxford Dictionary of English.dictionary
	Oxford Thesaurus of English.dictionary
	Simplified Chinese - English.dictionary
## 三指查词
打开“系统偏好设置”然后在“触控板”打开这个功能(查找&数据钩（look up&data detectors）上)就可以啦


## install other dict
我觉得自带的Simplified ce 就做中英翻译就非常够用了. 如果需要下载的词典
可以:
1. [在baidu pan下载](http://pan.baidu.com/s/1o6z67dK#dir/path=%2Fdictionary),
2. https://github.com/ahuigo/langdao

下载后解压到字典目录就ok了.

	mv langdao-ec-gb.dictionary ~/Library/Dictionaries

安装好了后, 在dict中按`Cmd+,`选择字典就可以了

> 另外我想说明的是dict 支持维基, 可是不支持google translate, 不过可以通过alfred 实现google translate

## shortcut

    Ctrl+Cmd+D #select a word then press this shortcut anywhere.

## alfred2

    def word

如果不满足, 也可以直接呼出google/baidu 查询.我自己定义的tl会呼起google tranlate

    tl word
    df word

## F5:word completion.
绝大部分mac app 都支持用F5完成 word completion.

>Word completion seems to only work in Apple crafted cocoa apps, so you’ll be able to use the feature in Safari, Pages, Keynote, TextEdit, iCal, etc, but in a browser like Chrome you’re out of luck.

## text to voice
In System Preference -> [Text to voice](http://computers.tutsplus.com/tutorials/give-your-mac-a-voice-with-text-to-speech--mac-4943)

### shortcut

    Alt+ESC 单词朗读

### say 'word'

    $ say 'word'
	$ say -f mynovel.txt -o myaudiobook.aiff

### Voice Files Dir
所有的语音文件都是放在这里的：

    /System/Library/Speech/Voices
