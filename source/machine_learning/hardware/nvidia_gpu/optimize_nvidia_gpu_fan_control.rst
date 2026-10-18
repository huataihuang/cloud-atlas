.. _optimize_nvidia_gpu_fan_control:

===================================
优化NVIDIA GPU散热风扇控制
===================================

在 :ref:`tesla_a2_idle_power_fluctuation` 排查发现单纯使用 ``nvidia-smi`` 对GPU的查询压力过大，影响idle的功率波动，所以重新尝试更好的查询和控制风扇方法。

- 检查系统PWM接口:

.. literalinclude:: nvidia_gpu_fan_control/pwm_enable
   :caption: 检查哪些有可以搜供控制的PWM

输出显示

.. literalinclude:: optimize_nvidia_gpu_fan_control/pwm_enable_output
   :caption: 显示PWM

根据验证检查，当前我的 :ref:`tesla_a2` 分别连接SYS FAN接口如下：

  - GPU 0: ``/sys/class/hwmon/hwmon2/pwm4``
  - GPU 1 和 2: ``/sys/class/hwmon/hwmon2/pwm3``

风扇转速动态调整脚本
=====================

gemini提供了一个动态调整风扇转速的脚本，通过 ``pynvml`` 库来获取GPU温度和功耗信息来调整风扇转速:

  - **轻量级低开销直读** : 使用 pynvml 直接从内存中的驱动缓存读取温度和功耗，不会因为高频查询而唤醒处于 ``P8`` 节能状态的 Tesla A2
  - **多卡策略优化** : 由于 1 号和 2 号 A2 共享同一个风扇接口（ ``pwm3`` ），脚本会自动取这两张卡中的最高温度作为温控基准，确保任何一张卡都不会过热
  - **安全平滑的控制逻辑** : 内置了阶梯/线性温控映射，并且带有防止风扇频繁突变的抗抖动机制

- 首先安装 ``pynvml`` 库:

.. literalinclude:: optimize_nvidia_gpu_fan_control/install_pynvml
   :caption: 安装 ``pynvml`` 库

- ``/usr/local/bin/gpu_fan_control.py`` 脚本:

.. literalinclude:: optimize_nvidia_gpu_fan_control/gpu_fan_control.py
   :language: python
   :caption: 改进的温控脚本

脚本说明:

- **绝对轻量** : 通过 ``pynvml`` 直接获取数据，整个循环中不会触发任何外部 shell 进程（如 ``nvidia-smi`` ），从而保证了 3 张 A2 能够安稳地待在 ``P8`` 节能状态（5-6W），不会被监控脚本惊醒。
- **安全映射 (calculate_pwm)** :

  - 当显卡处于轻载、温度低于 35°C 时，PWM 会被锁定在设定的下限（例如 30，保证风扇低转速静音或维持基本气流）
  - 当温度线性上升到 75°C（例如开始跑大模型推理）时，PWM 会平滑拉满到 255（全速散热）

- **智能防抖 (last_pwm)** : 脚本内部记录了上一次下发的 ``PWM`` 值。如果温度在上下 1°C 以内微幅晃动，计算出来的 PWM 值不变，脚本就不会重复向 ``/sys/class/hwmon/...`` 节点写文件，有效避免了风扇转速因为小幅温度波动而剧烈调整

运行和验证
----------

- 在终端直接运行脚本: ( ``chmoe +x /usr/local/bin/gpu_fan_control.py`` ):

.. literalinclude:: optimize_nvidia_gpu_fan_control/run
   :caption: 终端运行脚本

- 为了能够给GPU添加压力，在系统中安装一个ffmpeg来测试:

.. literalinclude:: optimize_nvidia_gpu_fan_control/load
   :caption: 添加压力

另外一种加压方式是使用 ``torch`` ，但是安装依赖非常多 ``sudo apt install python3-torch`` 大约需要1.5G空间。这种 **使用 Python 结合 PyTorch 运行一个持续的矩阵乘法死循环** 更能模拟大模型的负载:

.. literalinclude:: optimize_nvidia_gpu_fan_control/torch
   :caption: 测试压力

给 GPU 1 或 GPU 2 加压，只需要把代码里的 cuda:0 改为 cuda:1 或 cuda:2 即可

服务设置
---------

- 创建一个 systemd 服务配置文件 ``/etc/systemd/system/gpu-fan-control.service``

.. literalinclude:: optimize_nvidia_gpu_fan_control/gpu-fan-control.service
   :caption: 配置服务 ``/etc/systemd/system/gpu-fan-control.service``

- 启用并启动服务

.. literalinclude:: optimize_nvidia_gpu_fan_control/systemctl
   :caption: 启动服务

- 验证服务:

.. literalinclude:: optimize_nvidia_gpu_fan_control/status
   :caption: 检查服务

输出显示服务正常运行

.. literalinclude:: optimize_nvidia_gpu_fan_control/status_output
   :caption: 检查服务可以看到运行状态

- 可以通过标准输出日志检查控制输出和温度、功耗日志

.. literalinclude:: optimize_nvidia_gpu_fan_control/log
   :caption: 检查日志

参考
=======

- gemini
