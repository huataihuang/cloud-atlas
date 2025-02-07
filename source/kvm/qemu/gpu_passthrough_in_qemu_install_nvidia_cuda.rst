.. _gpu_passthrough_in_qemu_install_nvidia_cuda:

=====================================================
QEMU运行GPU passthrough的虚拟机安装NVIDIA CUDA
=====================================================

参考 :ref:`install_nvidia_linux_driver_in_ovmf_vm` 积累的经验，我在 :ref:`blfs_qemu` 环境中继续为 :ref:`run_debian_gpu_passthrough_in_qemu` 安装NVIDIA Linux驱动，这样构建成一个能够使用GPU加速的机器学习环境，为后续 :ref:`deep_learning` 做准备。

:ref:`run_debian_gpu_passthrough_in_qemu` 启动 ``vfio-pci`` 配置的虚拟机:

.. literalinclude:: run_debian_gpu_passthrough_in_qemu/d2l_run_vnc
   :caption: 运行UEFI虚拟机(使用VNC)
   :emphasize-lines: 10

.. note::

   本文实践是在 :ref:`run_debian_gpu_passthrough_in_qemu` 直接运行CUDA

   如果是 :ref:`qemu_docker_tesla_t10` ，则虚拟机中只执行 :ref:`install_nvidia_linux_driver_in_ovmf_vm`

准备工作
========

- 在没有安装NVIDIA Linux驱动之前，检查系统日志可以看到操作系统默认加载了开源的 ``nouveau`` ，但是加载 ``nvidia/tu102`` firmware失败:

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/dmesg_before_cuda
   :caption: 安装CUDA驱动之前系统日志

安装
=======

- 根据不同发行版在 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_ 选择对应的 :ref:`cuda_repo` ，这里针对 :ref:`debian` ``12`` 安装仓库配置如下

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/cuda_toolkit_debian_repo
   :caption: 在 :ref:`debian` 12操作系统添加NVIDIA官方软件仓库配

排查
=========

只安装 ``cuda-toolkit`` 没有安装 ``cuda-drivers``
---------------------------------------------------

我最初只安装了 ``cuda-toolkit`` ，完成后重启系统，检查 ``dmesg -T`` 输出:

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/dmesg_nouveau_error
   :caption: 显示没有正确加载NVIDIA驱动，依然是 ``nouveau`` 并且提示firmware加载失败，电源没有连接好?

我发现我搞错了，原来需要先安装 ``cuda-drivers`` 再安装 ``cuda-toolkit`` (或者两个一起安装?)，两者并没有包含关系。不安装 ``cuda-drivers`` 会导致主机只使用了开源驱动 ``nouveau`` ，无法正确使用CUDA。

所以补充安装 ``cuda-drivers`` 然后再次重启(前文已经修订正确): 安装 ``cuda-drivers`` 之后，在终端控制台会看到提示驱动加载版本信息:

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/cuda-drivers_version
   :caption: 安装 ``cuda-drivers`` 之后，控制台提示版本信息

``Failed to allocate NvKmsKapiDevice`` 报错
----------------------------------------------

安装 ``cuda-drivers`` 驱动之后，重启系统，在终端看到报错:

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/cuda-drivers_nvidia_drm_error
   :caption: ``nv_drm_load`` 加载失败

由于之前在 :ref:`install_nvidia_linux_driver_in_ovmf_vm` 经验: 需要调整虚拟机内核参数 ``pci=realloc`` ，所以尝试修订:

.. literalinclude:: ../iommu/install_nvidia_linux_driver_in_ovmf_vm/grub
   :caption: 修订 ``/etc/default/grub`` 添加 ``pci=realloc`` 参数
   :emphasize-lines: 2

好像不是这个原因

检查 ``dmesg -T`` 显示有一个 ``uncorrectable ECC error detected`` :

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/dmesg_nvidia_drm_error
   :caption: dmesg中显示 ``uncorrectable ECC error``
   :emphasize-lines: 13

这个 ``uncorrectable ECC error`` 看起来是 VRAM 存在ECC校验硬件错误了，情况和 NVIDIA 论坛 `Problems with A100 and Ubuntu 22.04 <https://forums.developer.nvidia.com/t/problems-with-a100-and-ubuntu-22-04/275205>`_ 相似，硬件异常。





