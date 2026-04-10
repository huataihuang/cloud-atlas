.. _freebsd_linux_lvm:

=============================
FreeBSD使用Linux LVM卷管理
=============================

我在处理 :ref:`dell_t5820` 服务器 :ref:`ubuntu_linux` 启动时网络配置问题时，采用了将硬盘挂载到FreeBSD系统上修订的方法。这里有一个问题是，最初Ubuntu安装时，默认installer采用了 :ref:`linux_lvm` ，所以在采用 :ref:`freebsd_ext4` 之前，需要先能够检查和处理LVM卷管理。

- 首先需要让 ``geom`` 能够识别Linux的LVM元数据和Ext4文件系统，所以需要线加载 ``geom_linux_lvm`` 内核模块:

.. literalinclude:: freebsd_linux_lvm/kldload
   :caption: 加载 ``geom_linux_lvm`` 内核模块

然后加载 ``ext2fs`` 内核模块来处理 Ext4文件系统

.. literalinclude:: freebsd_linux_lvm/kldload_ext2fs
   :caption: 加载 ``ext2fs`` 内核模块`

- 在加载了 ``geom_linux_lvm`` 之后，FreeBSD会自动扫描所有磁盘，此时会在 ``/dev/linux_lvm/`` 目录下发现新设备:

.. literalinclude:: freebsd_linux_lvm/ls
   :caption: ``/dev/linux_lvm/`` 目录检查

这是看到我插入移动硬盘中的 :ref:`linux_lvm` 卷设备，注意这个是lv卷(也就是Ubuntu系统的根目录卷):

.. literalinclude:: freebsd_linux_lvm/ls_output
   :caption: ``/dev/linux_lvm/`` 目录下有一个lv卷设备

- 创建一个 ``/mnt/ubuntu`` 目录，然后将上述 ``ubuntu-vg-ubunt-lv`` 卷中的文件系统挂载上去就可以读写:

.. literalinclude:: freebsd_linux_lvm/mount
   :caption: 挂载文件系统`
