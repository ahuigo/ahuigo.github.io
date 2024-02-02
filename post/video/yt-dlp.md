 ---
 title: yt-dlp
 date: 2024-02-02
 private: true
 ---
# 视频格式
## 显示视频格式#
可以使用-F标识符(注意是大写的F)或–list-formats列出视频的所有可用格式(分辨率)。

    $ yt-dlp https://url -F
    ID  EXT   RESOLUTION FPS CH │   FILESIZE   TBR PROTO │ VCODEC          VBR ACODEC      ABR ASR MORE INFO
    ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    139 m4a   audio only      2 │  698.51KiB   49k https │ audio only          mp4a.40.5   49k 22k low, m4a_dash
    249 webm  audio only      2 │  729.17KiB   51k https │ audio only          opus        51k 48k low, webm_dash
    597 mp4   256x144     15    │  380.72KiB   27k https │ avc1.4d400b     27k video only          144p, mp4_dash
    603 mp4   256x144     30    │ ~  2.22MiB  155k m3u8  │ vp09.00.11.08  155k video only
    278 webm  256x144     30    │  694.23KiB   49k https │ vp09.00.11.08   49k video only          144p, webm_dash
    230 mp4   640x360     30    │ ~  4.37MiB  306k m3u8  │ avc1.4D401E    306k video only

结果跟用 youtube-dl命令的差不多，标题行含义： > ID：文件ID > EXT：格式 > RESOLUTION：分辨率 > FPS：视频的帧率 > FILESIZE：文件大小 > VCODEC：audio only表示仅音频 > ACODEC：video only表示仅视频（没有音频）；像mp4a.40.2（720p）就直接包含了音频
## 下载视频（带音频）ID
下载视频（带音频）ID：22 | EXT：mp4 | 1280*720

    yt-dlp -f22 https://youtu.be/sKrT6mBrosc

## 下载指定分辨率视频+音频
1080及以上分辨率的音频和视频是分开的，所以一般会音频和视频一起下载

yt-dlp -f299+140 https://youtu.be/sKrT6mBrosc

## 下载最佳mp4视频+最佳m4a音频格式并合成mp4

    yt-dlp -f ‘bv[ext=mp4]+ba[ext=m4a]’ –embed-metadata –merge-output-format mp4 https://youtu.be/sKrT6mBrosc
    - bv(best video)

最差视频质量：

    yt-dlp -f 'worstvideo[ext=mp4]+ba[ext=m4a]' –embed-metadata –merge-output-format mp4 https://youtu.be/sKrT6mBrosc

## 指定质量#
要下载指定格式的视频，请使用-f(注意小写f)或–format标志符。您可以指定仅视频、仅音频或视频+音频格式。使用使用–list-formats标志符返回的格式代码来选择格式。

    yt-dlp https://url -f best

也有一些预设格式来下载最好或最差的音频/视频。这些可以用来代替精确的格式代码。

    best – Downloads the highest quality file containing both audio and video
    worst – Downloads the lowest quality file containing both audio and video
    bestvideo – 下载最高质量的视频文件
    worstvideo – 下载最低质量的视频文件
    bestaudio – 下载最高质量的音频文件
    worstaudio – 下载最低质量的音频文件
## 指定格式
    -S vcodec:h264,res,acodec:m4a
# 只下载音频
    youtube-dl -x url

默认情况下，Youtube-dl 将以 Ogg（opus）格式保存音频，如果想以任何其他格式下载音频，例如 mp3 请运行：

    yt-dlp -x --audio-format mp3 https://url

# output
## 合并mp4格式（默认）

    yt-dlp --merge-output-format mp4 https://url

# bilibili

    yt-dlp -S vcodec:h264,res,acodec:m4a --no-mtime https://www.bilibili.com/video/xxxx --merge-output-format mp4