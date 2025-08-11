.. _zfs_pool_restore:

====================
ZFS pool 恢复
====================

.. warning::

   因为是测试环境，我自己的homelab，所以我不太重视数据安全性，采用了 ``zpool destory`` 来一次性销毁存储。

   但是，我强烈建议你不要直接使用 ``zpool destroy`` ，这个命令和 ``rm -rf /`` 没有什么差别，几乎是瀑布式递归删除所有的被删除存储池下所有数据集数据。大杀器，慎用!!!

   如果要清理数据，建议采用反向，从最低层的 ``dataset`` 开始，一点点删除和不断核对数据安全性完整性。避免出现盛昌环境故障!!!

我在移动硬盘上完成了 :ref:`zfs_replication` ，意味着已经完成了ZFS数据的备份。我当时有点大意了，想着备份完成，可以缩容(删除zfs pool):

.. literalinclude:: zfs_pool_restore/zpool_destroy
   :caption: 删除zpool

删除到第二个 ``zdata`` zpool时候报错了:

.. literalinclude:: zfs_pool_restore/zpool_destroy_error
   :caption: 报错 

突然发现我的开发容器处于 :ref:`docker_container_nfs` 状态，突然间无法读写挂载的NFS了。

一脸懵逼，突然想起来还有一些最近修订的文档没有提交git，不会丢失了吧?

ZFS pool删除前的系统变化
===========================

.. warning::

   虽然 ``zpool destory`` 过程打断依然可以恢复 ``zpool`` ，但是我发现有些 ``dataset`` 已经删除了。所以有可能恢复会比较麻烦，并不一定像我这里写得这么简单。例如，我发现我之前创建的 ``zdata/vms`` 卷集已经消失了(我已经备份，所以也没有再折腾)

检查发现，原来

- ZFS pool在 ``destroy`` 步骤中会调用停止使用ZFS dataset的NFS服务，我的docker容器之所以突然无法读写NFS，只是因为NFS服务被停止了
- ZFS pool的 ``destroy`` 时，如果数据集还有进程在使用(例如我这里因为 :ref:`freebsd_jail` 正处于运行状态)，就会阻断pool删除( **此时有可能部分卷集还没有删除** )

很幸运， ``zdata`` 没有销毁，可以通过 ``zpool list`` 看到:

.. literalinclude:: zfs_pool_restore/zpool_list_output
   :caption: ``zpool list`` 显示 ``zdata`` 没有删除

检查了 ``zdata/docs`` 数据集，发现数据还在。

- 重新启动ZFS上NFS，也就是激活 ``nfsshare`` 参数就可以恢复 :ref:`docker_container_nfs` 访问(我尝试了重启NFS服务但是没有解决，后来发现原来是 ``nfsshare`` 参数关闭了，恢复就可以了)

.. literalinclude:: freebsd_zfs_sharenfs/zfs_sharenfs
   :caption: 设置ZFS数据集 ``sharenfs`` 属性

恢复已经 ``destroy`` 的zpool
================================

如前述，我的 ``zstore-1`` 确实已经 ``destroy`` 了，那么有没有可能恢复呢？(这里只是为了做一个测试)

- 检查当前系统已经被 ``destroy`` 的 zpool 可以使用 ``-D`` 参数:

.. literalinclude:: zfs_pool_restore/zfs_import_d
   :caption: 检查当前有哪些已经处于 ``destoryed`` 状态的zpool ( ``-D`` )

可以看到 ``zstore-1`` 状态是ONLINE，但是已经 ``DESTROYED`` :

.. literalinclude:: zfs_pool_restore/zfs_import_d_output
   :caption: 检查当前有哪些已经处于 ``destoryed`` 状态的zpool ( ``-D`` )
   :emphasize-lines: 3

- 只要使用 ``-D`` 参数并指定zpool，依然可以导入已经 ``destroyed`` 的zpool:

.. literalinclude:: zfs_pool_restore/zfs_import_d_zstore-1
   :caption: 导入已经 ``destroyed`` 的zpool

没有报错，此时再次使用 ``zpool list`` 命令就可以看到 ``zstore-1`` zpool已经可以使用了

.. literalinclude:: zfs_pool_restore/zpool_list_output_zstore-1
   :caption: 可以看到已经导入了 ``zstore-1``
   :emphasize-lines: 4

参考
=======

- `Restoring data after zfs destroy <https://serverfault.com/questions/842955/restoring-data-after-zfs-destroy>`_
