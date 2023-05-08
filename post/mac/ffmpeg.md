---
title: ffmpeg 命令使用
date: 2023-05-08
private: true
---
# ffmpeg 命令使用
ffmpeg转gif的时候可以设置区间、码率、分辨率

    $ ffmpeg -i file.mov -r 15 file.gif

    -i 输入您要处理的视频文件路径
    -r 15 
        要强制输出文件的帧频为15 fps

# usage
## 获取封面

    ffmpeg -ss 00:00:10 -i test1.flv -f image2 -y test1.jpg