.. _install_ceph_mgr:

=======================
安装 ceph-mgr
=======================

手工安装Ceph的第一阶段工作 :ref:`install_ceph_mon` 完成后，需要在 :strike:`每个` 至少一个 ``ceph-mon`` 服务的运行节点，在安装一个 ``ceph-mgr`` daemon(这里的案例是在 ``z-b-data-1`` 节点上启动第一个 ``mgr`` )

可以设置 ``ceph-mgr`` 来使用诸如 ``ceph-ansible`` 工具。

手工部署单个 ``mgr``
=======================

- 创建服务的认证key::

   sudo ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *'

.. note::

   官方文档这里写得很含糊，我参考 `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_ 大致理解 ``$name`` 指的是管理服务器名字，所以实践操作我采用了第一台服务器 ``z-b-data-1`` 名字

实际操作::

   sudo ceph auth get-or-create mgr.z-b-data-1 mon 'allow profile mgr' osd 'allow *' mds 'allow *'

此时会提示::

   [mgr.adm]
        key = XXXXXXXXXXXXXXXX

将上述输出内容存放到集群对应名字( ``ceph`` )的 ``z-b-data-1`` 路径中，对于我的 ``ceph`` 集群，目录就是 ``/var/lib/ceph/mgr/ceph-z-b-data-1/`` 。参考 :ref:`install_ceph_mon` 有同样的配置 ``ceph-mon`` 存放的密钥是 ``/var/lib/ceph/mon/ceph-z-b-data-1/keyring`` 内容类似如下::

   [mon.]
       key = XXXXXXXXXXX
       caps mon = "allow *"


所以类似 ``ceph-mgr`` 的key存放就是 ``/var/lib/ceph/mgr/ceph-z-b-data-1/keyring`` ::

   [mgr.adm]
        key = XXXXXXXXXXXXXXXX

.. _install_ceph_mgr_single:

部署单个 ``mgr``
===================

上述命令可以合并起来(不用再手工编辑 ``/var/lib/ceph/mgr/ceph-z-b-data-1/keyring`` ):

.. literalinclude:: install_ceph_mgr/ceph_mgr_keyring
   :caption: 创建对应主机名的 ``mgr`` keyring

- 然后还需要修订文件属性:

.. literalinclude:: install_ceph_mgr/ceph_mgr_keyring_chown_chmod
   :caption: 修改 ``mgr`` keyring的属性和属主

- 最后通过systemd启动:

.. literalinclude:: install_ceph_mgr/start_ceph_mgr
   :caption: 启动 ``mgr``

- 然后检查:

.. literalinclude:: install_ceph_mgr/check_ceph_mgr
   :caption: 检查 ``mgr`` 运行状态

可以看到 ``ceph-mgr`` 已经注册成功:

.. literalinclude:: install_ceph_mgr/check_ceph_mgr_output
   :caption: 检查 ``mgr`` 运行状态输出

.. note::

   注意，上述步骤只启动了一个 ``mgr`` 运行在 ``z-b-data-1`` 上，所以如果配置 :ref:`ceph_dashboard_prometheus` ，则激活的 ``protmetheus`` 模块也只是运行在 ``z-b-data-1`` 上。要实现监控冗余，则应该在多个节点部署 ``mgr`` (见下文)

- 上述多个步骤可以合并成一个通用脚本:

.. literalinclude:: install_ceph_mgr/ceph_mgr
   :caption: 配置 ``mgr`` keyring并启动服务

.. _install_ceph_mgr_multi:

部署多个 ``mgr``
===================

在 :ref:`ceph_dashboard_prometheus` 可以定义多个抓取入口，此时需要在Ceph集群中运行对应的 ``mgr`` 以及激活 ``prometheus`` 模块

- 将上文 ``z-b-data-1`` 配置文件 ``/var/lib/ceph/mgr/ceph-z-b-data-1/keyring`` 复制到 ``z-b-data-2`` 和 ``z-b-data-3`` ，或者直接在对应的 ``z-b-data-2`` 和 ``z-b-data-3`` 上执行通用脚本:

.. literalinclude:: install_ceph_mgr/ceph_mgr
   :caption: 配置 ``mgr`` keyring并启动服务

使用模块
===========

- 查看 ``ceph-mgr`` 提供了哪些模块::

   sudo ceph mgr module ls

可以看到大量提供的模块以及哪些模块已经激活。

Ceph提供了一个非常有用的模块 ``dashboard`` 方便管理存储集群。对于发行版，可以非常容易安装::

   sudo apt install ceph-mgr-dashboard

然后通过 ``sudo ceph mgr module ls`` 就会看到这个模块

- 通过 ``ceph mgr module enable <module>`` 和 ``ceph mgr module disable <module>`` 可以激活和关闭模块::

   sudo ceph mgr module enable dashboard

详细配置见 :ref:`ceph_dashboard` 提供了非常丰富的管理功能，并且能够结合 :ref:`prometheus` 和 :ref:`grafana` 。

- 激活 ``dashboard`` 并配置好模块后 ( 详见 :ref:`ceph_dashboard` )，可以通过 ``ceph-mgr`` 的服务看到它::

   sudo ceph mgr services

下一步
=======

- :ref:`add_ceph_osds_lvm`

参考
=====

- `ceph-mgr administrator’s guide: MANUAL SETUP <https://docs.ceph.com/en/pacific/mgr/administrator/#mgr-administrator-guide>`_
- `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_ 这篇笔记非常实用，补充了ceph官方文档的缺失
