.. _install_nvidia_linux_driver_ubuntu:

======================================
安装NVIDIA Linux驱动(Ubuntu)
======================================

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

参考
======

- `How to Install NVIDIA Drivers on Ubuntu 24.04 <https://linuxconfig.org/how-to-install-nvidia-drivers-on-ubuntu-24-04>`_
- `arch linux wiki: NVIDIA <https://wiki.archlinux.org/title/NVIDIA>`_
