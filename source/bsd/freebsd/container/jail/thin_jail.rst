.. _thin_jail:

===========================
FreeBSD Thin(薄) Jail
===========================

FreeBSD Thin Jail是基于 :ref:`zfs` (OpenZFS) 快照 或模板 和 NullFS 来创建的 **瘦** Jail

.. _thin_jail_using_zfs_snapshot:

OpenZFS快照Thin Jail
=========================

- 为模板创建发行版，这个是只读的:

.. literalinclude:: thin_jail/zfs
   :caption: 在ZFS中创建模板数据集

- 和 :ref:`thick_jail` 一样下载用户空间:

.. literalinclude:: thick_jail/fetch
   :caption: 下载用户空间

- 将下载内容解压缩到模板目录:

.. literalinclude:: thin_jail/template
   :caption: 内容解压缩到模板目录

- 将时区和DNS配置复制到模板目录:

.. literalinclude:: thin_jail/template_conf
   :caption: 时区和DNS配置复制到模板目录

- 更新模板补丁:

.. literalinclude:: thin_jail/template_update
   :caption: 更新补丁

- 从模板创建 :ref:`zfs` 快照:

.. literalinclude:: thin_jail/template_snapshot
   :caption: 模板创建 :ref:`zfs` 快照

一旦创建了 OpenZFS 快照，就可以使用 OpenZFS 克隆功能创建无限个 jail

.. literalinclude:: thin_jail/clone
   :caption: 从快照中clone出2个Thin Jail

- 准备 ``dev-1`` Thin Jail配置 ``/etc/jail.conf.d/dev-1.conf`` ( ``dev-2.conf`` 类似，只有主机名和IP不同):

.. literalinclude:: thin_jail/dev-1.conf
   :caption: ``dev-1.conf``

- 启动Thin Jail容器:

.. literalinclude:: thin_jail/start
   :caption: 启动2个Thin Jail

.. warning::

   OpenZFS快照Thin Jail实际上有一个 **致命限制** : ``ZFS snapshot是不可更改的``

   虽然 ``snapshot => clone`` 极大地节约了磁盘空间，但是如果需要更新OpenZFS snapshot Thin Jails，需要:

   - destroy 所有的 clone，也就是销毁Thin Jails
   - 更新ZFS卷，也就是上文案例中的 ``zroot/jails/templates/14.2-RELEASE`` ，当然可以是再建立一个卷，例如 ``zroot/jails/templates/14.3-RELEASE``
   - 重新走一遍 ZFS snapshot => ZFS clone ，来构建Thin Jails

   也就是说，这是一个重建的过程，和 :ref:`docker` 的镜像发布非常相似: 不存在更新snapshot从而达到所有clone自动更新的效果

   好处是和 :ref:`docker` 容器镜像发布是一个原理，如果你熟悉容器管理，其实就是一样的技术。在大规模部署时，假设类似 :ref:`kubernetes` ，可以采用滚动销毁旧Jail，然后从新的snapshot上clone出新的Jail来实现升级。

   相关讨论可以参考 `Upgrade thin jail with ZFS snapshot <https://forums.freebsd.org/threads/upgrade-thin-jail-with-zfs-snapshot.95508/>`_

.. _thin_jail_using_nullfs:

NullFS thin Jail
=========================

通过结合 Thin Jail 和 ``NullFS`` 技术也可以创建节约系统文件存储开销(类似于 ``ZFS snapshot`` clone出来的卷完全不消耗空间)，并且能够将Host主机的我呢见目录共享给 **多个** Jail。

.. note::

   实际上直接使用 ZFS snapshot 创建 thin jail 和 使用 NullFS 创建 thin jail 的区别在于:

   - ``ZFS snapshot 是只读的，不可更改的`` ，这意味着 **没有办法简单通过更新共享的ZFS snapshot来实现Thin Jail操作系统**
   - ``NullFS直接使用ZFS dataset是可读写的`` ，也就是 **直接更新NullFS底座共享的ZFS dataset可以瞬间更新所有Thin Jail**

   所以，两者区别仅在于创建Thin Jail的开始步骤: 

   - 将FreeBSD Release base存放在 **只读** 的 ``14.2-RELEASE@base`` **快照** - OpenZFS snapshot Thin Jail
   - 将FreeBSD Relaase base存放在 **读写** 的 ``14.2-RELEASE-base`` **数据集** - NullFS Thin Jail

- 创建 **读写模式** 的 ``14.2-RELEASE-base`` (注意，大家约定俗成 ``@base`` 表示只读快照， ``-base`` 表示可读写数据集)

.. literalinclude:: thin_jail/zfs_nullfs
   :caption: 创建 **读写模式** 的 ``14.2-RELEASE-base`` 数据集

- 和 :ref:`thick_jail` 一样下载用户空间:

.. literalinclude:: thick_jail/fetch
   :caption: 下载用户空间

- 将下载内容解压缩到模板目录:

.. literalinclude:: thin_jail/template_nullfs
   :caption: 内容解压缩到模板目录( ``14.2-RELEASE-base`` 后续不需要创建快照，直接使用)

- 将时区和DNS配置复制到模板目录:

.. literalinclude:: thin_jail/template_conf_nullfs
   :caption: 时区和DNS配置复制到模板目录

- 更新模板补丁:

.. literalinclude:: thin_jail/template_update_nullfs
   :caption: 更新补丁

``关键部分来了，以下是NullFS特别部分``

- 创建一个特定数据集 ``skeleton`` (骨骼) ，这个 "骨骼" ``skeleton`` 命名非常形象，用意就是构建特殊的支持大量thin jial的框架底座

.. literalinclude:: thin_jail/create_skeleton_zfs
   :caption: 创建特定数据集 ``skeleton`` (骨骼)

- 执行以下命令，将特定目录移入 ``skeleton`` 数据集，并构建 ``base`` 和 ``skeleton`` 必要目录的软连接关系

.. literalinclude:: thin_jail/create_directories_nullfs
   :caption: 创建目录

- 执行以下命令创建软连接

.. literalinclude:: thin_jail/skeleton_link
   :caption: 创建 ``skeleton`` 软连接     
