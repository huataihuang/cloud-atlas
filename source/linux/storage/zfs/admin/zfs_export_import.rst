.. _zfs_export_import:

====================
ZFS导出和导入
====================

.. _rename_zpool:

zpool导出/导入(含重命名)
===========================

导出(export)
--------------

.. warning::

   ZFS不能直接修改zpool名字(你可以理解成ZFS挂载点挂载时不能 ``mv`` )，所以只有 ``export`` / ``import`` 时候才能对zpool进行重命名

- 导出 :ref:`zfs_raidz` 创建的 ``zpool-data`` :

.. literalinclude:: zfs_export_import/export
   :caption: 导出(export) ``zpool-data`` ，相当于 ``umount``

导入(import)
---------------

- 检查当前可以导入的zpool，实际上就是 ``import`` 命令不带任何参数就能显示所有连接在系统上可供导入的zpool情况

.. literalinclude:: zfs_export_import/import
   :caption: 不带参数运行 ``zpool import`` 可以显示系统可导入的zpool

在我的实践案例中，可以看到前面 ``export`` 出去的 ``zpool-data`` :

.. literalinclude:: zfs_export_import/import_output
   :caption: 不带参数运行 ``zpool import`` 看到可供导入的zpool
   :emphasize-lines: 1,4

可以看到待导入的zpool名字是 ``zpool-data`` ，并且是一个 ``raidz1`` 存储池

- 导入存储池 ``zpool-data`` ，且重命名为 ``zpool-dataz``

.. literalinclude:: zfs_export_import/import_zpool-data
   :caption: 导入 ``zpool-data`` 存储池且重命名为 ``zpool-dataz``

- 再次 ``zpool`` 检查:

.. literalinclude:: zfs_raidz/zpool_list
   :caption: 检查zpool

此时可以看到导入的zpool存储池已经被重命名成 ``zpool-dataz``

.. literalinclude:: zfs_export_import/zpool_list_output
   :caption: 可以看到zpool存储池名字已经改成了 ``zpool-dataz``

- 检查 ``zfs`` :

.. literalinclude:: zfs_export_import/zfs_list
   :caption: ``zfs list``

可以看到 ``zpool-dataz`` 数据集被挂载为 ``/Volumes/zpool-dataz``

.. literalinclude:: zfs_export_import/zfs_list_output
   :caption: ``zfs list``

zpool导出/导入多个卷的存储池
=============================

当 ``zpool`` 导出( ``export`` ) 和 导入( ``import`` )存储池时候，会自动 ``umount`` 和 ``mount`` 存储池中包含的子卷，所以操作非常方便。以下实践是 :ref:`zfs_raidz` 中为 ``zpool-dataz`` 创建过多个子卷的 导出/导入 操作:

- 当前卷情况 ``zfs list`` :

.. literalinclude:: zfs_raidz/zfs_list_output
   :caption: ``zfs list`` 列出创建的卷

- 当前卷情况 ``df -h`` 显示已经挂载

.. literalinclude:: zfs_raidz/zfs_df_output
      :caption: ``df`` 可以看到创建的zfs卷

- 执行 ``zpool export`` 导出存储池(卸载):

.. literalinclude:: zfs_export_import/export_dataz
   :caption: ``zpool export`` 存储池 ``zpool-dataz``

可以看到子卷和存储卷都会自动卸载:

.. literalinclude:: zfs_export_import/export_dataz_output
   :caption: ``zpool export`` 存储池 ``zpool-dataz`` 卸载同时会umount所有子卷

此时 ``df -h`` 将看不到 ``zpool-dataz`` 存储池和卷、子卷

- 再次导入 ``zpool-dataz``

.. literalinclude:: zfs_export_import/import_dataz
   :caption: ``zpool import`` 导入存储池 ``zpool-dataz``

此时没有任何输出，但是观察 ``df -h`` 可以看到所有存储池中的卷都已经自动挂载:

.. literalinclude:: zfs_raidz/zfs_df_output
      :caption: ``df`` 可以看到导入存储池 ``zpool-dataz`` 后所有存储卷都自动挂载

参考
======

- `Importing ZFS Storage Pools <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/manage-zfs/importing-zfs-storage-pools.html>`_
