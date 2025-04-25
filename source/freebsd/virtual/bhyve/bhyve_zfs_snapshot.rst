.. _bhyve_zfs_snapshot:

=================================
基于ZFS的bhyve虚拟机快照
=================================

现代化的hypervisor通常会提供虚拟机状态的快照功能，例如guest磁盘，CPU和内存内容的快照。而且这种快照和虚拟机是否运行或关闭无关，提供了虚拟机reset或恢复原先状态的能力。举例，如果虚拟机被破坏，可以通过快照恢复到指定时间的状态中。

``bhyve`` 结合 :ref:`zfs` 能够非常巧妙地实现虚拟机磁盘快照，并且实验性地提供了CPU和内存快照功能(当前限制很多且不稳定)。

待实践...

参考
======

- `FreeBSD handbook: Chapter 24. Virtualization <https://docs.freebsd.org/en/books/handbook/virtualization/>`_
- `How to install Linux VM on FreeBSD using bhyve and ZFS <https://www.cyberciti.biz/faq/how-to-install-linux-vm-on-freebsd-using-bhyve-and-zfs/#google_vignette>`_
- `From 0 to Bhyve on FreeBSD 13.1 <https://klarasystems.com/articles/from-0-to-bhyve-on-freebsd-13-1/>`_
