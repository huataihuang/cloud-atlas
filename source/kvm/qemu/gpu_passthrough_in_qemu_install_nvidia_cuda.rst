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

**还存在疑惑**

我尝试将 :ref:`tesla_t10` 从 :ref:`hpe_dl360_gen9` 的 ``PCIe 3`` 插槽换到 ``PCIe 1`` 

一点乌龙
---------

这里有点乌龙，我忘记之前 :ref:`pcie_bifurcation` 将 ``PCIe 1`` 分为2个，结果发现 :ref:`tesla_t10` 在这种 :ref:`pcie_bifurcation` 通过 ``vfio-pci`` passthrough到虚拟机内部，执行启动会出现如下报错:

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/pcie_bifurcation_error
   :caption: 忘记关闭 :ref:`pcie_bifurcation` 导致的qemu GPU passthrough虚拟机启动报错

:ref:`tesla_t10` 插槽换到 ``PCIe 1``
-------------------------------------

将 :ref:`hpe_dl360_gen9` 的系统BIOS恢复默认重新设置后，关闭了 :ref:`pcie_bifurcation` ，现在 :ref:`tesla_t10` 插槽在 ``PCIe 1`` ，重新通过vfio-pci直接passthrough到虚拟机内部。这次VM启动后观察，发现同样报 ``uncorrectable ECC error`` :

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/dmesg_nvidia_drm_error_pcie1
   :caption: :ref:`tesla_t10` 更换到 ``PCIe1`` 但虚拟机启动dmesg还是显示 ``uncorrectable ECC error``
   :emphasize-lines: 13

另外，观察到物理主机的控制台上显示报错:

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/nmi_iock_error
   :caption: 物理主机控制台报错显示 NMI IOCK error

改为物理主机使用 :ref:`tesla_t10` 对比
===========================================

由于我是在淘宝上购买的二手 :ref:`tesla_t10` ，所以硬件质量不能保证。但是我也不能确定是不是我的使用虚拟化运行问题，所以改为直接使用 :ref:`debian` 物理主机来使用这块 :ref:`tesla_t10` 。我甚至还重装了一遍 :ref:`debian`

重启系统后，使用 ``lspci -vvv`` 可以看到这块 :ref:`tesla_t10` 使用了对应的nvidia驱动

但是，系统 ``dmesg`` 日志还是显示 ``uncorrectable ECC error detected`` :

.. literalinclude:: gpu_passthrough_in_qemu_install_nvidia_cuda/host_dmesg_error
   :caption: 物理主机使用 :ref:`tesla_t10` 依然存在报错
   :emphasize-lines: 75-80

参考NVIDIA官方文档 `Xid Errors <https://docs.nvidia.com/deploy/xid-errors/index.html>`_ 其中  Xid Errors => ``140 Unrecovered ECC Error`` 表示 ``GPU driver has observed uncorrectable errors in GPU memory, in such a way as to interrupt the GPU driver’s ability to mark the pages for dynamic page offlining or row remapping``       

**很不幸，这次实践最后没有完成** :ref:`tesla_t10` 硬件异常，最后退还给淘宝卖家了。等以后有机会再做探索...
