#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import time
import sys
import os
from pynvml import (
    nvmlInit,
    nvmlShutdown,
    nvmlDeviceGetCount,
    nvmlDeviceGetHandleByIndex,
    nvmlDeviceGetTemperature,
    nvmlDeviceGetPowerUsage,
    NVML_TEMPERATURE_GPU
)

# ==================== 用户可配置参数 ====================
POLL_INTERVAL = 5          # 轮询间隔（秒），建议 5~10 秒，避免过于频繁
TEMP_MIN = 35.0            # 低于此温度时风扇保持最低转速
TEMP_MAX = 70.0            # 高于此温度时风扇全速运转
PWM_MIN = 30               # 最低 PWM 值 (0-255)，对应转速下限，防止卡死
PWM_MAX = 255              # 最高 PWM 值 (0-255)

# 硬件路径配置 (根据你的描述)
# 0号 A2 独占 pwm4
PWM_PATH_GPU0 = "/sys/class/hwmon/hwmon2/pwm4"
# 1号和2号 A2 共享 pwm3
PWM_PATH_GPU12 = "/sys/class/hwmon/hwmon2/pwm3"
# ========================================================

def write_pwm(path, pwm_value):
    """安全写入 PWM 节点"""
    try:
        pwm_clamped = max(0, min(255, int(pwm_value)))
        with open(path, "w") as f:
            f.write(str(pwm_clamped))
    except Exception as e:
        print(f"[错误] 写入 PWM 路径 {path} 失败: {e}", file=sys.stderr)

def calculate_pwm(temp):
    """根据温度计算目标 PWM 值（线性映射）"""
    if temp <= TEMP_MIN:
        return PWM_MIN
    elif temp >= TEMP_MAX:
        return PWM_MAX
    else:
        # 线性插值
        ratio = (temp - TEMP_MIN) / (TEMP_MAX - TEMP_MIN)
        return int(PWM_MIN + ratio * (PWM_MAX - PWM_MIN))

def main():
    # 检查 root 权限
    if os.geteuid() != 0:
        print("[错误] 此脚本需要 root 权限才能修改风扇 PWM 节点，请使用 sudo 运行！")
        sys.exit(1)

    print("初始化 NVML 库...")
    nvmlInit()
    
    device_count = nvmlDeviceGetCount()
    if device_count < 3:
        print(f"[警告] 检测到 GPU 数量为 {device_count}，少于预期的 3 张 A2！")

    # 缓存 GPU 句柄
    handles = [nvmlDeviceGetHandleByIndex(i) for i in range(min(3, device_count))]
    
    print(f"成功挂载 {len(handles)} 张 Tesla A2，开始智能温控循环 (Ctrl+C 退出)...\n")

    # 记录上一次的 PWM 值，用于平滑过渡，避免转速剧烈跳变
    last_pwm_0 = -1
    last_pwm_12 = -1

    try:
        while True:
            # 1. 轻量化直读所有 A2 的温度和功耗
            gpu_data = []
            for i, handle in enumerate(handles):
                temp = nvmlDeviceGetTemperature(handle, NVML_TEMPERATURE_GPU)
                power = nvmlDeviceGetPowerUsage(handle) / 1000.0  # mW 转 W
                gpu_data.append({"id": i, "temp": temp, "power": power})

            # 2. 计算 GPU 0 的风扇转速 (独占 pwm4)
            temp_0 = gpu_data[0]["temp"]
            target_pwm_0 = calculate_pwm(temp_0)

            # 3. 计算 GPU 1 和 GPU 2 的风扇转速 (共享 pwm3，取两者中的最高温)
            temp_1 = gpu_data[1]["temp"]
            temp_2 = gpu_data[2]["temp"] if len(gpu_data) > 2 else temp_1
            max_temp_12 = max(temp_1, temp_2)
            target_pwm_12 = calculate_pwm(max_temp_12)

            # 4. 仅在 PWM 有显著变化时写入（减少系统调用开销）
            if target_pwm_0 != last_pwm_0:
                write_pwm(PWM_PATH_GPU0, target_pwm_0)
                last_pwm_0 = target_pwm_0

            if target_pwm_12 != last_pwm_12:
                write_pwm(PWM_PATH_GPU12, target_pwm_12)
                last_pwm_12 = target_pwm_12

            # 5. 终端美观打印当前状态
            timestamp = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            print(f"[{timestamp}]")
            print(f"  > GPU 0 (PWM4 -> {target_pwm_0:3d}): 温度 {temp_0:2d}°C | 功耗 {gpu_data[0]['power']:5.2f}W")
            if len(gpu_data) > 1:
                print(f"  > GPU 1 (PWM3 -> {target_pwm_12:3d}): 温度 {temp_1:2d}°C | 功耗 {gpu_data[1]['power']:5.2f}W")
            if len(gpu_data) > 2:
                print(f"  > GPU 2 (PWM3 -> {target_pwm_12:3d}): 温度 {temp_2:2d}°C | 功耗 {gpu_data[2]['power']:5.2f}W")
            print("-" * 50)

            time.sleep(POLL_INTERVAL)

    except KeyboardInterrupt:
        print("\n用户终止脚本，正在安全退出...")
    finally:
        nvmlShutdown()

if __name__ == "__main__":
    main()
