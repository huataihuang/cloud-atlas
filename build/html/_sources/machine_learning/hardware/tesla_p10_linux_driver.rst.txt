.. _tesla_p10_linux_driver:

=======================
Tesla P10 Linux驱动
=======================

:ref:`tesla_p10` 的GPU核心是Tesla，属于 ``Pascal`` 微架构:

- 根据 :ref:`tesla_p10_spec` ，Tesla P10 / P40 以及 GeForce GTX 1080 Ti 硬件完全一致，只是在GPU主频和内存大小(及主频)上有细微差异，所以完全可以采用 `NVIDIA官方提供的 P40 驱动 <https://www.nvidia.com/download/index.aspx#>`_ :

.. figure:: ../../_static/machine_learning/hardware/tesla_p10_driver.png
   :scale: 80

驱动版本

.. csv-table:: Tesla P10驱动
   :file: tesla_p10_linux_driver/tesla_p10_linux_driver_spec.csv
   :widths: 40,60
   :header-rows: 1

NVDIA Tesla驱动安装
====================

准备工作
--------

- 验证硬件是否支持 CUDA ::

   lspci | grep -i nvida

根据输出的信息，查询 `CUDA GPUs - Compute Capability <https://developer.nvidia.com/cuda-gpus>`_ 网站信息确认

- 验证是否是支持的Linux版本::

   uname -m && cat /etc/*release

确保采用了 ``x86_64`` 版本Linux (或者是 ``aarch64`` 的64位ARM版本，需要下载对应架构的驱动)

- 验证系统已经安装了gcc，以及对应版本::

   gcc --version

- 验证系统已经安装了正确的内核头文件和开发工具包:

CUDA驱动需要内核头文件以及开发工具包来完成内核相关的驱动安装，因为内核驱动需要根据内核进行编译。

对于 RHEL 7 /CentOS 7执行以下安装命令::

   sudo yum install kernel-devel-$(uname -r) kernel-headers-$(uname -r)

对于 Fedora / RHEL 8 / Rocky Linux 8 执行以下安装命令::

   sudo dnf install kernel-devel-$(uname -r) kernel-headers-$(uname -r)

对于OpenSUSE/SELES 执行以下安装命令::

   sudo zypper install -y kernel-default-devel=$(uname -r | sed 's/\-default//')

对于Ubuntu执行以下安装命令::

   sudo apt-get install linux-headers-$(uname -r)

- 如果要支持 :ref:`nvidia_gpudirect_storage` (GDS)，需要同时安装CUDA软件包和 MLNX_OFED软件包 (需要使用NVMe硬件) ，这样可以在直接内存访问(DMA)方式在GPU内存和存储之间传输数据，不需要经过CPU缓存: 这种直接访问路径可以增加系统带宽和降低延迟以及降低CPU负载




参考
======

- `NVIDIA Driver Installation Quickstart Guide <https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html>`_
