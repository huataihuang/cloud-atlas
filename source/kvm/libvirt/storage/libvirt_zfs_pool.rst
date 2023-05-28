.. _libvirt_zfs_pool:

=======================
libvirt ZFS存储池
=======================

:ref:`arch_linux` 的 ``X86_64`` 架构对 :ref:`zfs` 和 :ref:`stratis` 都有良好支持，所以我计划:

- 在MacBook Pro 2013笔记本上同时采用这两种存储技术来构建 ``libvit`` 存储后端
- 在 :ref:`priv_cloud_infra` 上利用3块旧的HDD构建ZFS扩展 ``libvit`` 存储后端

参考
=======

- `libvirt storage: ZFS pool <https://libvirt.org/storage.html#zfs-pool>`_
- `KVM with ZFS support <https://operationroot.com/?p=1595>`_
