.. _kubespray_admin:

=========================
Kubespray管理
=========================

etcd
=========

- ``kubespray`` 是在本地通过 :ref:`systemd` 包装的 :ref:`container_runtimes` 运行 :ref:`etcd` ，这里的runtime可以是 :ref:`docker` 也可以是 :ref:`containerd` ，可以直接使用 :ref:`systemctl` 来简单管理和检查::

   systemctl status etcd

- 检查 ``ps aux | grep etcd`` 可以看到 kubespray 部署的 ``etcd`` 运行参数，这个运行参数也可以直接检查 ``/etc/systemd/system/etcdservice`` ，其中有一项配置::

   EnvironmentFile=-/etc/etcd.env

所以尝试采用:

.. literalinclude:: kubespray_admin/kubespray_etcdctl
   :language: bash
   :caption: 借用systemd的etcd服务配置所使用的 ``/etc/etcd.env`` 来使用 ``etcdctl``

但是遇到一个非常奇怪的报错:

.. literalinclude:: kubespray_admin/kubespray_etcdctl_output
   :language: bash
   :caption: 通过 ``/etc/etcd.env`` 来使用 ``etcdctl`` 出现报错

非常奇怪，为何访问 ``etcd-endpoints://0xc000394a80/127.0.0.1:2379`` ? **惭愧** ，我忽略了在 :ref:`bash` 中，一定要使用 ``export`` 命令输出变量才能使得这个变量成为生效的环境便利那个。所以检查 ``/etc/etcd.env`` 可以知道需要生效以下环境变量

.. literalinclude:: kubespray_admin/etcd_env
   :language: bash
   :caption: 配置环境变量访问etcd

所以执行以下脚本命令为自己构建一个环境变量:

.. literalinclude:: kubespray_admin/kubespray_etcdctl_env
   :language: bash
   :caption: **正确的** 采用 ``/etc/etcd.env`` 输出环境变量来使用 ``etcdctl``
   :emphasize-lines: 3

现在执行 ``etcd_status`` 就能正确看到当前集群的etcd状态::

   +----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   |          ENDPOINT          |        ID        | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
   +----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
   | https://192.168.8.116:2379 | 3ff555f9837c69b9 |   3.5.6 |  7.8 MB |      true |      false |        10 |    1444995 |            1444995 |        |
   | https://192.168.8.117:2379 | 4a784b4a93b49575 |   3.5.6 |  7.9 MB |     false |      false |        10 |    1444995 |            1444995 |        |
   | https://192.168.8.118:2379 | cb79cdeb0f0fe1cb |   3.5.6 |  7.9 MB |     false |      false |        10 |    1444995 |            1444995 |        |
   +----------------------------+------------------+---------+---------+-----------+------------+-----------+------------+--------------------+--------+

