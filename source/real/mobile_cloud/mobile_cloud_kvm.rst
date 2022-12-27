.. _mobile_cloud_kvm:

==================
移动云KVM虚拟化
==================

采用 :ref:`archlinux_arm_kvm` 技术构建在 :ref:`apple_silicon_m1_pro` MacBook Pro ( :ref:`arm` 架构 )

架构
=====

- 由于arch linux ARM没有直接提供可用的 qemu 安装包，所以 :ref:`build_qemu_ovmf` 来实现 :ref:`archlinux_arm_kvm`
- 由于 :ref:`asahi_linux` 内核版本过新不被 :ref:`zfs` 直接支持，而 :ref:`btrfs` 对kvm的支持有很多限制，所以采用 :ref:`linux_lvm` 构建 :ref:`libvirt_lvm_pool`

挫折和探索
============

我没有想到在 :ref:`apple_silicon_m1_pro` MacBook Pro上通过 :ref:`asahi_linux` (底层是 :ref:`arch_linux` ARM) 部署 :ref:`kvm` 虚拟化会遇到这么多挫折:

- 从一开始安装软件包就发现 :ref:`pacman` 仓库的 ``aarch64`` 架构的虚拟化系列软件包依赖是broken的，无法直接安装

- 既然没有二进制安装包，那么开源的软件，我们从源代码编译可不可行呢？可行，但是非常麻烦(带来的好处是对 :ref:`ovmf` UEFI 以及 :ref:`qemu` 有了更深的了解):

  - :ref:`build_qemu_ovmf` 想办法构建 :ref:`ovmf` 实现虚拟机的UEFI启动，但是好不容易编译成功并且配置好 :ref:`libvirt` 使用自制的nvram

    - 却发现居然还是无法出现安装界面，期间尝试了各种 ``virt-install`` 安装参数组合
    - 采用 :ref:`virt-install_location_iso_image` 传递内核参数(想基于iso安装依然能够字符终端模式)依然无法解决instller启动

- 不得已又回转来想办法解决 :ref:`arch_linux` ARM 虚拟化软件的 :ref:`force_install_kvm_and_patch` ，峰回路转，终于能够启动安装

- 再遇拦路虎: 安装程序无法写入磁盘导致安装失败， :ref:`debug_arm_vm_disk_fail` 对比和尝试不同的虚拟磁盘参数组合:

  - ARM64架构下 ``io=native`` 导致无法写虚拟磁盘，调整为 ``io=threads`` 解决

安装虚拟化软件
================

安装 ``qemu-system-aarch64``
----------------------------------

.. note::

   以下是我在 :ref:`asahi_linux` 上经过探索总结的部署KVM虚拟化的方法步骤，应该是最简便和准确的方法(去除了反复尝试的一些错误方法)。

虽然QEMU可以运行任意硬件架构操作系统，但是对于运行ARM64架构操作系统，只需要安装 ``qemu-system-aarch64`` 即可。需要注意，当前社区仓库没有解决依赖包安装，直接安装 ``qemu-system-aarch64`` 会提示依赖错误，所以解决方法如下:

- 将 `edk2-armvirt <https://archlinux.org/packages/extra/any/edk2-armvirt/>`_ 依赖安装包下载到本地安装:

.. literalinclude:: ../../kvm/arm_kvm/archlinux_arm_kvm/archlinux_install_edk2_armvirt
   :language: bash
   :caption: 在arch linux上安装edk2-armvirt软件依赖包

- 强制安装 ``qemu-system-aarch64`` :

.. literalinclude:: ../../kvm/arm_kvm/archlinux_arm_kvm/archlinux_install_qemu_aarch64
   :language: bash
   :caption: 强制安装qemu-system-aarch64忽略依赖(依赖需要手工修复) 

- 从 `libbpf release <https://github.com/libbpf/libbpf/releases>`_ 下载一个低版本 ``libbpf-0.6.1.tar.gz`` 进行编译安装:

.. literalinclude:: ../../kvm/arm_kvm/archlinux_arm_kvm/archlinux_compile_libbpf
   :language: bash
   :caption: 编译安装低版本libbpf-0.6.1

这样就能够正常运行 ``qemu-system-aarch64`` 

安装libvirt
--------------

- arch linux for arm软件仓库提供 :ref:`libvirt` 安装；

.. literalinclude:: ../../kvm/arm_kvm/archlinux_arm_kvm/archlinux_install_libvirt_packages
   :language: bash
   :caption: 在arch linux上安装libvirt以及支持网络连接的软件包

- 启动libvirt服务:

.. literalinclude:: ../../kvm/arm_kvm/archlinux_arm_kvm/archlinux_start_libvirtd
   :language: bash
   :caption: 在arch linux上启动libvirtd

libvirt存储配置
==================

.. note::

   创建3个基于 :ref:`mobile_cloud_libvirt_lvm_pool` 的虚拟机，作为运行 :ref:`install_mobile_cloud_ceph` 的底层虚拟机。这3个底层虚拟机需要配置 :ref:`libvirt_lvm_pool`

磁盘分区规划: 分区9作为 :ref:`linux_lvm` 构建 :ref:`ceph` 的KVM虚拟机集群

.. csv-table:: 移动云计算的磁盘分区
   :file: ../../linux/storage/btrfs/btrfs_mobile_cloud/mobile_cloud_parted.csv
   :widths: 20,20,30,30
   :header-rows: 1

- 磁盘采用 :ref:`btrfs_mobile_cloud` 划分磁盘分区:

.. literalinclude:: ../../linux/storage/btrfs/btrfs_mobile_cloud/parted_nvme_btrfs
   :language: bash
   :caption: parted分区: 50G data, 48G docker, 216G libvirt
   :emphasize-lines: 4,7

- 创建 :ref:`linux_lvm` 的PV和VG:

.. literalinclude:: ../../kvm/libvirt/storage/mobile_cloud_libvirt_lvm_pool/mobile_cloud_libvirt_lvm_create
   :language: bash
   :caption: 创建vg-libvirt卷

- 定义 ``images_lvm`` 存储池: 使用逻辑卷组 ``vg-libvirt`` 目标磁盘 ``/dev/nvme0n1p9`` ，并且启动激活:

.. literalinclude:: ../../kvm/libvirt/storage/mobile_cloud_libvirt_lvm_pool/virsh_pool_lvm
   :language: bash
   :caption: 定义使用LVM卷组的libvirt存储池

完成上述 :ref:`libvirt_lvm_pool` 配置后，就可以创建基础虚拟机，如下文

创建虚拟机
============

- 使用Fedora官方下载iso镜像 启动安装:

.. literalinclude:: ../../kvm/arm_kvm/debug_arm_vm_disk_fail/virsh_create_ovmf_vm_iso_io_threads
   :language: bash
   :caption: virt-install通过--location参数使用iso镜像安装ARM版本Fedora，必须使用io=threads
   :emphasize-lines: 14,15 

-  完成 :ref:`mobile_cloud_vm` 就可以开始部署 :ref:`install_mobile_cloud_ceph`
