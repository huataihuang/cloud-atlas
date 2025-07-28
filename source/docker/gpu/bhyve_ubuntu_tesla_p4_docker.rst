.. _bhyve_ubuntu_tesla_p4_docker:

================================================
Bhyve环境Ubuntu虚拟机运行Tesla P4 GPU的Docker
================================================

我曾经想在 :ref:`pi_5` 的硬件上通过 :ref:`pi_5_pcie_m.2_ssd` 转接卡方式连接 :ref:`tesla_p4` 来实现一个低功耗 :ref:`machine_learning` 环境，但是遇到了不少挫折:

- :ref:`nvidia-driver_pi_os` 实践验证无法正常编译CUDA driver的内核模块
- :ref:`nvidia_p4_pi_docker` 回归到标准版Ubuntu确实能够完成CUDA driver安装，但是很不幸 :ref:`pi_5` 硬件无法支持外接 :ref:`nvidia_gpu` 惨淡失败

我回归到标准的x86硬件环境，采用组装台式机来运行 :ref:`freebsd` 操作系统，计划构建一个 :ref:`freebsd_machine_learning` 环境:

- 采用 :ref:`bhyve` 虚拟化来运行 :ref:`ubuntu_linux` 服务器
- 构建 :ref:`docker_gpu` 环境的单GPU到多GPU的 :ref:`llm` 推理
- 最终构建 :ref:`kubernetes` 调度运行

本文是开始的第一步，也就是为 :ref:`bhyve_nvidia_gpu_passthru` 运行的Ubuntu虚拟机 :ref:`install_cuda_ubuntu`

准备工作
==============

- 启动虚拟机后检查 ``dmesg`` 此时因为还没有安装 CUDA driver，所以看到的驱动是 ``nouveau`` ::

   [Mon Jul 28 06:01:24 2025] nouveau 0000:00:06.0: NVIDIA GP104 (134000a1)

- 采用 :ref:`debian_init` 纯后台服务器系统安装开发工具的方式(安装 ``build-essential`` 为主)

.. literalinclude:: ../../linux/debian/debian_init/debian_init_vimrc_dev
   :caption: 安装纯后台开发工具

- CUDA驱动需要内核头文件以及开发工具包来完成内核相关的驱动安装，因为内核驱动需要根据内核进行编译

安装 **linux-headers** :

.. literalinclude:: nvidia_p4_pi_docker/linux-headers
   :caption: 安装inux-headers

安装CUDA driver
====================

- 从NVIDIA官方提供 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_ 选择 ``linux`` => ``x86_64`` => ``Ubuntu`` => ``24.04`` => ``deb(network)``

.. literalinclude:: bhyve_ubuntu_tesla_p4_docker/cuda_driver_debian_ubuntu_repo_install
   :caption: Debian/Ubuntu使用NVIDIA官方软件仓库安装CUDA驱动

- 安装驱动 ``cuda-driver`` :

.. literalinclude:: ../../machine_learning/hardware/nvidia_gpu/install_nvidia_linux_driver/cuda_driver_debian_ubuntu_repo_install
   :language: bash
   :caption: Debian/Ubuntu使用NVIDIA官方软件仓库安装CUDA驱动

- 重启虚拟机操作系统

检查
======

- 重启后检查pci设备 ``lspci`` 显示输出 :ref:`tesla_p4` 如下:

.. literalinclude:: bhyve_ubuntu_tesla_p4_docker/lspci
   :caption: ``lspci`` 显示设备
   :emphasize-lines: 4

检查设备 ``00:06.0`` 详情 ``lspci -v -s 00:06.0`` :

.. literalinclude:: bhyve_ubuntu_tesla_p4_docker/lspci_p4
   :caption: ``lspci`` 显示设备 ``Tesla P4`` 驱动是 ``nvidia`` (刚才安装的官方驱动)
   :emphasize-lines: 10

异常
-------

- 执行 ``nvidia-smi`` 检查NVIDIA设备，发现异常(没有发现设备)::

   No devices were found

- 检查 ``dmesg | grep -i nvidia`` 日志看到了奇怪的现象:

.. literalinclude:: bhyve_ubuntu_tesla_p4_docker/nvida-drm_error
   :caption: 系统日志显示 ``nvidia-drm`` 加载驱动是不能分配 ``NvKmsKapiDevice``
   :emphasize-lines: 11,12

- 尝试回滚了一个版本( 575 -> 570 )，但是问题依旧(参考 `Ubuntu 22.04.1 LTS, RTX 3060Ti, Failed to allocate NvKmsKapiDevice <https://askubuntu.com/questions/1436629/ubuntu-22-04-1-lts-rtx-3060ti-failed-to-allocate-nvkmskapidevice>`_ )

.. literalinclude:: bhyve_ubuntu_tesla_p4_docker/rollback_nvidia-driver
   :caption: 回滚一个版本

可能还是要回到 :ref:`bhyve_nvidia_gpu_passthru` 寻求解决方案
