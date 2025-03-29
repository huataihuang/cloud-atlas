.. _kubespray_admin:

=========================
Kubespray管理
=========================

.. _kubespray_etcd:

Kubespray维护etcd
==================

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

非常奇怪，为何访问 ``etcd-endpoints://0xc000394a80/127.0.0.1:2379`` ? **惭愧** ，我忽略了在 :ref:`bash` 中，一定要使用 ``export`` 命令输出变量才能使得这个变量成为生效的环境变量。所以检查 ``/etc/etcd.env`` 可以知道需要生效以下环境变量

.. literalinclude:: ../../administer/etcd/maintain/etcd_env/etcd.env
   :language: bash
   :caption: 配置环境变量访问etcd

所以执行以下脚本命令为自己构建一个环境变量:

.. literalinclude:: ../../administer/etcd/maintain/etcd_env/etcdctl_env
   :language: bash
   :caption: **正确的** 采用 ``/etc/etcd.env`` 输出环境变量来使用 ``etcdctl``
   :emphasize-lines: 3

现在执行 ``etcd_status`` 就能正确看到当前集群的etcd状态:

.. literalinclude:: ../../administer/etcd/maintain/etcd_env/etcd_status_output
   :caption: 包装一个 ``etcd_status`` 命令查看etcd健康状态
