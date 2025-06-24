.. _zfs_raidz:

===================
ZFS RaidZ
===================

.. note::

   本文是一次在一个移动硬盘上完成的模拟测试，当时测试的移动硬盘盒有4块nvme磁盘，所以可以用来构建RaidZ存储。另外，实践在 :ref:`macos_zfs` 环境完成，但方法是通用的。

   我的后续实践在 :ref:`freebsd_zfs_stripe` 以及 :ref:`freebsd` 环境中完成，使用FreeBSD原生支持的ZFS系统。

创建RAID-Z1存储池
===================

.. warning::

   需要小心 macOS 上对磁盘的识别，我是采用 ``diskutils`` 工具一个个检查磁盘命名，确认当前插入USB磁盘被识别为::

     disk2 disk3 disk4 diak5

- 创建名为 ``zpool-data`` 的ZFS存储池:

.. literalinclude:: zfs_raidz/zpool_raidz
   :caption: 创建RZID-Z1存储池

- 检查zpool:

.. literalinclude:: zfs_raidz/zpool_list
   :caption: 检查zpool

输出显示如下:

.. literalinclude:: zfs_raidz/zpool_list_output
   :caption: 检查zpool

可以看到 ``zpool-data`` 存储池默认被挂载，挂载点就是 ``/Volumes/zpool-data``

使用 ``df -h`` 检查也能够看到:

.. literalinclude:: zfs_raidz/df_output
   :caption: 创建 ``zpool-data`` 后挂载显示空间
   :emphasize-lines: 3

.. note::

   考虑到我需要将ZFS存储池(磁盘)在不同主机间移动，我需要重命名 ``zpool-data`` 为 ``zpool-dataz`` ，此时需要使用 :ref:`zfs_export_import`

在RAID-Z存储池中创建卷
========================

在完成 :ref:`zfs_export_import` 之后，上述 ``zpool-data`` 被重命名为 ``zpool-dataz`` ，接下来在存储池中创建不同命名的卷以便分门别类存放数据:

.. literalinclude:: zfs_raidz/zfs_create
   :caption: 创建不同用途的存储卷

完成后检查 ``zfs list`` 输出可以看到不同的存储卷:

.. literalinclude:: zfs_raidz/zfs_list_output
   :caption: ``zfs list`` 列出创建的卷

检查 ``df -h`` 输出可以看到

.. literalinclude:: zfs_raidz/zfs_df_output
   :caption: ``df`` 可以看到创建的zfs卷都被挂载好了


.. note::

   对于zpool存储池执行 :ref:`zfs_export_import` 会自动将zpool中所有卷自动 ``umount``

参考
======

- `OpenZFS Basic Concepts RAIDZ <https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAIDZ.html>`_
- `RAID-Z Storage Pool Configuration <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/manage-zfs/raid-z-storage-pool-configuration.html>`_ Oracle Solaris 11.4手册，提供了ZFS相关参考

  - `Creating a RAID-Z Storage Pool <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/manage-zfs/creating-a-raid-z-storage-pool.html>`_
  - `When to (and Not to) Use RAID-Z <https://blogs.oracle.com/solaris/post/when-to-and-not-to-use-raid-z>`_
  - `Oracle Solaris 11.4 Tunable Parameters Reference Manual <https://docs.oracle.com/en/operating-systems/solaris/oracle-solaris/11.4/tuning/oracle-solaris-11.4-tunable-parameters-reference-manual.pdf>`_ 有关于ZFS RAIDZ调优

- `RAIDZ types reference <https://www.raidz-calculator.com/raidz-types-reference.aspx>`_
