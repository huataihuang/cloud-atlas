.. _install_nvidia_container_toolkit_for_containerd:

============================================
为containerd安装NVIDIA Container Toolkit
============================================

准备工作
===========

- :ref:`install_nvidia_linux_driver` :

在部署NVIDIA Container Toolkit之前，首先要为Host主机/VM :ref:`install_nvidia_linux_driver` ，并且要求 NVIDIA Linux drivers 版本 >= 418.81.07

- 内核要求 > 3.10

- Docker >= 19.03

- NVIDIA GPU架构 >= Kepler

.. note::

   由于我之前已经在物理主机安装(演练)过一遍 :ref:`install_nvidia_linux_driver` ，所以采用相同方法在 :ref:`ovmf_gpu_nvme` 的虚拟机 ``z-k8s-n-1`` 安装 NVIDIA CUDA 驱动

:ref:`install_nvidia_linux_driver`
------------------------------------

- 根据不同发行版在 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_ 选择对应的 :ref:`cuda_repo` ，例如我的 :ref:`priv_cloud_infra` 采用了 Ubuntu 22.04 LTS，所以执行如下步骤在系统中添加仓库:

.. literalinclude:: ../../machine_learning/cuda/install_nvidia_cuda/cuda_toolkit_ubuntu_repo
   :language: bash
   :caption: 在Ubuntu 22.04操作系统添加NVIDIA官方软件仓库配置

- 安装 NVIDIA CUDA 驱动:

.. literalinclude:: ../../machine_learning/hardware/install_nvidia_linux_driver/cuda_driver_ubuntu_repo_install
   :language: bash
   :caption: 使用NVIDIA官方软件仓库安装CUDA驱动

这里安装过程提示不能支持 Secure Boot::

   Building initial module for 5.15.0-57-generic
   Can't load /var/lib/shim-signed/mok/.rnd into RNG
   40A7F3E73E7F0000:error:12000079:random number generator:RAND_load_file:Cannot open file:../crypto/rand/randfile.c:106:Filename=/var/lib/shim-signed/mok/.rnd
   ...
   Secure Boot not enabled on this system.
   Done.

- 重启操作系统，检查驱动安装::

   nvidia-smi

.. _nvidia_pci_passthrough_via_ovmf_pci_realloc:

NVIDIA passthrough via ovmf需要Host主机内核参数 ``pci=realloc``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在虚拟机内部 :ref:`install_nvidia_linux_driver` 遇到异常，设备没有初始化成功，从 ``dmesg -T`` 看到:

.. literalinclude:: install_nvidia_container_toolkit_for_containerd/dmesg_nvidia_pci_io_region_invalid
   :language: bash
   :caption: 虚拟机NVIDIA设备初始化失败，显示PCI I/O region错误
   :emphasize-lines: 5,6

这个问题在 `PCI passthrough via OVMF/Examples <https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF/Examples>`_ 找到案例解释，原来物理主机内核参数需要增加 ``pci=realloc`` ，否则就会导致类似错误::

   NVRM: This PCI I/O region assigned to your NVIDIA device is invalid: NVRM: BAR1 is 0M @ 0x0 (PCI:0000:0a:00.0)

所以修订 :ref:`ovmf_gpu_nvme` 物理主机内核参数添加 ``pci=realloc`` 并重启物理主机

参考
========

- `NVIDIA Cloud Native Documentation: Installation Guide >> containerd <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#containerd>`_
