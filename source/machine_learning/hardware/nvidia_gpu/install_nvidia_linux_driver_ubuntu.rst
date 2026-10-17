.. _install_nvidia_linux_driver_ubuntu:

======================================
安装NVIDIA Linux驱动(Ubuntu)
======================================

安装590 ``-server`` 驱动
==========================

我之前 :ref:`install_nvidia_linux_driver` 实践中采用了官方仓库方式安装。Ubuntu提供了一个简单工具来查看最适合自己显卡的驱动器版本:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/devices
   :caption: 使用Ubuntu提供的工具来查找最适合的驱动版本

输出显示中标记为 ``recommanded`` 就是最推荐的驱动版本:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/devices_output
   :caption: 使用Ubuntu提供的工具来查找最适合的驱动版本，可以看到最适合的版本是 ``590``

需要注意的是 ``590`` 有3个版本 ``open`` , ``server`` 和 ``server-open`` :

- ``nvidia-driver-590-open`` 是NVIDIA 近年来主推的新架构

  - 内核部分开源：驱动分为两部分，一部分是闭源的用户态库（CUDA、OpenGL），另一部分是开源的内核模块
  - 支持对象：仅支持 Turing (图灵) 架构及以后的架构( :ref:`tesla_a2` 是 Ampere 架构完全支持)
  - 优势：与 Linux 内核（尤其是 Ubuntu 24.04 的新内核）集成更好，符合现代 Linux 发行版的安全标准，支持一些仅限开源模块的高级功能（如 GSP 固件管理）

- ``nvidia-driver-590-server`` 是服务器长期支持版

  - 稳定性优先：Server 版驱动不追求最新的游戏特性，而是专注于长时间运行的稳定性和兼容性
  - 更新频率低：它不会频繁更新，只有在修复重大 Bug 或安全漏洞时才会推送，适合 7x24 小时运行的服务器
  - 功能完整：它包含了数据中心显卡所需的所有管理工具（如 nvidia-smi 的完整功能）

对于服务器追求稳定，建议安装 ``-server`` 版本，如果要追求最新特性和性能，则接受Ubuntu建议安装 ``-open`` 版本。

如果接受默认 ``recommanded`` 则可以使用 ``ubuntu-drivers`` 工具的自动安装功能:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/autoinstall
   :caption: 接受默认建议自动安装

不过，我主要用于服务器上运行，追求稳定，并且 `arch linux wiki: NVIDIA <https://wiki.archlinux.org/title/NVIDIA>`_ 提到 ``nvidia-open`` 主要用于Blackwell和更新硬件，其中GSP firmware已知会导致Turing GPU的电源管理子优化系统问题，所以我感觉我的 :ref:`tesla_a2` 使用的Ampere架构采用 ``-server`` 版本可能更稳健:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/install
   :caption: 安装指定server版本

.. note::

   ``add-apt-repository ppa:graphics-drivers/ppa`` 命令可以为Ubuntu添加第三方维护的图形驱动仓库，提供了最新的NVIDIA beta驱动。在添加了第三方PPA仓库之后，同样使用 ``ubuntu-drivers devices`` 搜索和安装驱动，有可能对于桌面应用起到更大加速。

   此外也可以采用 :ref:`install_nvidia_linux_driver` 中官方仓库安装

- 安装完成后重启系统，并执行 ``nvidia-smi`` 确认GPU正确初始化

.. literalinclude:: install_nvidia_linux_driver_ubuntu/nvidia-smi_output
   :caption: 输出显示初始状态

卸载590驱动
=============

当我准备在台式机上准备同时使用 :ref:`tesla_a2` 和 :ref:`tesla_p10` 时候，系统提示当前安装的590版本驱动和P10不兼容，需要回退到580版本。所以执行

- 清理nvidia和cuda相关软件包:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/purge_nvidia
   :caption: 清理nvidia和cuda相关包

安装580驱动
================

- 如果执行 ``sudo ubuntu-drivers devices`` 出现报错提示 ``ERROR:root:aplay command not found`` 则表明刚才清理时候删除了 ``alsa-utils`` 软件包，该软件包提供了 ``aplay`` 播放工具(NVIDIA高清音频驱动和系统音频工具链存在依赖级联，强力清理是autoremove掉alsa-utils)，当使用 ``ubuntu-drivers devices`` 时会调用这个工具，所以可以通过补安装 ``alsa-utils`` 来恢复

.. literalinclude:: install_nvidia_linux_driver_ubuntu/install_580
   :caption: 安装指定nvidia-580 server版本

安装595 ``-server-open`` 驱动
===============================

2026年10月，我开始采用最新的 :ref:`ubuntu_linux` LTS Server 26.04版本，这个版本已经开始使用 :ref:`kernel` 7.0系列。

考虑到:

- Tesla A2 是一张标准的 Data Center (数据中心/服务器级) 显卡，没有视频输出接口（无 HDMI/DP），专为深度学习推理、AI 计算和虚拟化设计。
- ``nvidia-driver-xxx-server`` 是 NVIDIA 专门为服务器和数据中心 GPU 优化的分支。它在长效稳定性、虚拟化（vGPU）支持、系统内核崩溃防护以及数据中心工作负载调度上经过了更严格的验证。
- ``nvidia-driver-595-server`` (传统闭源内核模块)

  - 内核底层驱动由 NVIDIA 闭源编写
  - 生态最成熟，兼容性历经多年考验

- ``nvidia-driver-595-server-open`` (开源内核模块，推荐用于 **Ampere 及更新架构** )

  - 主要开源的是与内核交互的 RM 层，底层核心算子依然调用闭源驱动
  - 由于 A2 是 ``Ampere`` 架构（Compute Capability 8.6），官方从 ``R515`` 开始就完美支持开源内核模块
  - 现代 Linux 内核(7.0 内核或高版本 Generic 内核)对开源内核模块的集成度更高、配合更默契，不容易因为内核频繁升级导致 DKMS 编译失败

后续Ubuntu LTS会逐步提高Linux :ref:`kernel` 版本，并且未来NVIDIA主要发展 ``-open`` 驱动，所以我在最新的Ubuntu中选择采用 ``nvidia-driver-595-server-open`` 。

.. literalinclude:: install_nvidia_linux_driver_ubuntu/install_595
   :caption: 安装 ``nvidia-driver-595-server-open`` 驱动

.. note::

   我在 :ref:`nasse_c246` 安装3块 :ref:`tesla_a2` ，需要注意BIOS设置中关闭 :ref:`sr-iov` 来避免过多的VF设备内存分配失败。

在安装了驱动之后，就会发现 :ref:`tesla_a2` 的待机温度下降了很多:

.. literalinclude:: install_nvidia_linux_driver_ubuntu/nvidia-smi_output_a2
   :caption: ``nvidia-smi`` 输出显示Tesla A2的待机功率下降
   :emphasize-lines: 11,15,19

这是因为:

- :ref:`tesla_a2` 内部有一套复杂的微控制器（PMU）和电源状态机，当安装了官方闭源驱动，操作系统就会和GPU建立通讯
- **动态电源状态（P-States）被激活** GPU 拥有了像 CPU 一样精细的节能状态切换能力: 在 Idle（待机）状态下，核心频率、显存频率会降到最低，功耗直接跌至 ``5W - 6W`` 左右

.. note::

   由于安装在组装兼容机上，需要在 :ref:`tesla_a2` 上安装散热风扇，此时需要通过 :ref:`lm_sensor` 以及 :ref:`nvidia_gpu_fan_control` 来自动调整风扇转速。

参考
======

- `How to Install NVIDIA Drivers on Ubuntu 24.04 <https://linuxconfig.org/how-to-install-nvidia-drivers-on-ubuntu-24-04>`_
- `arch linux wiki: NVIDIA <https://wiki.archlinux.org/title/NVIDIA>`_
