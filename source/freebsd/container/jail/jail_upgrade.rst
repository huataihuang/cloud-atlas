.. _jail_upgrade:

===================
Jail升级
===================

Jail升级可以确保隔离环境保持安全以及最新的功能和性能提升。

升级经典Jail或使用OpenZFS Snapshots的Thin Jail
================================================

**Jails必须从host主机操作系统发起升级**

FreeBSD的默认特性不允许在一个Jail内部使用 ``chflags`` ，这样可以避免在jail内部执行升级失败时更新一些文件。

.. note::

   目前我使用NullFS Jail，所以这段暂时记录待后续实践

- 在 **host** 上执行以下命令更新到FreeBSD运行的最新patch:

.. literalinclude:: jail_upgrade/freebsd-update
   :caption: 更新名为classic的经典Jail

**在更新jail的主版本或从版本之前，需要先完成host主机的版本升级** :ref:`freebsd_update_upgrade`

- 在host主机上升级 ``13.1-RELEASE`` 到 ``13.2-RELEASE`` :

.. literalinclude:: jail_upgrade/freebsd-update_upgrade
   :caption: 升级jail的RELEASE版本

- 在完成了主版本升级之后，需要重新安装jail中的软件包并重启jail:

.. literalinclude:: jail_upgrade/pkg_upgrade
   :caption: 升级jail软件包

升级使用NullFS的Thin Jail
============================

.. note::

   我在 `docs.cloud-atlas.dev: VNET + Thin Jail <https://docs.cloud-atlas.dev/zh-CN/architecture/container/jails/vnet-thin-jail>`_ 上构建的使用NullFS的Thin Jail。使用本段方法进行更新

由于NullFS Jail共享了系统目录，所以非常容易更新。只需要更新模版就能够完成，会立即对所有NullFS Jail同步更新。

- **在host上** 执行以下命令更新FreeBSD的模版补丁:

.. literalinclude:: jail_upgrade/nullfs_jail_update
   :caption: 更新NullFS的Jail模版

**在更新jail的主版本或从版本之前，需要先完成host主机的版本升级** :ref:`freebsd_update_upgrade`

- **在host上** 执行以下命令将Jail的模版从 ``14.2-RELEASE`` 升级到 ``14.3-RELEASE`` :

.. literalinclude:: jail_upgrade/nullfs_jail_upgrade
   :caption: 升级NullFS的Jail模版的RELEASE

参考
=========

- `17.7. Jail Upgrading <https://docs.freebsd.org/en/books/handbook/jails/#jail-upgrading>`_
