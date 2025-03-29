.. _jetpack_sdk:

============
JetPack SDK
============

NVIDIA JetPack SDK是构建AI应用的全面解决方案，所有的Jetson模块和开发套件都得到JetPack SDK的支持。

JetPack SDK包括最新的Linux驱动软件包(Linux Driver Package, L4T)的Linux操作系统以及CUDA-X加速库和API，可以用于深度学习，视觉结算，加速计算和多媒体。JetPack SDK也包含了案例、文档和开发工具用于计算主机和开发套件，以及支持高级SDK如用于流视频分析的DeepStream和用于机器人的Issac。

.. note::

   L4T 即Linux for Tegra：Tegra是NVIDIA推出的基于 :ref:`arm` 架构通用处理器(CPU)品牌，NVIDIA称为"Computer on a chip"(片上计算机)，能够为便携设备提供高性能、低功耗体验。

   Tegra在中国使用的中文名是 "图睿" ，是NVIDIA(英伟达)Tegra品牌推广使用。

JetPack 4.4
============

JetPack 4.4是最新的生产发行版，支持所有Jetson型号。关键特性包括支持Jetson Xavier NX以及CUDA，TensorRT和cuDNN的最新生产版本。

.. note::

   `Jetson Download Center <https://developer.nvidia.com/embedded/downloads>`_ 提供了JetPack 4.4下载资源。

安装JetPack套件
----------------

有两种方式安装JetPack套件：

- 使用SD卡镜像方式：请参考 :ref:`jetson_nano_startup` 完成Jetson Nano操作系统的安装以及工作室的各种优化配置以方便开发：
  - :ref:`jetson_xfce4`
  - :ref:`jetson_remote`
  - :ref:`jetson_xpra`
  - :ref:`jetson_usb_hd`
  - :ref:`linux_tether_vpn`

- 使用NVIDIA SDK Manager进行软件安装:

提供了极为方便的软件包选择和安装，不再需要手工操作就能够完成软件的下载和安装，是最为简单容易的开发环境部署方案。

.. note::

   不过，作为 :ref:`linux` 爱好者，折腾始终是冯妇之好，所以我还是采用了镜像安装，然后通过 :ref:`apt` 手工进行软件环境安装部署。

JetPack的关键特性
====================

OS
----

JetPack的生产版本以稳定为主，选择了Ubuntu 18.04 LTS版本，整个软件生态都是围绕这个长期支持版本展开，所以轻易不要做跨版本升级(建议 **不要** 升级 :ref:`jetson_ubuntu_20.04` )

CUDA
-------

.. note::

   出于稳定，我采用了 JetPack 4.4 官方稳定生产版本 `CUDA Toolkit v10.2.89 <https://docs.nvidia.com/cuda/archive/10.2/cuda-toolkit-release-notes/index.html>`_

- 检查CUDA版本(JetPack 4.4内建了CUDA稳定版本仓库配置)::

   # 检查CUDA版本:可以看到 stable 10.2.89-1 arm64
   apt list | grep cuda-core

输出显示::

   cuda-core-10-2/unknown,stable,now 10.2.89-1 arm64

不过提示::

   WARN: Package cuda-core-10-2 has been deprecated.
         Please install cuda-compiler-10-2 instead.

.. note::

   实际上已经完成了安装，包括 ``cuda-core`` 和 ``cuda-compiler`` 都完成了安装。在 ``/usr/local/cuda-10-2`` 有完整安装目录。

   详细安装CUDA请参考 :ref:`jetson_cuda`

参考
=====

- `NVIDIA JetPack SDK官方介绍 <https://developer.nvidia.com/embedded/jetpack>`_
- `NVIDIA CUDA Installation Guide for Linux <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html>`_
