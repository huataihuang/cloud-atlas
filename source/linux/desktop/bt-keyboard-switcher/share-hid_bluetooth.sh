#!/bin/sh
# =====================================================================
# MacBook Air 2010 -> iPad/iPhone 蓝牙键盘鼠标共享一键启动脚本 (自守恒版)
# =====================================================================

# 1. 确保脚本是以 root (sudo) 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "[-] 错误: 此脚本需要 root 权限，请使用 'sudo $0' 运行。"
  exit 1
fi

# 2. 定义清理和恢复函数 (当用户按 Ctrl+C 或脚本退出时自动执行)
cleanup() {
  echo ""
  echo "[*] 正在恢复系统环境，请稍候..."

  # 杀死我们手动启动的定制蓝牙进程
  if [ -n "$BT_PID" ]; then
    echo "[*] 正在关闭定制的蓝牙进程 (PID: $BT_PID)..."
    kill "$BT_PID" 2>/dev/null
    wait "$BT_PID" 2>/dev/null
  fi

  # 重新拉起系统默认的蓝牙后台服务 (此时 input 插件重新加载，不影响正常设备使用)
  echo "[*] 正在恢复默认的系统蓝牙服务..."
  rc-service bluetooth start >/dev/null 2>&1

  echo "[+] 恢复完毕，系统已回到默认状态。再见！"
  exit 0
}

# 绑定信号捕获 (无论是 Ctrl+C、终端关闭还是脚本异常终止，都会触发 cleanup)
trap cleanup INT TERM EXIT

# 3. 暂停系统的默认蓝牙后台服务
echo "[*] 正在暂时停止系统的默认蓝牙后台服务..."
rc-service bluetooth stop >/dev/null 2>&1
sleep 0.5

# 4. 在后台手动拉起定制参数的蓝牙服务
echo "[*] 正在后台启动专用蓝牙实例 (强制禁用 input,hostname)..."
/usr/lib/bluetooth/bluetoothd --noplugin=input,hostname &
BT_PID=$!

# 等待蓝牙芯片完全初始化
sleep 1.5

# 5. 强刷蓝牙芯片物理寄存器为 外设/键鼠 复合类型 (Class: 0x002540)
echo "[*] 正在物理写入蓝牙芯片 Class (0x002540)..."
hciconfig hci0 class 0x002540

# 6. 强制开启物理广播发现模式 (piscan)
echo "[*] 正在物理开启蓝牙广播 (piscan)..."
hciconfig hci0 piscan

# 7. 进入项目目录并启动 Python 模拟器
SCRIPT_DIR="/home/admin/docs/github/nutki/bt-keyboard-switcher"
if [ -d "$SCRIPT_DIR" ]; then
  echo "[+] 状态: 硬件已就绪！正在启动键盘切换器..."
  echo "[+] 提示: 终端保持开启即可。按 Ctrl+C 可以退出并自动恢复默认蓝牙。"
  cd "$SCRIPT_DIR"
  python3 keyboardswitcher.py
else
  echo "[-] 错误: 未找到项目目录 $SCRIPT_DIR"
  exit 1
fi
