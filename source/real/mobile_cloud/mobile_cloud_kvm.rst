.. _mobile_cloud_kvm:

==================
移动云KVM虚拟化
==================

采用 :ref:`archlinux_arm_kvm` 技术构建在 :ref:`apple_silicon_m1_pro` MacBook Pro ( :ref:`arm` 架构 )

架构
=====

- 由于arch linux ARM没有直接提供可用的 KVM ，所以 :ref:`build_qemu_ovmf` 来实现 :ref:`archlinux_arm_kvm`
