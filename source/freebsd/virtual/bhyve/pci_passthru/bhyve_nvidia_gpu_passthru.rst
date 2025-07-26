.. _bhyve_nvidia_gpu_passthru:

===============================================
在bhyve中实现NVIDIA GPU passthrough
===============================================

我在尝试 :ref:`bhyve_pci_passthru_startup` 将 :ref:`tesla_p10` passthrough 给 bhyve 虚拟机，但是遇到无法启动虚拟机的问题，不论是直接使用 ``bhyve`` 命令还是通过 :ref:`vm-bhyve` 管理工具。这个问题困挠了我很久...

`GPU passthrough for bhyve on FreeBSD 14 <https://dflund.se/~getz/Notes/2024/freebsd-gpu/>`_ 解释了为何网上说 "bhyve支持PCI设备passthrough，但是不支持GPU passthru" 是一个误解: 真实原因是NVIDIA驱动仅支持KVM信号的hypervisor，对于bhyve则需要补丁才行。

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

获取源代码
============

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
