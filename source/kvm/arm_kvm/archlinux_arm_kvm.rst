.. _archlinux_arm_kvm:

===============================
arch linux ARM KVM虚拟化
===============================

我尝试在 :ref:`arm` 架构的 :ref:`asahi_linux` 上构建ARM虚拟化:

- 硬件: :ref:`apple_silicon_m1_pro` MacBook Pro 2022
- OS: :ref:`asahi_linux`

.. note::

   `arch linux: QEMU <https://wiki.archlinux.org/title/QEMU>`_ 和 `arch linux: KVM <https://wiki.archlinux.org/title/KVM>`_ 的资料都是围绕 X86_64 架构的，需要整理和汇总ARM架构信息。

.. _install_kvm_asahi_linux_fail:

在 :ref:`asahi_linux` 安装虚拟化(挫折)
============================================

- 使用 :ref:`pacman` 搜索QEMU软件工具::

   pacman -Ss qemu

可以看到::

   extra/qemu-base 7.0.0-12
       A basic QEMU setup for headless environments

.. note::

   直接执行 ``pacman -S qemu`` 会提示你选择3种安装之一::

      1) qemu-base  2) qemu-desktop  3) qemu-full

- 安装 ``qemu-base`` ::

   pacman -S qemu-base

对于ARM架构，会有一些提示错误::

   resolving dependencies...
   warning: cannot resolve "libbpf.so=0-64", a dependency of "qemu-system-x86"
   warning: cannot resolve "edk2-ovmf", a dependency of "qemu-system-x86"
   warning: cannot resolve "seabios", a dependency of "qemu-system-x86"
   warning: cannot resolve "qemu-system-x86", a dependency of "qemu-base"
   :: The following package cannot be upgraded due to unresolvable dependencies:
         qemu-base

- 安装 ``qemu-system-aarch64`` ::

   pacman -S qemu-system-aarch64

报错::

   resolving dependencies...
   warning: cannot resolve "libbpf.so=0-64", a dependency of "qemu-system-aarch64"
   warning: cannot resolve "edk2-armvirt", a dependency of "qemu-system-aarch64"
   :: The following package cannot be upgraded due to unresolvable dependencies:
         qemu-system-aarch64

- 安装 ``qemu-system-aarch64`` ::

   pacman -S ovmf-aarch64

报错::

   error: target not found: ovmf-aarch64

参考 `QEMU for Apple Silicon: Roadmap? edk2-armvirt? <https://archlinuxarm.org/forum/viewtopic.php?t=16029>`_ 目前社区还没有解决，原因是上游QEMU软件包分成多个，目前打包依赖没有解决。

源代码编译安装qemu+ovmf(可能存在问题)
=======================================

由于直接从经过一番折腾，我基本完成 :ref:`build_qemu_ovmf` 。原本以为曙光就在眼前，但是没有想到 ``qemu`` 程序运行安装程序始终无法出现安装界面，而且 ``qemu-system-aarch64`` 进程会100%消耗CPU资源。我无法解决这个问题，虽然整个折腾过程对qemu和libvirt有了更多了解，但是我还是没有解决在 ``aarch64`` 架构下的运行。

所以我改回到 "强制方式安装仓库提供的qemu"

.. _force_install_kvm_and_patch:

强制方式安装仓库提供的qemu并补全依赖
=========================================

- `edk2-armvirt <https://archlinux.org/packages/extra/any/edk2-armvirt/>`_ 下载到本地安装::

   sudo pacman -U --noconfirm edk2-armvirt-202208-3-any.pkg.tar.zst
   
- 实际上系统已经安装了 ``libbpf-1.0.1-1``

- 然后强制安装(忽略倚赖)::

   pacman -Sd qemu-system-aarch64 

不过，实际上还是存在依赖问题，也就是 ``qemu-system-aarch64`` 的库依赖错误::

   qemu-system-aarch64 --help

提示::

   qemu-system-aarch64: error while loading shared libraries: libbpf.so.0: cannot open shared object file: No such file or directory

这个 ``libbpf.so.0`` 是低版本 ``libbpf`` ，但是当前系统已经采用了 ``libbpf-1`` ，需要再安装一个低版本

从 `libbpf release <https://github.com/libbpf/libbpf/releases>`_ 下载一个低版本 ``libbpf-0.6.1.tar.gz`` 进行编译安装::

   tar xfz libbpf-0.6.1.tar.gz
   cd libbpf-0.6.1
   cd src
   make
   sudo cp libbpf.so.0.6.0 /usr/lib/
   sudo ln -s /usr/lib/libbpf.so.0.6.0 /usr/lib/libbpf.so.0

这样就能够正常运行 ``qemu-system-aarch64``

.. note::

   折腾差不多3天了，兜兜转转，尝试了各种方法，从源代码编译到绕过软件包安装依赖(手工编译补齐)，终于能够正常在 :ref:`apple_silicon_m1_pro` 的 :ref:`asahi_linux` 上运行虚拟机了...唏嘘

安装libvirt
===============

- arch linux for arm软件仓库提供 :ref:`libvirt` 安装；除了 :ref:`libvirt` 和 :ref:`qemu` /KVM (Hypervisor) 之外，还需要一些网络相关的组件:

.. literalinclude:: archlinux_arm_kvm/archlinux_install_libvirt_packages
   :language: bash
   :caption: 在arch linux上安装libvirt以及支持网络连接的软件包

- 启动libvirt服务:

.. literalinclude:: archlinux_arm_kvm/archlinux_start_libvirtd
   :language: bash
   :caption: 在arch linux上启动libvirtd

.. note::

   在 :ref:`arm_kvm_startup` 采用了基于Debian的 :ref:`raspberry_pi` 操作系统，可以无需 :ref:`build_qemu_ovmf` ，使用更为方便

- 执行 :ref:`mobile_cloud_libvirt_lvm_pool` 为 :ref:`libvirt` 构建一个基于 :ref:`linux_lvm` 的存储池(详细步骤见 :ref:`mobile_cloud_libvirt_lvm_pool` )

启动安装
===========

按照 :ref:`mobile_cloud_infra` 规划进行磁盘的划分

- 创建使用 :ref:`mobile_cloud_libvirt_lvm_pool` 的虚拟机磁盘(举例 ``a-b-data-1`` ):

.. literalinclude:: archlinux_arm_kvm/virsh_create_vm_lvm_disk
   :language: bash
   :caption: virsh创建虚拟机的LVM卷磁盘

- 由于我采用 :ref:`virt-install_location_iso_image` 能够解决终端模式， :strike:`但是看起来 Ubuntu LTS 22.04还不能在 Apple Silicon MacbookPro上工作` (误判)，权衡之后改为采用 :ref:`fedora` ( :ref:`asahi-fedora` ):

.. literalinclude:: archlinux_arm_kvm/virsh_create_ovmf_vm
   :language: bash
   :caption: virt-install通过--location参数在线安装ARM版本Fedora，使用官方安装源

这里需要使用官方源，不知道为何163镜像网站无法执行安装(应该缺少了同步内容)

.. note::

   之前的折腾( :ref:`build_qemu_ovmf` )还是存在缺陷的，我原本以为是安装iso的问题，折腾了好久 :ref:`virt-install_location_iso_image` ，但最终还是采用上文 :ref:`arch_linux` ARM官方仓库的软件包为主(忽略依赖强制安装)，然后通过源代码编译补齐 ``libbpf`` 低版本依赖来解决。

上述在线安装能够正常启动安装过程，但是出现一个报错::

   [   11.180807 ] dracut-initqueue[1040]: Warning: can't find installer main image path in .treeinfo
   [   11.216388 ] dracut-initqueue[1164]:   % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
   [   11.216749 ] dracut-initqueue[1164]:                                  Dload  Upload   Total   Spent    Left  Speed

所以我改为从iso安装，方法借鉴 :ref:`virt-install_location_iso_image` :

.. literalinclude:: debug_arm_vm_disk_fail/virsh_create_ovmf_vm_iso_io_threads
   :language: bash
   :caption: virt-install通过--location参数使用iso镜像安装ARM版本Fedora，必须使用io=threads
   :emphasize-lines: 14,15

.. note::

   我这里遇到一个安装过程中磁盘无法写入异常，通过 :ref:`debug_arm_vm_disk_fail` 发现和虚拟机磁盘参数 ``io=native`` 相关，所以改为 ``io=threads`` 可以绕过这个问题。

这里我采用 ``--graphics vnc`` 会提示错误::

   ERROR    unsupported configuration: domain configuration does not support video model 'virtio'

非常奇怪，我只在 ``--disk`` 指定了 ``virtio`` ；而且也不能使用 ``--graphics spice`` 。所以我最终取消掉图形指定才启动安装。 此时可以看到字符终端界面

开始 ``Install Fedora 37`` 流程之后，会提示提供两种安装模式::

   Starting installer, one moment...
   anaconda 37.12.6-1.fc37 for Fedora 37 started.
    * installation log files are stored in /tmp during the installation
    * shell is available on TTY2 and in second TMUX pane (ctrl+b, then press 2)
    * when reporting a bug add logs from /tmp as separate text/plain attachments
   
   X or window manager startup failed, falling back to text mode.
   ================================================================================
   ================================================================================
   X was unable to start on your machine. Would you like to start VNC to connect to
   this computer from another computer and perform a graphical installation or
   continue with a text mode installation?
   
   1) Start VNC
   2) Use text mode
   
   Please make a selection from the above ['c' to continue, 'h' to help, 'q' to
   quit, 'r' to refresh]:

为方便操作，采用VNC( ``pacman -S tigervnc`` )，使用 ``vncviewer`` 连接虚拟机的VNC地址 ``192.168.122.109:1`` ，终于能够看到久违的安装界面了: 交互安装过程 :ref:`fedora37_installation`

磁盘无法写入的折腾
===================

原本松了一口气，但是没想到 :ref:`fedora37_installation` 配置完成开始安装，却发生虚拟机磁盘无法写入的异常，尝试多次都同样报错。

:ref:`debug_arm_vm_disk_fail` :

- 使用 :ref:`virt-builder` 构建本地Fedora37虚拟机镜像(最终实际采用官方虚拟机raw镜像)，采用简化配置方式能够正常运行KVM虚拟机
- 对比官方镜像运行虚拟机的磁盘参数和我沿X86虚拟化的磁盘参数，反复验证定位出 ``io=native`` 参数导致磁盘无法写入
- 修订 ``virt-install`` 参数，将磁盘参数改为 ``io=threads`` 解决磁盘写入问题(上文安装参数已修订正确)

参考
=======

- `Spawn a Linux virtual machine on Arm using QEMU (KVM) <https://community.arm.com/oss-platforms/w/docs/510/spawn-a-linux-virtual-machine-on-arm-using-qemu-kvm>`_ arm社区wiki文档
- `arch linux arm aarch64 + ovmf uefi + qemu <https://xnand.netlify.app/2019/10/03/armv8-qemu-efi-aarch64.html>`_ 
- `How to make a better ARM virtual machine (armhf/aarch64) with UEFI <https://quantum5.ca/2022/03/19/how-to-make-better-arm-virtual-machine-armhf-aarch64-uefi/>`_
- `FS#74773 - Cannot resolve "edk2-armvirt", a dependency of "qemu-system-aarch64" <https://bugs.archlinux.org/task/74773>`_
- `Creating an Arch Linux ARM QEMU VM on a Mac M1 <https://www.reddit.com/r/archlinux/comments/vg8n8c/creating_an_arch_linux_arm_qemu_vm_on_a_mac_m1/>`_
- `Architectures/AArch64/Install with QEMU <https://fedoraproject.org/wiki/Architectures/AArch64/Install_with_QEMU>`_
- `How to boot Arch Linux ARM in QEMU (patched for M1) <https://gist.github.com/thalamus/561d028ff5b66310fac1224f3d023c12>`_ 关于如何在ARM架构中QEMU启动Arch Linux ARM虚拟机镜像的方法，不过这个文档是使用qcow2和raw镜像，并且使用的是 :ref:`utm` (也就是针对 :ref:`macos` 移植的 :ref:`qemu` )
