.. _mobile_cloud_kvm:

==================
移动云KVM虚拟化
==================

采用 :ref:`archlinux_arm_kvm` 技术构建在 :ref:`apple_silicon_m1_pro` MacBook Pro ( :ref:`arm` 架构 )

架构
=====

- 由于arch linux ARM没有直接提供可用的 qemu 安装包，所以 :ref:`build_qemu_ovmf` 来实现 :ref:`archlinux_arm_kvm`
- 由于 :ref:`asahi_linux` 内核版本过新不被 :ref:`zfs` 直接支持，而 :ref:`btrfs` 对kvm的支持有很多限制，所以采用 :ref:`linux_lvm` 构建 :ref:`libvirt_lvm_pool`
