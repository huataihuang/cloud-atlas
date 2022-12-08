.. _mobile_cloud_ceph_mgr:

=============================
移动云计算Ceph安装 ceph-mgr
=============================

手工安装Ceph的第一阶段工作 :ref:`mobile_cloud_ceph_mon` 完成后，需要在 ``每个`` ``ceph-mon`` 服务的运行节点，在安装一个 ``ceph-mgr`` daemon

可以设置 ``ceph-mgr`` 来使用诸如 ``ceph-ansible`` 工具。

- 创建服务的认证key::

   sudo ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *'

.. note::

   官方文档这里写得很含糊，我参考 `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_ 大致理解 ``$name`` 指的是管理服务器名字，所以实践操作我采用了第一台服务器 ``z-b-data-1`` 名字

实际操作::

   sudo ceph auth get-or-create mgr.a-b-data-1 mon 'allow profile mgr' osd 'allow *' mds 'allow *'

此时会提示::

   [mgr.adm]
        key = XXXXXXXXXXXXXXXX

将上述输出内容存放到集群对应名字( ``ceph`` )的 ``a-b-data-1`` 路径中，对于我的 ``ceph`` 集群，目录就是 ``/var/lib/ceph/mgr/ceph-a-b-data-1/`` 。参考 :ref:`mobile_cloud_ceph_mon` 有同样的配置 ``ceph-mon`` 存放的密钥是 ``/var/lib/ceph/mon/ceph-a-b-data-1/keyring`` 内容类似如下::

   [mon.]
       key = XXXXXXXXXXX
       caps mon = "allow *"


所以类似 ``ceph-mgr`` 的key存放就是 ``/var/lib/ceph/mgr/ceph-a-b-data-1/keyring`` ::

   [mgr.adm]
        key = XXXXXXXXXXXXXXXX

上述命令可以合并起来(不用再手工编辑 ``/var/lib/ceph/mgr/ceph-a-b-data-1/keyring`` )::

   sudo mkdir /var/lib/ceph/mgr/ceph-a-b-data-1
   sudo ceph auth get-or-create mgr.a-b-data-1 mon 'allow profile mgr' osd 'allow *' mds 'allow *' | sudo tee /var/lib/ceph/mgr/ceph-a-b-data-1/keyring

- 然后还需要修订文件属性::

   sudo chown ceph:ceph /var/lib/ceph/mgr/ceph-a-b-data-1/keyring
   sudo chmod 600 /var/lib/ceph/mgr/ceph-a-b-data-1/keyring

- 然后通过systemd启动::

   sudo systemctl start ceph-mgr@a-b-data-1
   sudo systemctl enable ceph-mgr@a-b-data-1

- 然后检查::

   sudo ceph -s

可以看到 ``ceph-mgr`` 已经注册成功::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_OK
  
   services:
     mon: 1 daemons, quorum a-b-data-1 (age 8m)
     mgr: a-b-data-1(active, since 8s)
     osd: 0 osds: 0 up, 0 in
  
   data:
     pools:   0 pools, 0 pgs
     objects: 0 objects, 0 B
     usage:   0 B used, 0 B / 0 B avail
     pgs:

使用模块
===========

- 查看 ``ceph-mgr`` 提供了哪些模块::

   sudo ceph mgr module ls

可以看到大量提供的模块以及哪些模块已经激活。

Ceph提供了一个非常有用的模块 ``dashboard`` 方便管理存储集群。对于发行版，可以非常容易安装::

   sudo dnf install ceph-mgr-dashboard

然后通过 ``sudo ceph mgr module ls`` 就会看到这个模块

- 通过 ``ceph mgr module enable <module>`` 和 ``ceph mgr module disable <module>`` 可以激活和关闭模块::

   sudo ceph mgr module enable dashboard

详细配置见 :ref:`ceph_dashboard` 提供了非常丰富的管理功能，并且能够结合 :ref:`prometheus` 和 :ref:`grafana` 。

- 激活 ``dashboard`` 并配置好模块后 ( 详见 :ref:`ceph_dashboard` )，可以通过 ``ceph-mgr`` 的服务看到它::

   sudo ceph mgr services

下一步
=======

- :ref:`mobile_cloud_ceph_add_ceph_osds_lvm`

参考
=====

- `ceph-mgr administrator’s guide: MANUAL SETUP <https://docs.ceph.com/en/pacific/mgr/administrator/#mgr-administrator-guide>`_
- `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_ 这篇笔记非常实用，补充了ceph官方文档的缺失
