.. _bhyve_nvidia_gpu_passthru_intpin_patch:

====================================================
使用INIPIN补丁在bhyve中实现NVIDIA GPU passthrough
====================================================

我在 :ref:`bhyve_nvidia_gpu_passthru` 实践中采用了 `bhyve Current state of bhyve Nvidia passthrough? <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/>`_ 讨论中提供的补丁，也就是向Guest传递不同的id字符串激活GPU的虚拟化功能。但是这个patch根据不同的硬件和Guest组合似乎需要调整，在我的 :ref:`tesla_p10` 环境实践没有成功。

参考 WanpengQian 网友提供的方法，我尝试 `bhyve: assign a valid INTPIN to NVIDIA GPUs <https://reviews.freebsd.org/D51892>`_ 补丁，即通过设置INT PIN寄存器的数值来实现这个直通虚拟化功能。本文记录实践过程

准备工作
=========

已完成 `在 bhyve 中运行 虚拟机 <https://docs.cloud-atlas.dev/zh-CN/architecture/virtual/bhyve/bhyve-vm>`_

patch源代码
=============

.. note::

   目前网上提供针对NVIDIA passthru的补丁是采用 `Backhoff自动化公司 freebsd-src <https://github.com/Beckhoff/freebsd-src/>`_ ( `德国倍福自动化有限公司 <https://baike.baidu.com/item/%E5%BE%B7%E5%9B%BD%E5%80%8D%E7%A6%8F%E8%87%AA%E5%8A%A8%E5%8C%96%E6%9C%89%E9%99%90%E5%85%AC%E5%8F%B8/6896839>`_ )分支 ``phab/corvink/<RELEASE>/nvida-wip`` 来进行补丁的

   所以这里源代码从 `Backhoff自动化公司 freebsd-src <https://github.com/Beckhoff/freebsd-src/>`_ 拉取

   我尝试过 :ref:`freebsd_build_from_source` FreeBSD官方源码 ``releng/14.3`` ，发现代码差异不能patch，再仔细看了  `bhyve Current state of bhyve Nvidia passthrough? <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/>`_ 讨论找到上述规律

- 从 `Backhoff自动化公司 freebsd-src <https://github.com/Beckhoff/freebsd-src/>`_ 拉取源码:

.. literalinclude:: bhyve_nvidia_gpu_passthru/src
   :caption: 下载 Backhoff 的 freebsd-src 源代码

- ``checkout`` 出 ``phab/corvink/14.2/nvidia-wip`` 分支:

.. literalinclude:: bhyve_nvidia_gpu_passthru/checkout
   :caption: ``phab/corvink/14.2/nvidia-wip`` 分支

- 从 `bhyve: assign a valid INTPIN to NVIDIA GPUs <https://reviews.freebsd.org/D51892>`_ ``Download Raw Diff`` 并对 ``bhyve`` 代码打补丁

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/patch_bhyve
   :caption: ``Download Raw Diff`` 并对 ``bhyve`` 代码打补丁

.. note::

   我经过尝试对比发现 `bhyve: assign a valid INTPIN to NVIDIA GPUs <https://reviews.freebsd.org/D51892>`_ 实际上是针对 FreeBSD官方 ``stable/15`` 或者 `Backhoff自动化公司 freebsd-src <https://github.com/Beckhoff/freebsd-src/>`_ ``phab/corvink/15.0/nvidia-wip`` (根据 ``usr.sbin/bhyve/amd64/Makefile.inc`` 判断)

   所以，我这里手工做了补丁修正，并生成一个针对 ``releng/14.3`` 的 :ref:`git_diff` 补丁 ``pci_passthru_quirks.patch.txt``

- 编译安装补丁以后的 ``bhyve`` :

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/build
   :caption: 编译补丁以后的 ``bhyve``

配置PCI passthru
=====================

- 检查 PCI 设备:

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/vm_passthru
   :caption: ``vm`` 检查 ``passthru`` 设备列表

输出显示 ``Tesla P10`` 的 ``BHYVE ID`` 是 ``1/0/0``

.. note::

   我分别测试了 :ref:`tesla_p10` 和 :ref:`tesla_p4` ，单独安装其中任一设备，都识别为 ``BHYVE ID`` 是 ``1/0/0`` ，所以下文案例共用步骤

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/vm_passthru_output
   :caption: ``vm`` 检查 ``passthru`` 设备列表: Tesla P10
   :emphasize-lines: 3

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/vm_passthru_output_p4
   :caption: ``vm`` 检查 ``passthru`` 设备列表: Tesla P4
   :emphasize-lines: 3

- 配置 ``/boot/loader.conf`` 屏蔽掉需要passthru的GPU:

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/loader.conf
   :caption: 屏蔽掉 :ref:`tesla_p10` 或 :ref:`tesla_p4` ``1/0/0`` 

- 重启系统，然后再次检查 ``vm passthru`` ，此时看到 ``Tesla P10`` / ``Tesla P4`` 的设备一列应该显示为 ``ppt0`` :

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/vm_passthru_output_ppt0
   :caption: 屏蔽掉 :ref:`tesla_p10` 之后显示为 ``ppt0``
   :emphasize-lines: 3

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/vm_passthru_output_ppt0_p4
   :caption: 屏蔽掉 :ref:`tesla_p4` 之后显示为 ``ppt0``
   :emphasize-lines: 3

- 修订 ``xdev`` 虚拟机配置 ``/zroot/vms/xdev/xdev.conf``

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/xdev.conf
   :caption: 配置 ``xdev`` 添加直通PCI设备 ``1/0/0`` 也就是 :ref:`tesla_p10` / :ref:`tesla_p4`
   :emphasize-lines: 11

安装CUDA驱动
===============

参考之前在 :ref:`install_cuda_ubuntu` 经验，也包括我之前 :ref:`bhyve_ubuntu_tesla_p4_docker` ，快速完成 ``cuda-driver`` 安装:

- 采用 :ref:`debian_init` 纯后台服务器系统安装开发工具的方式(安装 ``build-essential`` 为主)

.. literalinclude:: ../../../../linux/debian/debian_init/debian_init_vimrc_dev
   :caption: 安装纯后台开发工具

- CUDA驱动需要内核头文件以及开发工具包来完成内核相关的驱动安装，因为内核驱动需要根据内核进行编译

安装 **linux-headers** (不过直接安装  ``cuda-driver`` 也会自动依赖安装):

.. literalinclude:: ../../../../docker/gpu/nvidia_p4_pi_docker/linux-headers
   :caption: 安装inux-headers

- 从NVIDIA官方提供 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_ 选择 ``linux`` => ``x86_64`` => ``Ubuntu`` => ``24.04`` => ``deb(network)``

.. literalinclude:: ../../../../docker/gpu/bhyve_ubuntu_tesla_p4_docker/cuda_driver_debian_ubuntu_repo_install
   :caption: Debian/Ubuntu使用NVIDIA官方软件仓库安装CUDA驱动

- 安装驱动 ``cuda-driver`` :

.. literalinclude:: ../../../../machine_learning/hardware/nvidia_gpu/install_nvidia_linux_driver/cuda_driver_debian_ubuntu_repo_install
   :language: bash
   :caption: Debian/Ubuntu使用NVIDIA官方软件仓库安装CUDA驱动

- 重启虚拟机操作系统

:ref:`tesla_p4`
====================

- 日志报错

.. literalinclude:: bhyve_nvidia_gpu_passthru_intpin_patch/dmesg_nvram_error
   :caption: 启动日志中有 ``RmInitAdapter`` 报错

参考
======

- `bhyve: assign a valid INTPIN to NVIDIA GPUs <https://reviews.freebsd.org/D51892>`_
- `Bug 288848 - bhyve GPU passthru for NVIDIA not working <https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=288848>`_ 关于 ``origin/phab/corvink/14.2/nvidia-wip`` checkout以及补丁的讨论
