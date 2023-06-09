.. _etcd_env:

===================
``etcd`` 环境设置
===================

我在 :ref:`kubespray_startup` 成功部署了一个生产就绪的Kubernetes集群后，发现直接 :ref:`kubespray_etcd` 时由于环境变量配置问题无法直接访问和维护 :ref:`etcd` 。所以借助 :ref:`kubespray` 部署的 :ref:`systemd` 包装的 :ref:`container_runtimes` 运行 :ref:`etcd` ，梳理维护方法。

- 在 ``/etc/etcd.env`` 配置了 :ref:`systemd` 运行启动 :ref:`etcd` 的执行参数，也包括了 ``etcdctl`` 客户端运行参数:

.. literalinclude:: etcd_env/etcd.env
   :language: bash
   :caption: **正确的** 采用 ``/etc/etcd.env`` 输出环境变量来使用 ``etcdctl``
   :emphasize-lines: 3

- 执行以下脚本命令为自己构建一个环境变量:

.. literalinclude:: etcd_env/etcdctl_env
   :language: bash
   :caption: **正确的** 采用 ``/etc/etcd.env`` 输出环境变量来使用 ``etcdctl``
   :emphasize-lines: 3

- 此时执行 ``etcd_status`` 就能正确看到当前集群的etcd状态:

.. literalinclude:: etcd_env/etcd_status_output
   :caption: 包装一个 ``etcd_status`` 命令查看etcd健康状态
