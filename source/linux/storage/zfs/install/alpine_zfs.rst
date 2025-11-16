.. _alpine_zfs:

====================
Alpine Linux环境ZFS
====================

安装
======

- 通过发行版仓库安装ZFS:

.. literalinclude:: alpine_zfs/install
   :caption: 安装ZFS

.. note::

   这里按照OpenZFS官方文档 `OpenZFS Getting Started: Alpine Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Alpine%20Linux/index.html>`_ 安装

   我尝试仅安装 ``zfs`` 没有安装 ``zfs-lts`` (参考 `Alpine Linux wiki: ZFS <https://wiki.alpinelinux.org/wiki/ZFS>`_ ) 结果 ``modprobe zfs`` 提示:

   .. literalinclude:: alpine_zfs/modprobe_error
      :caption: 仅安装 ``zfs`` 没有安装 ``zfs-lts`` 执行 ``modprobe zfs`` 报错

参考
=====

- `Alpine Linux wiki: ZFS <https://wiki.alpinelinux.org/wiki/ZFS>`_
- `OpenZFS Getting Started: Alpine Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Alpine%20Linux/index.html>`_
