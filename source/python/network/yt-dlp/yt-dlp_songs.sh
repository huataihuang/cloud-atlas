#!/usr/bin/env bash
#
:<<'EOF'
获得音质最好的音频
yt-dlp -F 过滤列表案例
599 m4a   audio only      2 |   1.45MiB   31k dash  | audio only        mp4a.40.5   31k 22k ultralow, m4a_dash
139 m4a   audio only      2 |   2.30MiB   49k dash  | audio only        mp4a.40.5   49k 22k low, m4a_dash
140 m4a   audio only      2 |   6.11MiB  129k dash  | audio only        mp4a.40.2  129k 44k medium, m4a_dash
EOF

for i in `cat playlist`;do
    id=`yt-dlp -F "https://www.youtube.com/watch?v=$i" | grep "m4a   audio only" | awk '{print $1" "$8}' | awk -Fk '{print $1}' | sort -r -n -k2 | head -1 | awk '{print $1}'`
    echo $id
    yt-dlp -f $id "https://www.youtube.com/watch?v=$i"
done
