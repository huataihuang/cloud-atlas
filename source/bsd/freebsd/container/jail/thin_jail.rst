.. _thin_jail:

===========================
FreeBSD Thin(薄) Jail
===========================

FreeBSD Thin Jail是基于 :ref:`zfs` (OpenZFS) 快照 或模板 和 NullFS 来创建的 **瘦** Jail

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


