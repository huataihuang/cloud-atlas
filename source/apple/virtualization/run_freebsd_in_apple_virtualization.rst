.. _run_freebsd_in_apple_virtualization:

=====================================
在Apple Virtualization中运行FreeBSD
=====================================

.. note::

   我在学习和实践 :ref:`freebsd` ，但同时我又需要使用 :ref:`macos` 来完成日常开发工作，所以考虑通过Apple Virtualization框架来运行一个 :ref:`freebsd` 虚拟机

   实践验证方法其实和 :ref:`run_linux_in_apple_virtualization` 完全一样，但是很不幸，FreeBSD在Virtualization framework运行下失败。

.. warning::

   目前我的实践Apple Virtualization无法运行FreeBSD ``14.2`` ，从 `UTM: FreeBSD 14.0-CURRENT does not boot #3487 <https://github.com/utmapp/UTM/issues/3487>`_ 来看，似乎这个问题从FreeBSD 14开始就无法正常启动。

目前验证 :ref:`lima_run_freebsd` 使用 :ref:`qemu` 运行 FreeBSD ``14.2`` 是正常工作的，但是 ``VZ`` (Apple Virtualization) framework 看来无法支持FreeBSD。

暂时放弃尝试...

参考
=======

- `Running GUI FreeBSD in a virtual machine on a Mac <https://github.com/jlduran/RunningGUIFreeBSDInAVirtualMachineOnAMac>`_

  - `FreeBSD 14.0-CURRENT does not boot #3487 <https://github.com/utmapp/UTM/issues/3487>`_ :ref:`utm` 项目有人给出了一个在 :ref:`vmware_fusion` 中运行FreeBSD图形化桌面 :ref:`i3` 的例子

- `FreeBSD on Apple Silicon <https://forums.freebsd.org/threads/freebsd-on-apple-silicon.84008/>`_ 讨论，其中提到 `FreeBSD arm64/QEMU <https://wiki.freebsd.org/arm64/QEMU>`_ 有运行案例
- `FreeBSD VMs on Apple M1? <https://www.reddit.com/r/freebsd/comments/n6pk9y/freebsd_vms_on_apple_m1/>`_ 讨论提到 `Guide: Run FreeBSD 13.1-RELEASE for ARM64 in QEMU on Apple Silicon Mac (MacBook Pro M1, etc) with HVF acceleration (Hypervisor.framework) <https://gist.github.com/ctsrc/a1f57933a2cde9abc0f07be12889f97f>`_ 可以作为参考案例
- `Hacking on FreeBSD with an Apple Silicon MacBook <https://jrgsystems.com/posts/2023-09-08-developing-freebsd-on-macos/>`_
- `Hacker News: How to run FreeBSD 13 in QEMU on Apple Silicon Mac <https://news.ycombinator.com/item?id=26053983>`_
