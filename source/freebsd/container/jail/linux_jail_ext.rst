.. _linux_jail_ext:

================================
在Linux Jail中使用EXT文件系统 
================================

在构建 :ref:`linux_jail_rocky-base` 之后，我尝试将 :ref:`freebsd_xfs` 用于 :ref:`lfs_partition_freebsd` ，但是实践发现采用FUSE方式访问Linux文件系统限制较多且不稳定。所以我改为采用 :ref:`freebsd_ext` 来构建一个较为稳定的Linux文件系统，这个步骤完成后可以在Host主机上看到分区挂载:

.. literalinclude:: linux_jail_ext/df
   :caption: 分区挂载

.. note::

   在FreeBSD观察到的分区使用情况和在Linux虚拟机中观察的分区使用情况不同。上述观察到分区使用1G空间，在虚拟机观察挂载的磁盘只使用了 ``2.1M``

启动Linux容器时挂载Host主机EXT4目录
=====================================

Jail容器不是Linux虚拟机，实际上依然是FreeBSD系统，无法直接使用 :ref:`xfs` ，需要通过 ``nullfs`` 来挂载Host主机已经通过FUSE挂载的XFS分区。所以修订 ``/etc/jail.conf.d/lrdev.conf`` ，进一步添加自动挂载和写在Nullfs的配置命令:

.. literalinclude:: linux_jail_ext/lrdev.conf
   :caption: 调整 ``/etc/jail.conf.d/lrdev.conf`` 增加Nullfs绑定 EXT4分区
   :emphasize-lines: 22,23

上述容器启动和停止时XFS目录挂载和卸载也可以改写成 

而公共配置部分不需要调整，保留 ``/etc/jail.conf`` 不变:

.. literalinclude:: vnet_thin_jail/jail.conf_common
   :caption: 混合多种jail的公共 ``/etc/jail.conf``

在启动 ``lrdev`` 之前，需要确保Linux compact ``chroot`` 目录下存在 ``/zdata/jails/containers/${name}/compat/rocky/ext4_lfs`` 目录:

.. literalinclude:: linux_jail_ext/mkdir
   :caption: 创建目录

启动容器 ``lrdev`` :

.. literalinclude:: linux_jail_rocky-base/start
   :caption: 启动 ``lrdev`` Linux Jail

- 进入 ``lrdev`` 的Linux环境:

.. literalinclude:: linux_jail_rocky-base/jexec
   :caption: 进入 ``lrdev`` 的Linux环境

此时在容器内部就可以访问Host主机挂载的 :ref:`freebsd_ext`

采用fstab方式挂载nullfs
----------------------------

上述配置文件也可以修订成独立的 ``fstab`` 以便启动容器时挂载多个目录

.. literalinclude:: linux_jail_ext/fstab
   :caption: 独立的 fstab 配置文件 ``/zdata/jails/lrdev-nullfs.fstab``

然后修订 ``/etc/jail.conf.d/lrdev.conf`` 引用 ``/zdata/jails/lrdev-nullfs.fstab``

.. literalinclude:: linux_jail_ext/lrdev_fstab.conf
   :caption: 修订 ``/etc/jail.conf.d/lrdev.conf`` 引用 ``/zdata/jails/lrdev-nullfs.fstab``

采用单行配置nullfs目录挂载
-----------------------------

不过，对于少量目录挂载，其实单条mount配置就可以，上述配置简化为:

.. literalinclude:: linux_jail_ext/lrdev_mount.conf
   :caption: 单条mount配置挂载nullfs ``/etc/jail.conf.d/lrdev.conf``
   :emphasize-lines: 22

验证
========

在Jail ``lrdev`` 容器内检查 ``/ext4_lfs`` 目录，并复制文件或编辑文件，然后在Host主机上对应的 ``lfs`` 能够看到同步变化

下一步
========

- :ref:`lfs_prepare`
