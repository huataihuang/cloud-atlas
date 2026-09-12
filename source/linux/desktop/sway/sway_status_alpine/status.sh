#!/bin/sh

# 1. CPU 状态：频率/温度/负载 (C:频率@温度/负载)
get_cpu() {
  # 频率：读取 /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq (单位 kHz -> MHz)
  if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]; then
    freq_khz=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    freq=$((freq_khz / 1000))
  else
    freq="N/A"
  fi

  # 温度：优先查找 coretemp / thermal_zone (单位 m°C -> °C)
  temp="0"
  for t in /sys/class/thermal/thermal_zone*/temp; do
    if [ -f "$t" ]; then
      raw_temp=$(cat "$t" 2>/dev/null || echo 0)
      temp=$((raw_temp / 1000))
      break
    fi
  done

  # 负载：使用 uptime 获取 1分钟 平均负载
  load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d',' -f1 | tr -d ' ')

  echo "C:${freq}MHz@${temp}°C/${load}"
}

# 2. 内存占用 (M:百分比)
get_mem() {
  # 从 /proc/meminfo 中计算使用率 (避免依赖 free 命令的选项差异)
  mem_total=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
  mem_avail=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)

  if [ -n "$mem_total" ] && [ -n "$mem_avail" ] && [ "$mem_total" -gt 0 ]; then
    used_percent=$(((mem_total - mem_avail) * 100 / mem_total))
  else
    used_percent="0"
  fi
  echo "M:${used_percent}%"
}

# 3. 硬件信息：MacBook 风扇转速 / WiFi 强度 (F:转速|W:WiFi%)
get_hw() {
  # MacBook Air 2010 苹果风扇接口 (applesmc 模块)
  if [ -f /sys/devices/platform/applesmc.768/fan1_input ]; then
    fan=$(cat /sys/devices/platform/applesmc.768/fan1_input)
  elif [ -f /sys/class/hwmon/hwmon*/fan1_input ]; then
    fan=$(cat /sys/class/hwmon/hwmon*/fan1_input 2>/dev/null | head -n1)
  else
    fan="0"
  fi

  # WiFi 信号强度：从 /proc/net/wireless 获取
  wifi_link=$(awk '/wlan0:|wlp/ {print $3}' /proc/net/wireless 2>/dev/null | tr -d '.')
  if [ -n "$wifi_link" ]; then
    # quality 最高一般为 70
    wifi=$((wifi_link * 100 / 70))
    [ "$wifi" -gt 100 ] && wifi=100
  else
    wifi="0"
  fi

  echo "F:${fan}RPM|W:${wifi}%"
}

# 4. 电池 (含状态图标)
get_battery() {
  bat_path="/sys/class/power_supply/BAT0"
  [ ! -d "$bat_path" ] && bat_path="/sys/class/power_supply/BAT1"

  if [ -d "$bat_path" ]; then
    cap=$(cat "$bat_path/capacity" 2>/dev/null || echo 0)
    status=$(cat "$bat_path/status" 2>/dev/null || echo "Discharging")

    if [ "$status" = "Charging" ]; then
      echo "⚡${cap}%"
    else
      echo "🔋${cap}%"
    fi
  else
    echo "🔌AC"
  fi
}

# 5. 音量 (纯 ALSA amixer)
get_volume() {
  vol_info=$(amixer get Master 2>/dev/null | tail -n 1)

  if [ -z "$vol_info" ]; then
    echo "🔊N/A"
    return
  fi

  vol=$(echo "$vol_info" | awk -F'[][]' '{ print $2 }')
  status=$(echo "$vol_info" | awk -F'[][]' '{ print $6 }')

  if [ "$status" = "off" ]; then
    echo "🔇静音"
  else
    echo "🔊${vol}"
  fi
}

# 6. 媒体播放：当前 MPD 播放曲目 (新增)
get_media() {
  # 检查 MPD/playerctl 状态
  status=$(playerctl -p mpd status 2>/dev/null)

  if [ "$status" = "Playing" ]; then
    # 正在播放：获取 歌手 - 歌名 (超过 20 字符截断防超长)
    track=$(playerctl -p mpd metadata --format "{{ artist }} - {{ title }}" 2>/dev/null)
    [ -z "$track" ] && track=$(playerctl -p mpd metadata --format "{{ title }}" 2>/dev/null)

    # 限制显示长度
    if [ ${#track} -gt 22 ]; then
      track="$(echo "$track" | cut -c 1-20).."
    fi
    echo "🎵 ${track} |"
  elif [ "$status" = "Paused" ]; then
    echo "⏸️ 暂停 |"
  else
    # Stopped 或未启动时不输出内容
    echo ""
  fi
}

# 循环输出给 swaybar
while true; do
  echo "$(get_media) $(get_cpu) | $(get_mem) | $(get_hw) | $(get_battery) | $(get_volume) | $(date +'%Y-%m-%d %H:%M')"
  sleep 5
done
