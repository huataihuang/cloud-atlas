.. _jetson_cuda:

===================
Jetson Nano安装CUDA
===================

CUDA是NVIDIA开发的并行计算平台和编程模型。CUDA通过释放图形处理单元(graphics processing unit, GPU)的性能极大增强了计算能力。

CUDA提供了一系列设计理念:

- 提供一个标准语言扩展集，例如C，实现了直接的并行计算算法。通过CUDA C/C++，开发者可以集中精力去实现算法的并行执行而不是重新开发并行算法实现。
- 支持混合计算：应用程序可以同时使用CPU和GPU。应用程序的部分工作在CPU上执行，并行部分则卸载到GPU上运行。这样CUDA可以增强现有程序。在内存空间，CPU和GPU视为不同设备，这个配置运行CPU和GPU协同计算，不需要竞争内存资源。

JetPack安装CUDA
==================

Jatson Nano通过JetPack安装L4T操作系统，就已经包含了完整的CUDA稳定版本，所以不需要如本文做完整的检查和安装。

Jetson Nano系统安装以后，在 ``/etc/apt/sources.list.d/cuda-10-2-local-10.2.89.list`` 包含了以下配置，表明软件仓库是本地安装的::

   deb file:///var/cuda-repo-10-2-local-10.2.89 /

这个本地软件仓库比较占用空间(1.9G)，必要时可以做迁移。

只需要简单执行::

   # 查看版本
   apt list | grep cuda-core
   # 按照系统提供的版本直接安装
   apt install cuda-core-10-2

完成安装以后执行以下命令检查::

   apt list --installed | grep cuda

可以看到系统已经安装完成的CUDA软件包组合。

.. note::

   以下是完整的CUDA安装指南，适合主流Linux发行版安装。仅供参考。

系统要求
=========

要在系统中使用CUDA，需要安装以下:

- 能够运行CUDA的GPU
- 提供gcc编译器和工具链的受支持的Linux
- NVIDIA CUDA Toolkit - 可以从 `CUDA Toolkit Downloads <https://developer.nvidia.com/cuda-downloads>`_ 下载

.. note::

   运行CUDA需要内核版本支持，请参考 `NVIDIA CUDA Installation Guide for Linux <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html>`_ 中有关内核版本要求

安装前准备
===========

- 验证CUDA兼容GPU::

   lspci | grep -i nvidia

对于Jetson Nano，输出显示::

   00:01.0 PCI bridge: NVIDIA Corporation Device 0fae (rev a1)
   00:02.0 PCI bridge: NVIDIA Corporation Device 0faf (rev a1)

请参考 `CUDA GPUs <https://developer.nvidia.com/cuda-gpus>`_ 文档列出的GPU进行验证核对。

- 验证是否是支持的Linux版本::

   uname -m && cat /etc/*release

对于Jetson Nano Jetpak 4.4输出::

   aarch64
   DISTRIB_ID=Ubuntu
   DISTRIB_RELEASE=18.04
   DISTRIB_CODENAME=bionic
   DISTRIB_DESCRIPTION="Ubuntu 18.04.5 LTS"
   # R32 (release), REVISION: 4.3, GCID: 21589087, BOARD: t210ref, EABI: aarch64, DATE: Fri Jun 26 04:38:25 UTC 2020
   NAME="Ubuntu"
   VERSION="18.04.5 LTS (Bionic Beaver)"
   ID=ubuntu
   ID_LIKE=debian
   PRETTY_NAME="Ubuntu 18.04.5 LTS"
   VERSION_ID="18.04"
   HOME_URL="https://www.ubuntu.com/"
   SUPPORT_URL="https://help.ubuntu.com/"
   BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
   PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
   VERSION_CODENAME=bionic
   UBUNTU_CODENAME=bionic

- 验证系统已经安装了gcc::

   gcc --version

- 验证系统已经安装了正确的内核头部和开发包

CUDA驱动需要Kernel headers和development packages用于驱动安装和驱动重新构建。需要确保安装的Kernel header和development package和当前内核匹配。

检查运行内核::

   uname -r

输出显示::

   4.9.140-tegra

上述显示的版本就是我们需要安装CUDA驱动对应的kernel headers和development packages。

RHEL7/CentOS7安装::

   sudo yum install kernel-devel-$(uname -r) kernel-headers-$(uname -r)

Fedora/RHEL8/CentOS8安装::

   sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r)

OpenSUSE/SLES安装::

   sudo zypper install -y kernel-<variant>-devel=<version>

Ubuntu安装::

   sudo apt-get install linux-headers-$(uname -r)

选择安装方式
===============

CUDA Toolkit提供两种安装方式:

- 发行版软件包(RPM和Deb包)
- 发行版无关(runfile包)

建议使用 ``发行版软件包(RPM和Deb包)`` 进行安装::

   wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/sbsa/cuda-ubuntu1804.pin
   sudo mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600
   sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/sbsa/7fa2af80.pub
   sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/sbsa/ /"
   sudo apt-get update
   sudo apt-get -y install cuda


参考
=====

- `NVIDIA CUDA Installation Guide for Linux <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html>`_
- `How to to install cuda 10.0 on jetson nano separately ? <https://forums.developer.nvidia.com/t/how-to-to-install-cuda-10-0-on-jetson-nano-separately/82405>`_
