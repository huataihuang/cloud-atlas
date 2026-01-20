#!/bin/sh

# 1. CPU 状态：频率/温度/负载 (C:频率@温度/负载)
get_cpu() {
    # 获取当前频率 (MHz)
    freq=$(sysctl -n dev.cpu.0.freq)
    temp=$(sysctl -n dev.cpu.0.temperature | cut -d'.' -f1)
    load=$(uptime | awk -F'load averages:' '{ print $2 }' | cut -d',' -f1 | tr -d ' ')
    echo "C:${freq}@${temp}°C/${load}"
}

# 2. 内存占用 (M:百分比)
get_mem() {
    pagesize=$(sysctl -n hw.pagesize)
    total_pages=$(sysctl -n vm.stats.vm.v_page_count)
    free_pages=$(sysctl -n vm.stats.vm.v_free_count)
    used_percent=$(( (total_pages - free_pages) * 100 / total_pages ))
    echo "M:${used_percent}%"
}

# 3. 硬件信息：风扇转速/WiFi强度 (H:转速/WiFi)
get_hw() {
    # 需加载 acpi_ibm
    fan=$(sysctl -n dev.acpi_ibm.0.fan_speed 2>/dev/null || echo "0")
    wifi=$(ifconfig wlan0 list sta | tail -1 | awk '{print $5}' 2>/dev/null || echo "0")
    echo "F:${fan}|W:${wifi}%"
}

# 4. 电池 (含状态图标)
get_battery() {
    cap=$(sysctl -n hw.acpi.battery.life)
    state=$(sysctl -n hw.acpi.battery.state)
    [ "$state" -eq 2 ] && echo "⚡$cap%" && return
    echo "🔋$cap%"
}

while true; do
    echo "$(get_cpu) | $(get_mem) | $(get_hw) | $(get_battery) | $(date +'%H:%M')"
    sleep 5
done
