.. _k8s_node-local-dns:

=======================================
Kubernetes集群 ``node-local-dns`` 缓存
=======================================

.. _k8s_node-local-dns_force_tcp:

``node-local-dns`` 强制使用TCP访问CoreDNS
===========================================

CoreDNS运行对外提供的是 ``TCP`` 53端口，所以采用默认的 ``dig`` 命令查询时，由于 ``docker run`` 只映射TCP端口，所以就会查询超时。解决的方法是在 ``dig`` 查询命令令中添加 ``+tcp`` 参数:

.. literalinclude:: ../../../infra_service/dns/bind/dig/dig_tcp
   :language: bash
   :caption: dig的 ``+tcp`` 参数可以采用TCP方式查询DNS解析

参考
======

- `Nodelocal DNS Cache <https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/dns/nodelocaldns>`_
- `Setting up NodeLocal DNS Cache <https://cloud.yandex.com/en/docs/managed-kubernetes/tutorials/dns-autoscaler>`_
