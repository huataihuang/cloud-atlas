.. _zfs-jail:

============================
FreeBSD Jail访问ZFS文件系统
============================

ZFS数据集可以委托给Jail使用:

- ``zfs set jailed=on <volume name>`` 将ZFS卷集设置给jail使用
- ``zfs jail <jailid|jailname> filesystem`` 命令可以将ZFS文件系统attach到FreeBSD jail上
- ``jexec <jailname> zfs mount filesystem`` 命令在jail内部挂载上文件系统就可以开始使用

整个过程有一些技巧，特别适合在jail中运行数据库这种独占卷集的方案: :ref:`pgsql_in_jail`

实践案例
==========

目标: host主机的 ``zdata/docs`` 分配给 ``dev`` jail使用

- 创建 ``zdata/docs`` (可选设置挂载目录)

.. literalinclude:: zfs-jail/create_zfs
   :caption: 创建挂载到 ``/docs`` 目录的卷集 ``zdata/docs``

此时在host主机上执行 ``df -h`` 可以看到一个被挂载到 ``/docs`` 目录上的ZFS卷集:

.. literalinclude:: zfs-jail/create_zfs_output
   :caption: 创建挂载到 ``/docs`` 目录的卷集 ``zdata/docs`` 的挂载情况
   :emphasize-lines: 6

- 设置卷集 ``jailed=on`` 属性:

.. literalinclude:: zfs-jail/zfs_jailed
   :caption: 设置卷集 ``jailed=on`` 属性

.. note::

   此时再执行 ``df -h`` 就会看到 ``zdata/docs`` 卷集挂载从host主机上消失了，因为这个卷集已经设置为用于jail，对于host主机将不可用

- 执行 ``zfs jail`` 命令将设置了 ``jailed=on`` 的ZFS卷集分配给jail ``dev`` :

.. literalinclude:: zfs-jail/zfs_jail
   :caption: 将 ``jailed=on`` 属性的ZFS卷集分配给jail ``dev``

.. note::

   只有执行了 ``zfs jail dev zdata/docs`` 命令之后，才能在 ``dev`` jail 中看到这个ZFS卷集

   另外，如果host主机重启，则 ``dev`` jail中就看不到这个ZFS卷集，需要重新执行这个命令。

   要持久化配置，需要调整 ``dev`` jail 配置，加入这个jail启动时自动执行命令，见下文。

- 现在在 ``dev`` jail中可以看到卷集:

.. literalinclude:: zfs-jail/zfs_list
   :caption: 在 ``dev`` jail中可以看到卷集

- 可以在 ``dev`` jail 中执行挂载:

.. literalinclude:: zfs-jail/zfs_mount
   :caption: 在 ``dev`` jail 中执行挂载

这里遇到一个报错:

.. literalinclude:: zfs-jail/zfs_mount_error
   :caption: 在 ``dev`` jail 中执行挂载报错

这个报错是因为我部署的是 :ref:`vnet_thin_jail` 的NullFS jail，其中根文件目录是只读的snapshot挂载。不过，NullFS模式有部分目录是读写模式的，例如 ``/home`` 。所以调整 ``zdata/docs`` 的挂载点来重试:

- 修订挂载点(host)

.. literalinclude:: zfs-jail/zfs_set_mountpoint
   :caption: 调整挂载(host主机上执行)

- 此时在 ``dev`` jail 中执行 ``zfs list`` 可以看到ZFS卷集 ``zdata/docs`` 已经自动反映出挂载点修改了

.. literalinclude:: zfs-jail/zfs_list_mountpoint
   :caption: 在 ``dev`` jail 可以看到挂载点修订
   :emphasize-lines: 3

- 再次执行挂载 ``zfs mount zdata/docs`` ，可以看到另外一个报从显示jail没有权限:

.. literalinclude:: zfs-jail/zfs_mount_no_privileges
   :caption: 在jail中挂载zfs卷集没有权限

- 调整 ``dev``` jail的权限，先停止 ``dev`` jail，然后修订 ``/etc/jail.conf`` (公共设置) 或 ``/etc/jail.conf.d/dev.conf`` (单独设置)

.. literalinclude:: zfs-jail/jail.conf
   :caption: 配置允许挂载ZFS 
   :emphasize-lines: 8,10

.. note::

   这里同时需要配置:

   .. literalinclude:: zfs-jail/jail.conf_zfs
      :caption: 需要同时配置2个参数才能有权限挂载ZFS

   否则挂载时候都会报同样的错误:

   .. literalinclude:: zfs-jail/zfs_mount_no_privileges
      :caption: 在jail中挂载zfs卷集没有权限

参考
=========

- `FreeBSD 14.2 Host-Managed ZFS datasets auto-mounted With jexec inside a jail - native ZFS solution <https://forums.freebsd.org/threads/freebsd-14-2-host-managed-zfs-datasets-auto-mounted-with-jexec-inside-a-jail-native-zfs-solution.96178/>`_  非常好的参考案例，通过ZFS dataset为Jail中运行的 :ref:`pgsql` 提供存储
- `zfs-jail	-- attach or detach ZFS	filesystem from	FreeBSD	jail <https://man.freebsd.org/cgi/man.cgi?query=zfs-jail&sektion=8&manpath=freebsd-release-ports>`_
- `(Solved) zfs jail <https://forums.freebsd.org/threads/zfs-jail.89885/>`_
- `Automatically mounting ZFS dataset in jail? <https://forums.freebsd.org/threads/automatically-mounting-zfs-dataset-in-jail.59072/>`_
- `Mount ZFS dataset in jail <https://forums.freebsd.org/threads/mount-zfs-dataset-in-jail.90129/>`_
- `Using ZFS inside a jail <https://github.com/DtxdF/AppJail/wiki/zfs>`_
