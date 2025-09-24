.. _gpart_ufs_partition:

===============================
gpart实践(ufs分区)
===============================

在 :ref:`linux_jail` 遇到一个疑似 :ref:`linuxulator` 在FreeBSD 15 Alpha 2上对 :ref:`zfs` metadata 翻译层支持的bug，想要验证一下是否在UFS(简单有效)文件系统上可以绕过这个问题，对比验证一下FreeBSD 15 Alpha 2是否确实存在bug。本文为一个简单的UFS文件系统实践记录。

- 使用 ``geom`` 检查当前磁盘:

.. literalinclude:: freebsd_disk_startup/geom_disk
   :caption: 使用 ``geom`` 列出磁盘

系统中只安装了一块 :ref:`kioxia_exceria_g2` 显示设备名为 ``nda0`` :

.. literalinclude:: gpart_linux_zfs_partition/geom_disk_list_output
   :caption: 单块NVMe存储分区
   :emphasize-lines: 1

- 当前系统分区已经在 :ref:`gpart_linux_zfs_partition` 划分，所以使用 :ref:`gpart` 检查磁盘:

.. literalinclude:: gpart_ufs_partition/gpart_show
   :caption: 使用 ``gpart`` 检查磁盘分区

显示当前分区有5恶，其中分区4是准备调整的分区:

.. literalinclude:: gpart_ufs_partition/gpart_show_output
   :caption: 使用 ``gpart`` 检查磁盘分区，分区4需要调整
   :emphasize-lines: 6

- 删除分区4:

.. literalinclude:: gpart_ufs_partition/gpart_delete
   :caption: 删除分区4

- 这里有一个问题，一共5个分区，删掉中间的分区4，那么分区5的index会变化么？

.. literalinclude:: gpart_ufs_partition/gpart_show
   :caption: 使用 ``gpart`` 检查磁盘分区

可以看到分区5的index依然是 ``5`` :

.. literalinclude:: gpart_ufs_partition/gpart_show_5
   :caption: 使用 ``gpart`` 检查磁盘分区，删除分区4之后分区5的index依然是5
   :emphasize-lines: 7

- 创建一个 UFS 分区:

.. literalinclude:: gpart_ufs_partition/gpart_add_ufs
   :caption: 创建一个UFS分区

可以看到新创建的UFS分区使用了分区4的index :

.. literalinclude:: gpart_ufs_partition/gpart_show_4
   :caption: 使用 ``gpart`` 检查磁盘分区，新创建的UFS分区使用了分区4的index
   :emphasize-lines: 6

- 最后创建 Linux 分区将剩余空间用掉:

.. literalinclude:: gpart_ufs_partition/gpart_add_linux
   :caption: 创建Linux分区

可以看到每次新创建的分区都是使用可分配index的最小值，这次轮到了6:

.. literalinclude:: gpart_ufs_partition/gpart_show_6
   :caption: 使用 ``gpart`` 检查磁盘分区，新创建的Linux分区使用了可用index最小值6
   :emphasize-lines: 7

UFS文件系统创建和挂载
========================

- 对第4分区创建UFS文件系统

.. literalinclude:: gpart_ufs_partition/newfs
   :caption: 创建UFS系统

- 创建挂载目录 ``/udata`` :

.. literalinclude:: gpart_ufs_partition/mkdir
   :caption: 创建目录

- 配置 ``/etc/fstab`` 添加UFS挂载参数

.. literalinclude:: gpart_ufs_partition/fstab
   :caption: ``/etc/fstab`` 添加UFS挂载参数
   :emphasize-lines: 3

- 执行 ``mount /udata`` 命令挂载分区，然后执行 ``df -h`` 可以看到分区4已经挂好如下:

.. literalinclude:: gpart_ufs_partition/df
   :caption: 检查分区挂载

一切就绪，开始实践 :ref:`vnet_thick_jail`
