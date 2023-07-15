.. _nvidia_gpu_mem_clock:

==============================
NVIDIA GPU核心和显存的主频控制
==============================

在构建 :ref:`think_server_fanless` 我除了考虑 采用 :ref:`cpufreq` 的 ``powersave`` governor来降低CPU功耗，同时也想探索一下GPU主频的管理: (如果必要的话)

- 查询GPU支持的核心主频和内存主频可以使用以下命令:

.. literalinclude:: nvidia_gpu_mem_clock/nvidia-smi_query-supported-clocks
   :caption: 查询GPU支持的主频及内存主频组合

我的 :ref:`tesla_p10` GPU计算卡输出如下:

.. literalinclude:: nvidia_gpu_mem_clock/nvidia-smi_query-supported-clocks_output
   :caption: 查询GPU支持的主频及内存主频组合，Tesla P10

- 设置固定的core和memory主频:

.. literalinclude:: nvidia_gpu_mem_clock/nvidia-smi_lock_gpu_mem_clocks
   :caption: 设置主频

- 重置主频:

.. literalinclude:: nvidia_gpu_mem_clock/nvidia-smi_reset_gpu_mem_clocks
   :caption: 重置主频

- 检查主频:

.. literalinclude:: nvidia_gpu_mem_clock/nvidia-smi_query_gpu_mem_clocks
   :caption: 查询主频

我的 :ref:`tesla_p10` 输出信息:

.. literalinclude:: nvidia_gpu_mem_clock/nvidia-smi_query_gpu_mem_clocks_output
   :caption: 查询主频输出, Tesla P10




参考
======

- `nvidia-smi: Control Your GPUs <https://www.microway.com/hpc-tech-tips/nvidia-smi_control-your-gpus/>`_
- `How to set gpu clock using nvidia-smi <https://forums.developer.nvidia.com/t/how-to-set-gpu-clock-using-nvidia-smi/115854>`_
- `Advanced API Performance: SetStablePowerState <https://developer.nvidia.com/blog/advanced-api-performance-setstablepowerstate/>`_
