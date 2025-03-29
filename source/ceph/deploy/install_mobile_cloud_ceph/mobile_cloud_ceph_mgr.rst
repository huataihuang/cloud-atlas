.. _mobile_cloud_ceph_mgr:

=============================
移动云计算Ceph安装 ceph-mgr
=============================

手工安装Ceph的第一阶段工作 :ref:`mobile_cloud_ceph_mon` 完成后，需要在 ``每个`` ``ceph-mon`` 服务的运行节点，在安装一个 ``ceph-mgr`` daemon。

我还是采用 :ref:`mobile_cloud_ceph_mon` 的脚本风格来继续完成部署。

- 在每个服务器节点上准备环境变量:

.. literalinclude:: ceph_env
   :language: bash
   :caption: 在每个服务器节点上准备环境变量

- (官方文档案例，请勿执行)创建服务的认证key::

   sudo ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *'

.. note::

   官方文档这里写得很含糊，我参考 `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_ 大致理解 ``$name`` 指的是管理服务器名字，所以实践操作我采用了第一台服务器 ``z-b-data-1`` 名字

- (这步请不要直接执行，实际操作合并到直接将命令输出到key文件中)生成管理服务器mgr的认证key:

.. literalinclude:: mobile_cloud_ceph_mgr/ceph_auth_mgr_cmd
   :language: bash
   :caption: 创建管理服务器mgr的认证key(演示说明，不要执行)

如果执行上述命令会提示::

   [mgr.adm]
        key = XXXXXXXXXXXXXXXX

上述输出内容就是 ``ceph-mgr`` 的管理密钥，需要存放到集群 ``$CLUSTEr`` 对应名字( 这里是 ``ceph`` )的主机 ``$HOST`` （这里是 ``a-b-data-1`` )路径中(完整目录就是 ``/var/lib/ceph/mgr/${CLUSTER}-${HOST}`` ，这里是 ``/var/lib/ceph/mgr/ceph-a-b-data-1/`` ) 。参考 :ref:`mobile_cloud_ceph_mon` 有同样的配置 ``ceph-mon`` 存放的密钥是 ``/var/lib/ceph/mon/ceph-a-b-data-1/keyring`` 内容类似如下::

   [mon.]
       key = XXXXXXXXXXX
       caps mon = "allow *"

所以类似 ``ceph-mgr`` 的key存放就是 ``/var/lib/ceph/mgr/ceph-a-b-data-1/keyring`` ::

   [mgr.adm]
        key = XXXXXXXXXXXXXXXX

- (请不要执行，后面合并命令执行)你可以手工将上述信息存放到 ``/var/lib/ceph/mgr/${CLUSTER}-${HOST}/keyring`` 文件 ( 即 ``/var/lib/ceph/mgr/ceph-a-b-data-1/keyring`` ) ，然后修订文件属性::

   sudo chown ceph:ceph /var/lib/ceph/mgr/${CLUSTER}-${HOST}/keyring
   sudo chmod 600 /var/lib/ceph/mgr/${CLUSTER}-${HOST}/keyring

- 注意：我实际上将上述命令合并起来 **请执行这段命令** :

.. literalinclude:: mobile_cloud_ceph_mgr/ceph_auth_mgr
   :language: bash
   :caption: 创建管理服务器mgr的认证key(请执行这段命令)

- 然后通过systemd启动:

.. literalinclude:: mobile_cloud_ceph_mgr/start_ceph_mgr
   :language: bash
   :caption: 启动ceph-mgr(请执行这段命令)

- 然后检查::

   sudo ceph -s

可以看到 ``ceph-mgr`` 已经注册成功::

   cluster:
     id:     598dc69c-5b43-4a3b-91b8-f36fc403bcc5
     health: HEALTH_WARN
             mon is allowing insecure global_id reclaim
             1 monitors have not enabled msgr2
  
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

整合脚本快速完成
====================

上述步骤整合到一个脚本快速完成:

.. literalinclude:: mobile_cloud_ceph_mgr/host_1_ceph_mgr.sh
   :language: bash
   :caption: 在节点1上完成ceph-mgr部署脚本 host_1_ceph_mgr.sh

.. note::

   脚本中我整合了 :ref:`ceph_dashboard` ，所以执行以后不仅启动了 ``ceph-mgr`` 也激活了 ``dashborad`` 模块

   注意: :ref:`ceph_dashboard` 需要准备一个用户密码文件( 这里使用 ``pw.txt`` 文件 )，以便在 ``ceph dashboard ac-user-create`` 时候指定密码

下一步
=======

- :ref:`mobile_cloud_ceph_add_ceph_osds_lvm`

参考
=====

- `ceph-mgr administrator’s guide: MANUAL SETUP <https://docs.ceph.com/en/pacific/mgr/administrator/#mgr-administrator-guide>`_
- `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_ 这篇笔记非常实用，补充了ceph官方文档的缺失
