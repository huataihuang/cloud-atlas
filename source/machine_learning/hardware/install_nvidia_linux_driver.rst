.. _install_nvidia_linux_driver:

=======================
安装NVIDIA Linux驱动
=======================

:ref:`tesla_p10` 的GPU核心是Tesla，属于 ``Pascal`` 微架构

手工下载本地run安装(和发行版无关)
=======================================

.. note::

   我虽然下载了 ``.run`` 安装包，不过NVIDIA对主流发行版(RedHat/CentOS/Ubuntu/Debian/SUSE/OpenSUSE)都提供了软件仓库方式安装。所以，我最终实践还是直接在Ubuntu 22.04上采用官方软件仓库，见下文。

- 根据 :ref:`tesla_p10_spec` ，Tesla P10 / P40 以及 GeForce GTX 1080 Ti 硬件完全一致，只是在GPU主频和内存大小(及主频)上有细微差异，所以完全可以采用 `NVIDIA官方提供的 P40 驱动 <https://www.nvidia.com/download/index.aspx#>`_ :

.. figure:: ../../_static/machine_learning/hardware/tesla_p10_driver.png
   :scale: 80

驱动版本

.. csv-table:: Tesla P10驱动
   :file: install_nvidia_linux_driver/tesla_p10_linux_driver_spec.csv
   :widths: 40,60
   :header-rows: 1

.. note::

   底层物理主机仅需要参考本文安装NVIDIA Linux驱动，实际运行业务的虚拟机或容器才需要 :ref:`install_nvidia_cuda`

   本文在 :ref:`priv_cloud_infra` 的底层物理主机安装GPU的Linux驱动

NVDIA Tesla驱动安装
====================

参考
======

- `NVIDIA Driver Installation Quickstart Guide <https://docs.nvidia.com/datacenter/tesla/tesla-installation-notes/index.html>`_
