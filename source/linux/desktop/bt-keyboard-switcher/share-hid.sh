#!/bin/sh
# =====================================================================
# MacBook Air 2010 -> iPad/iPhone 蓝牙键盘鼠标共享一键启动脚本
# =====================================================================

# 1. 确保脚本是以 root (sudo) 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "[-] 错误: 此脚本需要 root 权限，请使用 'sudo $0' 运行。"
  exit 1
fi

# 2. 确保后台蓝牙服务正在运行 (由于我们在 conf.d 配置了参数，这里可以直接启动)
echo "[*] 正在确保 OpenRC 蓝牙服务处于运行状态..."
rc-service bluetooth start >/dev/null 2>&1
sleep 1.5 # 给芯片初始化留出 1.5 秒时间

# 3. 强刷蓝牙芯片物理寄存器为 外设/键鼠 复合类型 (Class: 0x002540)
echo "[*] 正在物理写入蓝牙芯片 Class (0x002540)..."
hciconfig hci0 class 0x002540

# 4. 强制开启物理广播发现模式 (piscan)
echo "[*] 正在物理开启蓝牙广播 (piscan)..."
hciconfig hci0 piscan

# 5. 进入项目目录并启动 Python 模拟器
SCRIPT_DIR="/home/admin/docs/github/nutki/bt-keyboard-switcher"
if [ -d "$SCRIPT_DIR" ]; then
  echo "[+] 状态: 硬件已就绪！正在拉起 Python 键盘切换器服务..."
  echo "[+] 提示: 终端保持开启即可。按 Ctrl+C 可以退出服务并断开连接。"
  cd "$SCRIPT_DIR"
  python3 keyboardswitcher.py
else
  echo "[-] 错误: 未找到项目目录 $SCRIPT_DIR，请检查路径是否正确。"
  exit 1
fi
