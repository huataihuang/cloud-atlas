import time
import subprocess
import os

# ==================== 请根据实际测试修改以下参数 ====================
# 主板 SYS_FAN 对应的 PWM 节点路径
PWM_PATH = "/sys/class/hwmon/hwmon4/pwm3"
PWM_ENABLE_PATH = "/sys/class/hwmon/hwmon4/pwm3_enable"

def set_manual_mode():
    """开启主板风扇手动控制模式"""
    try:
        if os.path.exists(PWM_ENABLE_PATH):
            with open(PWM_ENABLE_PATH, 'w') as f:
                f.write('1')
    except Exception as e:
        print(f"设置手动模式失败: {e}")

def get_nvidia_max_temp():
    """读取 3 块 Tesla A2 的温度，并返回最高值"""
    try:
        output = subprocess.check_output(
            ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"],
            encoding='utf-8'
        )
        temps = [float(t.strip()) for t in output.strip().split('\n') if t.strip()]
        return max(temps) if temps else 40.0
    except Exception as e:
        # 读取失败时返回 60 作为安全防烧卡保护
        return 60.0

def set_pwm(value):
    """写入 PWM 值 (0 - 255)"""
    try:
        # 限制范围在 0 ~ 255
        val = max(0, min(255, int(value)))
        with open(PWM_PATH, 'w') as f:
            f.write(str(val))
    except Exception as e:
        print(f"写入 PWM 失败: {e}")

# 启动时先强制切为手动模式
set_manual_mode()

while True:
    max_temp = get_nvidia_max_temp()
    
    # 动态阶梯控温逻辑（可根据自己对噪音的接受度调整）
    if max_temp < 45:
        # 45℃ 以下：PWM 75（约 30% 转速，极静音保持微风）
        set_pwm(75)
    elif 45 <= max_temp < 60:
        # 45℃ - 60℃：PWM 120（约 47% 转速，中等压制）
        set_pwm(120)
    elif 60 <= max_temp < 72:
        # 60℃ - 72℃：PWM 180（约 70% 转速，风量增强）
        set_pwm(180)
    else:
        # 超过 72℃：PWM 255（100% 全速，防止热积累）
        set_pwm(255)
        
    time.sleep(4)
