.. _alpine_zfs:

====================
Alpine Linux环境ZFS
====================

安装
======

- 通过发行版仓库安装ZFS:

.. literalinclude:: alpine_zfs/install
   :caption: 安装ZFS

这里按照OpenZFS官方文档 `OpenZFS Getting Started: Alpine Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Alpine%20Linux/index.html>`_ 安装

我尝试仅安装 ``zfs`` 没有安装 ``zfs-lts`` (参考 `Alpine Linux wiki: ZFS <https://wiki.alpinelinux.org/wiki/ZFS>`_ ) 结果 ``modprobe zfs`` 提示:

.. literalinclude:: alpine_zfs/modprobe_error
   :caption: 仅安装 ``zfs`` 没有安装 ``zfs-lts`` 执行 ``modprobe zfs`` 报错

但是我发现即使安装了 ``zfs-lts`` 也是同样报错无法加载 ``zfs`` 内核模块

排查发现，之前做了 :ref:`alpine_linux` 系统升级，但是没有重启，所以当前还在旧版本内核下。而Alpine Linux每次升级都是清理掉旧内核对应的 ``/lib/modules`` 目录下对应目录(为了节约空间?)以及旧内核文件，只保留新内核。所以我在当前内核时是无法加载zfs模块的

重启系统就能正常使用ZFS

参考
=====

- `Alpine Linux wiki: ZFS <https://wiki.alpinelinux.org/wiki/ZFS>`_
- `OpenZFS Getting Started: Alpine Linux <https://openzfs.github.io/openzfs-docs/Getting%20Started/Alpine%20Linux/index.html>`_
