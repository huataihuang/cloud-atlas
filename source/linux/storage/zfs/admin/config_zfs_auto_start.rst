.. _config_zfs_auto_start:

============================
配置ZFS自动启动
============================

在完成 :ref:`docker_zfs_driver` 配置并使用之后，如果重启物理主机，你会惊讶地发现 ``docker.service`` 启动失败，原因是 ``/var/lib/docker`` 没有就绪。

手工启动zfs
===============

此时检查ZFS会发现 ``zpool`` 是空的:

.. literalinclude:: config_zfs_auto_start/zpool_list_zfs_list
   :language: bash
   :caption: zpool list/ zfs list 都输出空

- 检查 ``zpool import`` 可以看到存储池是就绪的(但是没有导入):

.. literalinclude:: config_zfs_auto_start/zpool_import_output
   :language: bash
   :caption: zpool import可以看到zpool-docker就绪但没有导入

- 手工导入:

.. literalinclude:: config_zfs_auto_start/zpool_import_zpool-docker
   :language: bash
   :caption: zpool import zpool-docker

此时再次检查就能够看到zfs文件系统已经挂载 ( ``df -h`` )::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   zpool-docker    102G  6.4G   95G   7% /var/lib/docker

并且 ``zfs list`` 可以看到所有该存储池下文件系统::

   NAME                                                                                 USED  AVAIL     REFER  MOUNTPOINT
   zpool-docker                                                                        8.04G  94.7G     6.34G  /var/lib/docker
   zpool-docker/03ebbb6554f2f15ee36cedacade890f080081631375a60e3796fd160e6788a6d        104K  94.7G     16.6M  legacy
   zpool-docker/09315a96dcbfbfbc33929960905fc09793bd731a7645cdc625d56079d1643545        112K  94.7G     16.6M  legacy
   ...

配置自动导入和启动ZFS
=========================


参考
=======

- `arch linux: ZFS Configuration <https://wiki.archlinux.org/title/ZFS#Configuration>`_
