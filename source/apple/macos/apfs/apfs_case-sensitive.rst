.. _apfs_case-sensitive:

====================
macOS区分大小写APFS
====================

当我在 :ref:`ubuntu_tini_image` 的容器中 :ref:`install_anaconda` ，遇到了一个和底层文件系统 ``区分大小写`` 兼容性问题:

- macOS的 APFS 在操作系统安装时，默认配置了 ``case insensitive`` ，也就是不区分大小写
- 当使用 :ref:`docker_volume` 将macOS上的文件系统目录映射到容器内部时，由于Linux文件系统是区分大小写的，所以在一些情况下会出现错乱，例如 :ref:`install_anaconda` 安装报错，类似找不到文件等情况

验证方法可以采用类似如下:

.. literalinclude:: apfs_case-sensitive/check_filesystem_case_sensitive
   :caption: 检查文件系统是否区分大小写，在 ``case insensitive`` 的APFS文件系统上现象

创建新的 ``case sensitive`` 文件系统
=======================================

:ref:`apfs` 使用了 Containter 容器来分隔文件系统，类似于 :ref:`zfs` 和 :ref:`btrfs` 的子卷

.. note::

   虽然 macOS 内置的 ``Disk Utility`` 也能够创建分区，但是APFS并不推荐使用分区:

   - 类似 :ref:`zfs` ，整个磁盘都是一个大的存储池，只需要通过子卷来分隔系统，可以充分使用磁盘
   - 只有在同一个Mac上安装其他操作系统，如Linux时候，才需要使用分区创建

- 在APFS上添加子卷:

.. figure:: ../../../_static/apple/macos/apfs/apfs_add_subvolume.png
   
   添加子卷

注意创建子卷要选择 ``APFS (Case-sensitive)`` 格式:

.. figure:: ../../../_static/apple/macos/apfs/apfs_add_subvolume_case_sensitive.png
   
   添加区分字符大小写的子卷

现在，就可以重新创建 :ref:`ubuntu_tini_image` 的运行容器，映射新创建的区分大小写文件系统到容器内部，就不会导致Linux文件的问题

