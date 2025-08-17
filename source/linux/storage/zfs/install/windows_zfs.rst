.. _windows_zfs:

===================
Windows上运行ZFS
===================

除了 :ref:`macos_zfs` 为 :ref:`macos` 平台引入了ZFS，原先在 :ref:`windows` port ZFS的开源项目 ``ZFSin`` 逐步也被 ``OpenZFS`` port替代。这样，实际上ZFS已经成功成为跨平台的优秀文件系统，不仅支持海量存储空间，而且带来了现代化文件系统的高级功能(卷、压缩、RAID等)。

`OpenZFS on Windows <https://openzfsonwindows.org/>`_ 虽然起步不久，但是自2022年开源后，迅速迭代RC版本，目前(2025年8月)已经发布了 ``rc10`` (zfs-windows-2.3.1rc10)，初步具备了可用性。

.. note::

   目前我没有Windows运行需求和工作环境，暂时没有实践。本文记录作为参考，后续看实践需求再尝试。

参考
=========

- `OpenZFS on OS X wiki: Windows <https://openzfsonosx.org/wiki/Windows>`_

