#!/bin/sh

# 1. 启动 Firefox 并立即给“下一个”出现的 Firefox 窗口打上标记 'target_web'
swaymsg "exec firefox"
# 循环等待，直到找到那个还没被标记的新 Firefox
while :; do
    # 尝试寻找没有标记且 app_id 是 firefox 的窗口并打上标记
    if swaymsg "[app_id=\"firefox\" con_mark=\"^$\"] mark --add target_web" 2>/dev/null; then
        break
    fi
    sleep 0.2
done

# 2. 针对带标记的 Firefox 进行水平切分
swaymsg "[con_mark=\"target_web\"] focus; split horizontal"

# 3. 启动第一个 foot 并打标记 'term_top'
swaymsg "exec foot"
while :; do
    if swaymsg "[app_id=\"foot\" con_mark=\"^$\"] mark --add term_top" 2>/dev/null; then
        break
    fi
    sleep 0.1
done

# 4. 针对第一个 foot 进行垂直切分
swaymsg "[con_mark=\"term_top\"] focus; split vertical"

# 5. 启动最后一个 foot
swaymsg "exec foot"

# 可选：清理标记（如果你不希望窗口一直带着标签）
swaymsg "[con_mark=\"target_web\"] unmark"
swaymsg "[con_mark=\"term_top\"] unmark"
