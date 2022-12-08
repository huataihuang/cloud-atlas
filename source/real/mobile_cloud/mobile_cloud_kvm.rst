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

创建虚拟机
============

- 使用Fedora官方下载iso镜像 启动安装:

.. literalinclude:: ../../kvm/arm_kvm/debug_arm_vm_disk_fail/virsh_create_ovmf_vm_iso_io_threads
   :language: bash
   :caption: virt-install通过--location参数使用iso镜像安装ARM版本Fedora，必须使用io=threads
   :emphasize-lines: 14,15 

-  完成 :ref:`mobile_cloud_vm`
