.. _nvidia-driver_pi_os:

====================================================
树莓派安装NVIDIA驱动折腾笔记(归档)
====================================================

.. note::

   我在 :ref:`nvidia_p4_pi_docker` 实践走了弯路，在安装 ``nvidia-driver`` 步骤编译 :ref:`dkms` 内核模块时折腾了两天。为了精简 :ref:`nvidia_p4_pi_docker` 记录，我把这段安装驱动的过程汇总到本文作为一个学习实践的笔记。

   仅供参考

.. warning::

   在Raspberry Pi OS上安装 ``cuda-driver`` 没有成功!!!

   我在网上搜索树莓派上安装NVIDIA GPU的资料，发现几乎都是语焉不详或者步骤不清晰或矛盾，无法确定真正安装成功。所以我准备切换到标准版Ubuntu，重新开始安装 ``nvidia-driver``

:ref:`tesla_p4` 加电后再启动连接的 :ref:`pi_5` ，进入host主机系统后执行 ``lspci`` 命令可以看到识别出 :ref:`tesla_p4` :

.. literalinclude:: nvidia_p4_pi_docker/lspci
   :caption: 启动系统后检查识别的 :ref:`tesla_p4`
   :emphasize-lines: 5

Host主机安装 ``nvidia-driver``
==================================

如上文所述，在 :ref:`pi_5` Host主机上我规划部署 :ref:`docker` (作为 :ref:`kubernetes` 主机节点)，所以只需要安装 ``cuda-drivers`` 

.. note::

   在 :ref:`install_nvidia_linux_driver` 我曾经采用过两种方式安装 ``cuda-drivers`` :

   - 手工下载安装 `NVIDIA官方提供的 P40 驱动 <https://www.nvidia.com/download/index.aspx#>`_
   - 通过Linux发行版软件仓库方式安装NVDIA CUDA驱动

   本次实践我采用后者 **软件仓库方式**

准备工作
-----------

按照 :ref:`install_cuda_prepare` 检查和准备:

- 由于 :ref:`pi_5` 只有8GB内存，所以不建议启用 :ref:`above_4g_decoding` (应该也没有这个BIOS设置选项)
- 验证系统已经安装gcc以及对应版本:

.. literalinclude:: nvidia_p4_pi_docker/gcc
   :caption: 检查系统安装的gcc版本

输出显示目前系统安装了 ``gcc 12`` :

.. literalinclude:: nvidia_p4_pi_docker/gcc_output
   :caption: 检查系统安装的gcc版本显示是 ``gcc 12``

- CUDA驱动需要内核头文件以及开发工具包来完成内核相关的驱动安装，因为内核驱动需要根据内核进行编译。这里按照 :ref:`debian` / :ref:`ubuntu_linux` 安装对应内核版本的头文件包:

.. literalinclude:: nvidia_p4_pi_docker/linux-headers
   :caption: 安装内核版本对应的头文件包

我也参考 `Raspberry Pi Documentation: The Linux kernel#kernel-headers <https://www.raspberrypi.com/documentation/computers/linux_kernel.html#kernel-headers>`_ 安装 **树莓派专用linux-headers** :

.. literalinclude:: nvidia_p4_pi_docker/linux-headers-rpi
   :caption: 安装Raspberry Pi OS特定linux-headers

但是在后续 ``CUDA软件仓库`` 安装过程都出现相同的编译错误，所以看起来在 Raspberry Pi OS 安装 ``nvidia-driver`` 编译存在问题。

CUDA软件仓库
--------------

从NVIDIA官方提供 `NVIDIA CUDA Toolkit repo 下载 <https://developer.nvidia.com/cuda-downloads>`_

- 由于是 :ref:`pi_5` ARM架构，我选择了 ``Linux >> arm64-sbsa (Server Base System Architecture) >> Native >> Ubuntu >> 22.04 >> deb (network)``

  - Compilation 步骤可选 ``Native`` (只编译相同架构的代码)和 ``Cross`` (可编译不同架构代码)，我选择 ``Native``
  - Ubuntu版本选择 ``22.04`` 对应的是 :ref:`debian` 12 (bookworm)，如果选 Ubuntu 24.04 则对应的是debian 13

- 安装步骤:

.. literalinclude:: nvidia_p4_pi_docker/cuda_install
   :caption: 安装仓库

仓库安装 ``cuda-drivers``
----------------------------

.. note::

   使用软件仓库网络安装 ``cuda-drivers`` 需要主机安装好对应的 ``linux-headers``

.. literalinclude:: ../../machine_learning/hardware/nvidia_gpu/install_nvidia_linux_driver/cuda_driver_debian_ubuntu_repo_install
   :language: bash
   :caption: Debian/Ubuntu使用NVIDIA官方软件仓库安装CUDA驱动

安装过程会爱用 :ref:`dkms` 编译NVIDIA内核模块，并且会提示添加了 ``/etc/modprobe.d/nvidia-graphics-drivers.conf`` 来 ``blacklist`` 阻止加载冲突的 ``Nouveau`` 开源驱动，并且提示需要重启操作系统来完成驱动验证加载。

CUDA软件本地安装
---------------------

.. note::

   使用本地安装 ``cuda-drivers`` 需要本地安装好内核源代码，这里采用 `Raspberry Pi Documentation: The Linux kernel#Build the kernel <https://www.raspberrypi.com/documentation/computers/linux_kernel.html#building>`_ 下载Raspberry Pi 内核源代码

`JeffGeerling的网站上 Raspberry Pi PCIe Database#GPUs (Graphics Cards) <https://pipci.jeffgeerling.com/#gpus-graphics-cards>`_ 列出的NVIDIA显卡，他采用了下载最新驱动软件安装包方法，本地运行安装

- 下载最新的 `NVIDIA Linux-aarch64 (ARM64) Display Driver Archive <https://www.nvidia.com/en-us/drivers/unix/linux-aarch64-archive/>`_ 

- 本地安装:

.. literalinclude:: nvidia_p4_pi_docker/run_install
   :caption: 本地安装

本地安装会提示需要当前运行内核的源代码树，否则会报错

按照 `Raspberry Pi Documentation: The Linux kernel#Build the kernel <https://www.raspberrypi.com/documentation/computers/linux_kernel.html#building>`_ 下载Raspberry Pi 内核源代码:

.. literalinclude:: nvidia_p4_pi_docker/get_pi_kernel
   :caption: 下载树莓派系统的内核代码

.. warning::

   这里遇到一个运行 报错:

   .. literalinclude:: nvidia_p4_pi_docker/run_install_error
      :caption: 运行提示内核版本 ``version.h`` 不存在

   我感觉确实很难在 Raspberry Pi OS 上完成 ``nvidia-drivers`` 安装，网上的案例信息实际上都没有明确说明 Raspberry Pi OS 安装(没有详细步骤或者步骤存在矛盾)，所以我感觉需要切换到标准版本 Ubuntu 来完成

安装 ``cuda-drivers`` 报错: ``stdarg.h``
-----------------------------------------

我这里遇到报错(编译内核错误)

.. literalinclude:: nvidia_p4_pi_docker/cuda-drivers_dpkg_error
   :caption: 编译内核错误
   :emphasize-lines: 14

检查错误日志 ``/var/lib/dkms/nvidia/575.57.08/build/make.log`` 可以看到，显示缺少 ``stdarg.h`` :

.. literalinclude:: nvidia_p4_pi_docker/make.log
   :caption: 编译错误日志

这里提示 ``stdarg.h: No such file or directory`` ，看起来似乎指gcc自带的头文件: ``/usr/lib/gcc/aarch64-linux-gnu/12/include/stdarg.h``

在 `#include <stdarg.h> missing in 418.113 #46 <https://github.com/canonical/nvidia-graphics-drivers/issues/46>`_ 提到不同内核版本需要修订

.. literalinclude:: nvidia_p4_pi_docker/fix.c
   :caption: 修订报错代码的include部分

检查 ``stdarg.h`` 文件在哪里:

.. literalinclude:: nvidia_p4_pi_docker/find
   :caption: 查找 ``stdarg.h``

可以看到linux头文件确实在 ``linux/stdarg.h`` :

.. literalinclude:: nvidia_p4_pi_docker/find_output
   :caption: 查找 ``stdarg.h`` 输出显示 ``linux/stdarg.h``
   :emphasize-lines: 3,4

参考 `nvidia installer can't find stdarg.h #6 <https://github.com/NVIDIA/nvidia-installer/issues/6>`_ 建议在源代码header目录下创建 ``<linux/stdarg.h>`` 到 ``stdarg.h>`` 的软连接，感觉这个方法也好:

.. literalinclude:: nvidia_p4_pi_docker/link
   :caption: 创建 ``linux/stdarg.h`` 到 ``stdarg.h`` 的软连接

然后重新安装，则这个找不到 ``stdarg.h`` 的问题解决了(虽然还是有其他报错)

``cc1: some warnings being treated as errors``
----------------------------------------------

在解决了 ``stdarg.h`` 无法找到的问题之后，编译日志中出现大量报错，其中有很多行显示::

  cc1: some warnings being treated as errors

考虑到是不是WARNING被视为ERROR导致编译不通过，所以想修订 ``make`` 的 ``CFLAGS`` 配置。在 :ref:`gentoo_linux` 中，有一个全局的 ``/etc/make.conf`` 配置可以设置Gentoo的编译参数，那么Debian如何设置呢？

``CFLAGS=" -Wno-error=..."``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

makefile提供了一个参数可以将某些warning不视为error，举例刚才的编译日志中，很多WARNONG是 ``-Wmisssing-prototypes`` ，所以我需要忽略这个WARNING

则应该在 ``CFLAGS`` 中添加 ``-Wno-error=missing-prototypes``

修订配置的方法通常是在项目软件目录下修改 makefile ，例如:

.. literalinclude:: nvidia_p4_pi_docker/makefile
   :caption: 修改makefile添加CFLAGS

``dpkg-buildflags``
~~~~~~~~~~~~~~~~~~~~

``dpkg-buildflags`` 在package编译时返回build的flags，默认的配置定义在 ``/usr/local/etc/dpkg/buildflags.conf`` 。对应当前用户则是 ``$XDG_CONFIG_HOME/dpkg/buildflags.conf`` (默认的 ``$XDG_CONFIG_HOME`` 就是 ``$HOME/.config`` ，也就是当前用户的配置是 ``~/.config/dpkg/buildflags.conf``

不过，我发现我的情况不是对软件源代码包进行编译，具体参考 `How to override dpkg-buildflags CFLAGS? <https://stackoverflow.com/questions/11072724/how-to-override-dpkg-buildflags-cflags>`_ 。只有 ``apt-get source <pkg-name>`` 下载软件源代码包才使用这个 ``dpkg-buildflags`` 方法

修订 :ref:`dkms` 编译参数
------------------------------

注意到这个编译模块是 :ref:`dkms` ，参考 `building with clang rather than gcc #124 <https://github.com/dell/dkms/issues/124>`_ ，对于 dkms ，会使用一个 ``dkms.conf`` 来控制编译。所以我搜索了一下，发现在 ``/usr/src/nvidia-575.57.08/dkms.conf`` 但我没有找到修改方法参考

不过， ``grep`` 了一下 ``/usr/src/nvidia-575.57.08`` 源代码目录，发现在该目录下有一个 ``Kbuild`` 文件包含了 ``-Wno-error`` 配置，当前配置是:

.. literalinclude:: nvidia_p4_pi_docker/kbuild_origin
   :caption: 当前 ``Kbuild`` 配置 ``CFLAGS``
   :emphasize-lines: 7

参考
======

- `Using NVIDIA GPU within Docker Containers <https://marmelab.com/blog/2018/03/21/using-nvidia-gpu-within-docker-container.html>`_ (在安装 ``NVIDIA Container Toolkit`` 之前，先参考 `CUDA Installation Guide for Linux <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/>`_ 完成 ``cuda-driver`` 安装)
- `Enabling GPUs in the Container Runtime Ecosystem <https://devblogs.nvidia.com/gpu-containers-runtime/>`_
- **已废弃** `Build and run Docker containers leveraging NVIDIA GPUs <https://github.com/NVIDIA/nvidia-docker>`_
- `Installing the NVIDIA Container Toolkit <https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html>`_ 从2023年8月开始， ``nvidia-docker`` 已经被 ``NVIDIA Container Toolkit`` 替代，所以本文实践部署替代了之前的 :ref:`nvidia-docker`
- `How can I compile without warnings being treated as errors? <https://stackoverflow.com/questions/11561261/how-can-i-compile-without-warnings-being-treated-as-errors>`_ 和 `How to suppress all warnings being treated as errors for format-truncation <https://unix.stackexchange.com/questions/509384/how-to-suppress-all-warnings-being-treated-as-errors-for-format-truncation>`_ 提供了如何忽略某些WARNING的方法
- `Append to GNU 'make' variables via the command line <https://stackoverflow.com/questions/2129391/append-to-gnu-make-variables-via-the-command-line>`_ 如何设置makefile的CFLAGS
- `Configuration cflags compilation of debian <https://forums.debian.net/viewtopic.php?t=129182>`_ 建议使用 ``dpkg-buildflags`` 来调整编译参数，具体可以参考 `dpkg-buildflags man-pages <https://man7.org/linux/man-pages/man1/dpkg-buildflags.1.html>`_
- `How to override dpkg-buildflags CFLAGS? <https://stackoverflow.com/questions/11072724/how-to-override-dpkg-buildflags-cflags>`_
