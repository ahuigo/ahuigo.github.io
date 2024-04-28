---
title: ffmpeg 命令使用
date: 2023-05-08
private: true
---
# ffmpeg 命令转换
## mov to gif
ffmpeg转gif的时候可以设置区间、码率、分辨率

    $ ffmpeg -i file.mov -r 15 file.gif

    -i 输入您要处理的视频文件路径
    -r 15 
        要强制输出文件的帧频为15 fps

## avi to mp4

    $ ffmpeg -i src.avi -c:v copy -c:a copy output.mp4
## mp4 to m3u8
    $ ffmpeg -i input.mp4 -profile:v baseline -level 3.0 -s 640x480 -start_number 0 -hls_time 10 -hls_list_size 0 -f hls index.m3u8

    -profile:v baseline -level 3.0 -s 640x480: sets the output video profile to baseline, level to 3.0, and size to 640x480. You can adjust these according to your needs.
    -start_number 0: specifies the start number for the output file names.
    -hls_time 10: sets the maximum segment length to 10 seconds.
    -hls_list_size 0: includes all segments in the playlist.
    -f hls index.m3u8: specifies the output format as HLS and the output file name as index.m3u8.

# usage
## 获取封面

    ffmpeg -ss 00:00:10 -i test1.flv -f image2 -y test1.jpg