.. _archlinux_arm_kvm:

===============================
arch linux ARM KVM虚拟化
===============================

我尝试在 :ref:`arm` 架构的 :ref:`asahi_linux` 上构建ARM虚拟化:

- 硬件: :ref:`apple_silicon_m1_pro` MacBook Pro 2022
- OS: :ref:`asahi_linux`

.. note::

   `arch linux: QEMU <https://wiki.archlinux.org/title/QEMU>`_ 和 `arch linux: KVM <https://wiki.archlinux.org/title/KVM>`_ 的资料都是围绕 X86_64 架构的，需要整理和汇总ARM架构信息。

安装
=======

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

.. note::

   我的实践看来存在问题，我尝试 :ref:`build_qemu_ovmf`

参考
=======

- `arch linux arm aarch64 + ovmf uefi + qemu <https://xnand.netlify.app/2019/10/03/armv8-qemu-efi-aarch64.html>`_ 这篇文章可能是最全信息
- `FS#74773 - Cannot resolve "edk2-armvirt", a dependency of "qemu-system-aarch64" <https://bugs.archlinux.org/task/74773>`_
- `Creating an Arch Linux ARM QEMU VM on a Mac M1 <https://www.reddit.com/r/archlinux/comments/vg8n8c/creating_an_arch_linux_arm_qemu_vm_on_a_mac_m1/>`_
