#!/bin/sh

# 读取合盖状态：close 表示合上，open 表示打开
lid_state=$(awk '{print $2}' /proc/acpi/button/lid/*/state 2>/dev/null)

if [ "$lid_state" = "closed" ]; then
  # 挂起系统到内存 (Suspend to RAM)
  echo mem >/sys/power/state
fi
