.. _add_ceph_mons:

=======================
Ceph集群添加ceph-mon
=======================

在 :ref:`install_ceph_mon` 我们已经安装部署了1个 ``ceph-mon`` 。虽然这样也能工作，Ceph monitor可以使用Pasos算法来建立一致性映射以及集群的其他关键信息。但是，对应稳定的集群，需要一个奇数数量的monitor，所以，推荐至少3个 ``ceph-mon`` ，为了在出现更多失效能够继续服务，可以部署更多 monitor ，如5个 ``ceph-mon`` 。

.. note::

   虽然 ``ceph-mon`` 是非常轻量级的监控服务，可以运行在OSD相同的服务器上。但是，对于生产集群，特别是高负载集群，建议将 ``ceph-mon`` 和 ``ceph-osd`` 分开服务器运行。这是因为高负载下，有可能 ``ceph-osd`` 压力过大影响 ``ceph-mon`` 的稳定性(响应延迟)，从而导致系统误判而出现雪崩。

部署monitor
================

- 登陆需要部署monitor的服务器，例如，我这里部署到 ``z-b-data-2`` 服务器上，执行以下命令创建mon默认目录::

   mon-id="z-b-data-2"
   sudo mkdir /var/lib/ceph/mon/ceph-${mon-id}

- 将 192.168.6.204 ( ``z-b-data-1`` ) 管理密钥复制到需要部署 ``ceph-mon`` 的配置目录下::

   scp 192.168.6.204:/etc/ceph/ceph.client.admin.keyring /etc/ceph/
   scp 192.168.6.204:/etc/ceph/ceph.conf /etc/ceph/

- 在需要部署新 ``ceph-mon`` 的主机 ``z-b-data-1`` 上执行以下命令获取monitors的keyring(需要读取本机的 ``/etc/ceph/ceph.client.admin.keyring`` 认证来获取 ``ceph-mon`` 的keyring)::

   sudo ceph auth get mon. -o /tmp/ceph.mon.keyring

显示输出::

   exported keyring for mon.

此时获取到的monitor key存储在 ``/tmp/ceph.mon.keyring`` ，这个key文件实际上就是初始服务器 ``z-b-data-1`` 在 ``/var/lib/ceph/mon/ceph-z-b-data-1/keyring`` 内容。

- 获取monitor map::

   sudo ceph mon getmap -o /tmp/monmap

但是需要注意，这里从集群中获得的 ``monmap`` 只包含了第一台服务器 ``z-b-data-1`` ，我们还需要添加增加的 ``z-b-data-2`` 和 ``z-b-data-3`` ::

   monmaptool --add z-b-data-2 192.168.6.205 --fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17 /tmp/monmap
   monmaptool --add z-b-data-3 192.168.6.206 --fsid 0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17 /tmp/monmap

现在我们的 ``/tmp/monmap`` 是最新的最全的monmap，但是我们在 ``z-b-data-1`` 上没有添加过节点2和节点3的 monmap ，我们需要把这个 ``/tmp/monmap`` 插入到 ``z-b-data-1`` 的监控目录中。所以把这个最新 ``/tmp/monmap`` 复制到 ``z-b-data-1`` 上，再执行以下命令更新::

   sudo ceph-mon -i z-b-data-1 --inject-monmap /tmp/monmap

.. note::

   注意，在更新 ``z-b-data-1`` 的 ``monmap`` 之前，需要先停止 ``ceph-mon`` ::

      sudo systemctl stop ceph-mon@z-b-data-1

   否则会报错无法拿到db的锁::

      2021-12-02T22:37:23.236+0800 7f8227f17540 -1 rocksdb: IO error: While lock file: /var/lib/ceph/mon/ceph-z-b-data-1/store.db/LOCK: Resource temporarily unavailable
      2021-12-02T22:37:23.236+0800 7f8227f17540 -1 error opening mon data directory at '/var/lib/ceph/mon/ceph-z-b-data-1': (22) Invalid argument

   停止 ``ceph-mon`` 之后再执行::

      sudo ceph-mon -i z-b-data-1 --inject-monmap /tmp/monmap

   我发现导入命令似乎应该使用 ``ceph`` 用户身份执行，否则会把文件属主设置成root，需要执行 ``chown -R ceph:ceph /var/lib/ceph/mon/ceph-z-b-data-1`` 来修复。
      
   就不再报错。等导入更新了 ``monmap`` 之后，再次启动服务::

      sudo systemctl start ceph-mon@z-b-data-1

.. warning::

   当配置了3个 ``ceph-mon`` 的 ``monmap`` ，如果只启动 ``z-b-data-1`` 而没有启动其他节点的 ``ceph-mon`` ，则会发现虽然 ``z-b-data-`` 的 ``ceph-mon`` 启动 ( ``systemctl status ceph-mon@z-b-data-1`` 正常 )，但是 ``/var/log/ceph/ceph-mon.z-b-data-1.log`` 日志报错::

      2021-12-02T23:02:15.980+0800 7f16d5c02700  1 mon.z-b-data-1@0(probing) e3 handle_auth_request failed to assign global_id
      2021-12-02T23:02:16.184+0800 7f16d5c02700  1 mon.z-b-data-1@0(probing) e3 handle_auth_request failed to assign global_id

   此时::

      ceph -s

   无响应

   不过，只要再启动 ``z-b-data-2`` 上的 ``ceph-mon@z-b-data-2`` ，则立即恢复正常响应。

- 准备monitor的数据目录，这里必须指定monitor map路径，这样才能够获取监控的quorum信息以及 ``fsid`` ，而且还需要提供 monitor keyring的路径::

   sudo ceph-mon --mkfs -i z-b-data-2 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

.. note::

   仔细对比一下，就可以看出第二个以及今后节点的 ``ceph-mon`` 部署方法和 :ref:`install_ceph_mon` 差不多，只是证书是从第一台服务器导入过来不需要重新生成。

- 启动服务::

   sudo systemctl start ceph-mon@z-b-data-2
   sudo systemctl enable ceph-mon@z-b-data-2

.. note::

   如果启动失败，可以尝试通过终端执行命令 ``ceph-mon -f --cluster ceph --id z-b-data-2 --setuser ceph --setgroup ceph`` 查看终端输出信息。我遇到失败的原因是 ``/var/lib/ceph/mon/z-b-data-2`` 目录权限错误，可以根据提示信息检查

部署第三个 ``ceph-mon`` 节点
=============================

有了上述部署 ``z-b-data-2`` 的 ``ceph-mon`` 的经验，我们现在来快速完成第三个 ``z-b-data-3`` 的 ``ceph-mon`` 部署

- 将 192.168.6.204 ( ``z-b-data-1``  ) 管理密钥复制到 ``z-b-data-3`` 部署 ceph-mon 的配置目录下::

   scp 192.168.6.204:/etc/ceph/ceph.client.admin.keyring /etc/ceph/
   scp 192.168.6.204:/etc/ceph/ceph.conf /etc/ceph/

- 在 ``z-b-data-3`` 上执行以下命令获取 ``ceph-mon`` 的keyring::

   sudo ceph auth get mon. -o /tmp/ceph.mon.keyring

- 获取 monitor map::

   sudo ceph mon getmap -o /tmp/monmap

.. note::

   注意，这里获得的 ``monmap`` 已经包含了3台主机的 monitor map ，所以不需要再修订

- 准备monitor数据目录::

   sudo ceph-mon --mkfs -i z-b-data-3 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring

- 修订 ceph monitor数据目录权限::

   sudo chown -R ceph:ceph /var/lib/ceph/mon/ceph-z-b-data-3

- 启动服务::

   sudo systemctl start ceph-mon@z-b-data-3
   sudo systemctl enable ceph-mon@z-b-data-3

最小化配置 ``ceph-mon``
==========================

参考 `Ceph Monitor Config Reference#Minimum Configuration <https://docs.ceph.com/en/pacific/rados/configuration/mon-config-ref/#minimum-configuration>`_ 修订 ``/etc/ceph/ceph.conf`` :

.. literalinclude:: install_ceph_mon/ceph.conf
   :language: bash
   :linenos:
   :caption: /etc/ceph/ceph.conf

添加的 ``[mon.<id>]`` 段落可选，我实践下来似乎不配置也没有影响运行，待后续运维观察。

检查
=======

- 完成部署 ``ceph-mon`` 到 ``z-b-data-1`` / ``z-b-data-2`` / ``z-b-data-3`` 之后，集群就具备了3个监控

- 观察 :ref:`ceph_dashboard` 可以看到启动了3个 mon :

.. figure:: ../../../_static/ceph/deploy/install_ceph_manual/ceph-mon_3.png
   :scale: 50

参考
========

- `ADDING/REMOVING MONITORS <https://docs.ceph.com/en/latest/rados/operations/add-or-rm-mons/>`_
- `CEPH by hand <http://www.hep.ph.ic.ac.uk/~dbauer/cloud/iris/ceph.html>`_
