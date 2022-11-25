.. _build_qemu_ovmf:

=======================
编译QEMU+OVMF(ARM架构)
=======================

源代码编译QEMU
======================

- 安装编译依赖::

   pacman -S ninja

- 执行以下方法下载编译::

   tar xvJf qemu-7.1.0.tar.xz
   cd qemu-7.1.0
   ./configure
   make -j8   #按照主机CPU核心数设置编译并发

源代码编译OVMF
=====================

参考
======

- `ubuntu wiki: OVMF <https://wiki.ubuntu.com/UEFI/OVMF>`_
- `How to run OVMF <https://github.com/tianocore/tianocore.github.io/wiki/How-to-run-OVMF>`_
- `QEMU Build instructions <https://www.qemu.org/download/#source>`_
- `Setup: Linux host, QEMU vm, arm64 kernel <https://android.googlesource.com/platform/external/syzkaller/+/HEAD/docs/linux/setup_linux-host_qemu-vm_arm64-kernel.md>`_ 手工启动QEMU vm(ARM)
- `arch linux arm aarch64 + ovmf uefi + qemu <https://xnand.netlify.app/2019/10/03/armv8-qemu-efi-aarch64.html>`_
