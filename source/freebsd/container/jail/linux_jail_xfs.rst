.. _linux_jail_xfs:

================================
在Linux Jail中使用XFS文件系统 
================================

在构建 :ref:`linux_jail_rocky-base` 之后，我尝试将 :ref:`freebsd_xfs` 用于 :ref:`lfs_partition_freebsd` ，目标是在FreeBSD的Jail容器中模拟一个Linux系统来构建 :ref:`lfs` 。

Jail容器不是Linux虚拟机，实际上依然是FreeBSD系统，无法直接使用 :ref:`xfs` ，需要通过 ``nullfs`` 来挂载Host主机已经通过FUSE挂载的XFS分区。所以修订 ``/etc/jail.conf.d/lrdev.conf`` ，进一步添加自动挂载和写在Nullfs的配置命令:

.. literalinclude:: linux_jail_xfs/lrdev.conf
   :caption: 调整 ``/etc/jail.conf.d/lrdev.conf`` 增加Nullfs绑定 XFS fuse挂载目录
   :emphasize-lines: 22,23

而公共配置部分不需要调整，保留 ``/etc/jail.conf`` 不变:

.. literalinclude:: vnet_thin_jail/jail.conf_common
   :caption: 混合多种jail的公共 ``/etc/jail.conf``

在启动 ``lrdev`` 之前，需要确保Linux compact ``chroot`` 目录下存在 ``/zdata/jails/containers/${name}/compat/rocky/xfs_lfs`` 目录:

.. literalinclude:: linux_jail_xfs/mkdir
   :caption: 创建目录

启动容器 ``lrdev`` :

.. literalinclude:: linux_jail_rocky-base/start
   :caption: 启动 ``lrdev`` Linux Jail

- 进入 ``lrdev`` 的Linux环境:

.. literalinclude:: linux_jail_rocky-base/jexec
   :caption: 进入 ``lrdev`` 的Linux环境

此时在容器内部就可以访问Host主机挂载的 :ref:`freebsd_xfs`
