#!/usr/bin/env bash
#
:<<'EOF'
获得音质最好的音频
yt-dlp -F 过滤列表案例
599 m4a   audio only      2 |   1.45MiB   31k dash  | audio only        mp4a.40.5   31k 22k ultralow, m4a_dash
139 m4a   audio only      2 |   2.30MiB   49k dash  | audio only        mp4a.40.5   49k 22k low, m4a_dash
140 m4a   audio only      2 |   6.11MiB  129k dash  | audio only        mp4a.40.2  129k 44k medium, m4a_dash
EOF

# 这里playlist可以通过 yt-dlp -F 某个播放列表获得文件列表内容，将要下载的id都保存到playlist文件中，然后就可以自动把这些视频一一过滤出合适的id(需要的音频格式)
# yt-dlp --download-archive archive.txt "https://www.youtube.com/playlist?list=PLwiyx1dc3P2JR9N8gQaQN_BCvlSlap7re"
# 不过，上述命令会同时下载一次原始视频文件，有点蛋疼

for i in `cat archive.txt`;do
    id=`yt-dlp -F "https://www.youtube.com/watch?v=$i" | grep "m4a   audio only" | awk '{print $1" "$8}' | awk -Fk '{print $1}' | sort -r -n -k2 | head -1 | awk '{print $1}'`
    echo $id
    yt-dlp -f $id "https://www.youtube.com/watch?v=$i"
done
