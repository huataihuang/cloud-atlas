.. _bhyve_nvidia_gpu_passthru:

===============================================
在bhyve中实现NVIDIA GPU passthrough
===============================================

.. note::

   NVIDIA官方提供了 `FreeBSD x64 Graphics Driver Archive <https://www.nvidia.com/en-us/drivers/unix/freebsd-x64-archive/>`_ ，即最新的FreeBSD显卡驱动。但是很不幸，CUDA并不支持FreeBSD，所以无法直接将FreeBSD作为 :ref:`machine_learning` 平台。

.. warning::

   本文记录的通过补丁方式来解决NVIDIA GPU passthrough可能不是我遇到问题的解决方法:

   我使用了发行版原生的 ``bhyve`` ，也尝试了本文记录的补丁方式，但是都 **没有解决** :ref:`tesla_p10` passthrough 给 bhyve 虚拟机时无法启动虚拟机的问题
   
   但是我硬件改成 :ref:`tesla_p4` ，结果就成功启动了虚拟机，然而很不幸，不能正常初始化驱动，所以最终还是没有能够正常使用。目前使用了补丁版本( :strike:`我准备回滚到发行版本再重新尝试` )，但是我目前暂时放弃。准备等年底 RELEASE 15 再重新尝试。

   **目前我没有能够完成 bhyve NVIDIA GPU passthru**

我在尝试 :ref:`bhyve_pci_passthru_startup` 将 :ref:`tesla_p10` passthrough 给 bhyve 虚拟机，但是遇到无法启动虚拟机的问题，不论是直接使用 ``bhyve`` 命令还是通过 :ref:`vm-bhyve` 管理工具。这个问题困挠了我很久...

`GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_ 解释了为何网上说 "bhyve支持PCI设备passthrough，但是不支持GPU passthru" 是一个误解: 真实原因是NVIDIA驱动仅支持KVM信号的hypervisor，对于bhyve则需要补丁才行。

很不幸，我最终实践没有成功passthru :ref:`tesla_p10` ，但是同样GPU核心但是内存和频率降级的 :ref:`tesla_p4` 就非常成功使用。我感觉这两款NVIDIA GPU在处理hypvervisor时候有一些区别，目前我还没有找到如何驱动 :ref:`tesla_p10` passthru的方法。暂时先使用 :ref:`tesla_p4` 来做一些小模型的测试，后续有机会再尝试解决 :ref:`tesla_p10` passthru。

.. note::

   :ref:`bhyve_intel_gpu_passthru` 实现非常简单，标准方法操作就可以，不需要补丁

``vm-bhyve``
===============

.. note::

   使用 :ref:`vm-bhyve` 作为管理器来完成部署

- 安装 ``vm-bhyve``

.. literalinclude:: ../vm-bhyve/install_vm-bhyve
   :caption: 安装 ``vm-bhyve``

- 创建 ``vm-bhyve`` 使用的存储:

.. literalinclude:: ../vm-bhyve/zfs
   :caption: 创建虚拟机存储数据集

- 在 ``/etc/rc.conf`` 中设置虚拟化支持:

.. literalinclude:: ../vm-bhyve/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 支持虚拟化

- 在 ``/boot/loader.conf`` 添加:

.. literalinclude:: ../vm-bhyve/loader.conf
   :caption: ``/boot/loader.conf``

- 初始化:

.. literalinclude:: ../vm-bhyve/init
   :caption: 初始化

PCI passthru
===============

- 检查 PCI 设备:

.. literalinclude:: ../vm-bhyve/vm_passthru
   :caption: 检查可以passthrough的设备

- 配置 ``/boot/loader.conf`` 屏蔽掉需要passthru的GPU :

.. literalinclude:: bhyve_intel_gpu_passthru/loader.conf
   :caption: 屏蔽掉 :ref:`tesla_p10` ``1/0/0`` 和 Intel UHD Graphics P630 ``0/2/0``

- 重启系统

nvidia补丁(尝试一)
=====================

.. warning::

   我实践还存在问题，补丁和编译似乎没有问题，但是没有解决 passthru NVIDIA GPU 之后无法启动虚拟机的问题，VNC显示还是黑屏

   太奔溃了，我休息一下再想办法解决

- 参考 ` 26.6.3. Updating the Source <https://docs.freebsd.org/en/books/handbook/cutting-edge/#updating-src-obtaining-src>`_ 根据 ``uname -r`` 获取当前安装的RELEASE，例如 ``14.3-RELEASE`` ，则下载对应的源代码分支:

.. literalinclude:: ../../../build/freebsd_build_from_source/freebsd_src
   :caption: 获取 freebsd 源代码

- 下载补丁 :download:`nvidia.patch.txt <nvidia.patch.txt>` (或者下载 `原帖讨论中 c-c-c-c 提供的patch文件 <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/page-2>`_ ) 存放到 ``/usr/src`` 目录中

- 打上补丁:

.. literalinclude:: bhyve_nvidia_gpu_passthru/git_apply
   :caption: 打上nvidia补丁

- 编译和安装补丁过的内核:

.. literalinclude::  bhyve_nvidia_gpu_passthru/buildkernel
   :caption: 编译安装补丁过的内核

- 编译和安装 include, vmm, bhyve, bhyvectl, bhyveload:

.. literalinclude::  bhyve_nvidia_gpu_passthru/buildtools
   :caption: 编译安装include, vmm, bhyve, bhyvectl, bhyveloa

重启系统

nvidia补丁(尝试二)
=======================

`ZioMario提供了一个编译安装脚本 <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/page-4>`_ 我准备重新尝试一下

- 准备目录

.. literalinclude:: bhyve_nvidia_gpu_passthru/src
   :caption: 下载源代码

- 将下载的 :download:`setup.txt` :download:`build_branch.txt` :download:`build.txt` 存放到一个目录下，并将后缀名修订为 ``.sh`` ，然后执行:

.. literalinclude:: bhyve_nvidia_gpu_passthru/build
   :caption: 执行 build_branch.sh 脚本

.. note::

   到这里，我发现我的 :ref:`tesla_p4` 能够启动，但是 :ref:`tesla_p10` 不能启动虚拟机。不过 :ref:`bhyve_ubuntu_tesla_p4_docker` 还是遇到passthru的GPU无法初始化的问题。

   我可能还需要继续找寻方法:

   - `GPU passthrough with bhyve - Corvin Köhne - EuroBSDcon 2023 <https://www.youtube.com/watch?v=eurBCPj65oI>`_ 演讲者就是开发bhyve passthru的Corvin Köhne，上述补丁应该是他提供的。我准备仔细看看视频
   - 更换PCIe转接板，关闭 :ref:`pcie_bifurcation` 采用直接安装 :ref:`tesla_p10` (不太可能？)
   - 等待年底 RELEASE 15 重新尝试 ``bhyve passthru``

BIOS尝试
------------

google AI提到bhyve不支持Linux中使用的 ``pci=realloc`` 内核配置，建议设置 ``pci=realloc=off`` 。我尝试了在Ubuntu虚拟机中配置 ``pci=realloc`` 或 ``pci=realloc=off`` 都没有解决无法初始化 :ref:`tesla_p4` 驱动的问题，同样也没有启动 :ref:`tesla_p10` 的虚拟机。

我也尝试关闭 :ref:`above_4g_decoding` :

- 之前为了能够实现和 :ref:`dl360_gen9_large_bar_memory` 效果，我特意配置 :ref:`nasse_c246` BIOS 激活了:

  - ``Above 4G Decoding`` (在 Advanced 菜单中)
  - ``above 4GB mmio BIOS Assignment`` (在 chipset 菜单中)

- 上述两个 :ref:`above_4g_decoding` 不能disable，否则安装的 :ref:`tesla_p10` 启动时BIOS会告警提示PCIE配置不满足设备要求，所以这两个配置看起来是正确的

- 我尝试了 ``Re-Size BAR Support`` (该配置是为了加速NVIDIA性能，默认开启)关闭和开启都没有解决

总之，BIOS符合NVIDIA GPU的要求，看起来还是需要从 ``bhyve`` 这里寻找解决方法
配置
=======

- 配置 ``/zdata/vms/.templates/x-vm.conf`` (修订使用 ``1/0/0`` 作为 ``passthru`` ，以及使用 ``tap0`` 作为网络接口, VNC使用5900端口):

.. literalinclude:: bhyve_nvidia_gpu_passthru/x-vm.conf
   :caption: 模版配置 ``/zdata/vms/.templates/x-vm.conf``

- 创建虚拟机 ``xdev`` :

.. literalinclude:: bhyve_nvidia_gpu_passthru/create_vm
   :caption: 创建虚拟机 ``xdev``

- 安装ubuntu:

.. literalinclude::  bhyve_nvidia_gpu_passthru/vm_install
   :caption: 安装虚拟机

参考
======

- `GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_
- `bhyve Current state of bhyve Nvidia passthrough? <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/>`_ 也提示采用 `GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_ 介绍的补丁方法，有人验证在 14.3 上也能工作。这个讨论线索中 `原帖讨论中 c-c-c-c 提供的patch文件 <https://forums.freebsd.org/threads/current-state-of-bhyve-nvidia-passthrough.88244/page-2>`_ ，可以直接应用到14.3
- `Nvidia gpu passthru in bhyve <https://www.reddit.com/r/freebsd/comments/1i0pdov/nvidia_gpu_passthru_in_bhyve/>`_ reddit上讨论上述补丁方法
- `bhyve Experience from bhyve (FreeBSD 14.1) GPU passthrough with Windows 10 guest <https://forums.freebsd.org/threads/experience-from-bhyve-freebsd-14-1-gpu-passthrough-with-windows-10-guest.94118/>`_ 经验是使用Intel显卡，似乎不需要patch就可以直接passthru，后续我准备验证测试一下
