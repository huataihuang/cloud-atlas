.. _zfs-jail_zpool:

============================
FreeBSD Jail访问ZFS zpool
============================

- 修订分区类型(ufs改为zfs)

.. literalinclude:: zfs-jail_zpool/gpart
   :caption: 修订分区类型

显示分区1被修改:

.. literalinclude:: zfs-jail_zpool/gpart_output
   :caption: 修订分区类型

- 创建一个名为 ``zstore-1`` 的存储池

.. literalinclude:: zfs-jail_zpool/zpool
   :caption: 创建 ``zstore-1`` 的存储池

此时可以看到系统挂载了一个 ``/zstore-1`` 目录，对应了存储池 ``zstore-1`` :

.. literalinclude:: zfs-jail_zpool/zpool_df
   :caption:  ``zstore-1`` 的存储池挂载( ``df -h`` 输出)
   :emphasize-lines: 4

- 设置存储池 ``zstore-1`` 的 ``jailed=on`` 属性:

.. literalinclude:: zfs-jail_zpool/zfs_jailed
   :caption: 设置 存储池 ``zstore-1`` 的 ``jailed=on`` 属性

.. note::

   **amazing**

   居然可以设置 zpool 的 ``jailed`` 属性(google AI给的说明是command is incorrect. 但是实践发现是可行的)

   毕竟在 :ref:`zfs-jail` 实践中我发现当设置了 zfs dataset 的 ``jailed=on`` 属性之后，实际上在jail中是能够看到 ``zpool`` 的，所以我当时就有一个想法，似乎zpool可以直接在jail中使用

- 执行 ``zfs jail`` 命令将设置 ``jailed=on`` 的 :strike:`ZFS卷集` **zpool** ``zstore-1`` 分配给 **jail** ``store-1`` :

.. literalinclude:: zfs-jail_zpool/zfs_jail
   :caption: ``zfs jail`` 将 **zpool** ``zstore-1`` 分配给 **jail** ``store-1``

- **amazing** 此时在 ``store-1`` 这个jail中就能够看到存储池 ``zstore-1`` 了:

.. literalinclude:: zfs-jail_zpool/zpool_in_jail
   :caption: 在 ``zstore-1`` 中观察zpool
 
这里观察到jail中没有自动挂载上 ``zstore-1`` 这是因为在jial中，根目录是只读的，所以需要修订 ``zpool`` 挂载点:

.. literalinclude:: zfs-jail_zpool/zfs_mountpoint
   :caption: 修订zpool挂载点

此时再次在jail中执行 ``df -h`` 就会看到存储池被挂载到指定挂载点:

.. literalinclude:: zfs-jail_zpool/zfs_mountpoint_df
   :caption: 修订zpool挂载点后检查 ``df -h``
   :emphasize-lines: 5

稍微有一点和Ceph手册不同，挂载点实际在 ``/skeleton/var/lib/ceph/osd/osd.1`` ，不过软链接 ``/var`` 等同于 ``/skeleton/var`` ，不确定是否可行。待后续再改进部署

.. note::

   已验证zpool能够直接在jail中使用，这样理论上只需要使用容器来模拟 :ref:`ceph` 集群即可，不需要沉重的 :ref:`bhyve` 虚拟化了。


