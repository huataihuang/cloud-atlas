.. _nvidia-smi:

======================
nvidia-smi
======================

NVML
=======

``nvidia-smi`` 底层使用了 `NVIDIA Management Library (NVML) <https://developer.nvidia.com/nvidia-management-library-nvml>`_ (基于 C 的 API，用于监视和管理 NVIDIA GPU 设备的各种状态)。NVML提供了对通过 nvidia-smi 公开的查询和命令的直接访问，NVML运行时(runtime)随NVIDIA显示驱动一起提供，SDK提供头文件、stub libraries 和 示例程序，旨在构建第三方应用程序平台。

`nvidia-ml-py <https://pypi.org/project/nvidia-ml-py/>`_ 提供了Python绑定的 `NVIDIA Management Library (NVML) <https://developer.nvidia.com/nvidia-management-library-nvml>`_ ，可以方便开发

:ref:`nvidia-smi_nvlink` 可以提供 :ref:`nvidia_nvlink` 的运行状态以及功能、计数，方便构建自己的 :ref:`prometheus_nvlink`

参考
======

- `NVIDIA Management Library (NVML) <https://developer.nvidia.com/nvidia-management-library-nvml>`_
- `NVIDIA System Management Interface SMI <https://developer.nvidia.com/nvidia-system-management-interface>`_
- `NVIDIA GPU Debug Guidelines <https://docs.nvidia.com/deploy/gpu-debug-guidelines/index.html>`_ 提供了debug指南，可以使用工具进行诊断
- `DCGM initialization error #222 <https://github.com/NVIDIA/gpu-operator/issues/222>`_ 提供了一些诊断案例
- `Explained Output of Nvidia-smi Utility <https://medium.com/analytics-vidhya/explained-output-of-nvidia-smi-utility-fc4fbee3b124>`_ 解释输出内容
