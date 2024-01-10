.. _zfs_mount:

==================
ZFS挂载
==================

指定挂载点挂载ZFS
===================

当执行 ``zfs create pool/filesystem`` 命令时，创建的ZFS卷 ``filesystem`` 会沿着 ``pool`` 卷的目录进行挂载，也就是默认挂载为 ``/pool/filesystem`` (假设 ``pool`` 默认挂载为 ``/pool`` )。但是我们很多时候希望灵活的挂载点，例如 :ref:`gentoo_zfs` 实践中，我在 :ref:`install_gentoo_on_mbp` 后，需要把 :ref:`docker_zfs_driver` 管理的 ``zpool-docker`` 存储池分一部分给系统目录。此时，需要使用参数 ``-o`` 指定创建的ZFS卷挂载点 ``mountpoint=`` :

.. literalinclude:: zfs_mount/zfs_create_mountpoint
   :language: bash
   :caption: ``zfs create`` 创建卷时通过 ``-o mountpoint=`` 指定挂载点

然后执行 ``df -h`` 检查就可以看到新创建的ZFS卷 ``zpool-docker/var-cache`` 挂载到了 ``/var/cache`` :

.. literalinclude:: zfs_mount/zfs_create_mountpoint_output
   :caption: 挂载到指定目录下的ZFS卷
   :emphasize-lines: 10

参考
=========

- `Oracle Solaris ZFS Administration Guide  > Chapter 6 Managing Oracle Solaris ZFS File Systems  > Mounting and Sharing ZFS File Systems <https://docs.oracle.com/cd/E19253-01/819-5461/gaynd/index.html>`_
- `opensolaris: Solaris ZFS Administration Guide >> Mounting and Sharing ZFS File Systems <https://dlc.openindiana.org/docs/20090715/ZFSADMIN/html/gaynd.html>`_
