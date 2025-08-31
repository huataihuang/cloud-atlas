#!/usr/bin/env bash
#
:<<'EOF'
获得音质最好的音频
yt-dlp -F 过滤列表案例
599 m4a   audio only      2 |   1.45MiB   31k dash  | audio only        mp4a.40.5   31k 22k ultralow, m4a_dash
139 m4a   audio only      2 |   2.30MiB   49k dash  | audio only        mp4a.40.5   49k 22k low, m4a_dash
140 m4a   audio only      2 |   6.11MiB  129k dash  | audio only        mp4a.40.2  129k 44k medium, m4a_dash
EOF

# 将要下载的id都保存到playlist文件中，然后就可以自动把这些视频一一过滤出合适的id(需要的音频格式)
#
# yt-dlp --download-archive archive.txt "<playlist_URL>"
# 不过，上述命令会同时下载一次最近原始视频文件，然后存放一个列表到 archive.txt ，不过这个方法不太好
#
# 更好的获取playlist中所有视频IDs的方法是:
# yt-dlp --get-id --flat-playlist "<playlist_URL>"

# 这里的URL请修订成自己需要的真实playlist
playlist_URL="https://www.youtube.com/playlist?list=XXXXXXXXXXXX"

yt-dlp --get-id --flat-playlist $playlist_URL --cookies www.youtube.com_cookies.txt > video_ids.txt

for i in `cat video_ids.txt`;do
    id=`yt-dlp -F "https://www.youtube.com/watch?v=$i" | grep "m4a   audio only" | awk '{print $1" "$8}' | awk -Fk '{print $1}' | sort -r -n -k2 | head -1 | awk '{print $1}'`
    echo $id
    yt-dlp -f $id "https://www.youtube.com/watch?v=$i"
done
