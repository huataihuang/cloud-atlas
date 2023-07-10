.. _nvidia_gpu_mem_clock:

==============================
NVIDIA GPU核心和显存的主频控制
==============================

在构建 :ref:`think_server_fanless` 我除了考虑 采用 :ref:`cpufreq` 的 ``powersave`` governor来降低CPU功耗，同时也想探索一下GPU主频的管理。

参考
======

- `nvidia-smi: Control Your GPUs <https://www.microway.com/hpc-tech-tips/nvidia-smi_control-your-gpus/>`_
- `How to set gpu clock using nvidia-smi <https://forums.developer.nvidia.com/t/how-to-set-gpu-clock-using-nvidia-smi/115854>`_
- `Advanced API Performance: SetStablePowerState <https://developer.nvidia.com/blog/advanced-api-performance-setstablepowerstate/>`_
