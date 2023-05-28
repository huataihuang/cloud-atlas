.. _kube-prometheus-stack_coredns:

=======================================
``kube-prometheus-stack`` 监控CoreDNS
=======================================

在部署 :ref:`docker_run_coredns` 之后，需要修订 ``kube-prometheus-stack`` 来监控独立部署的 :ref:`coredns` :

- 采用独立抓取(scrap)主机节点端口 ``553`` :ref:`metrics`
- 关闭默认通过k8s的 ``prometheus_sd_config`` 方式获取coredns targets(原因是废弃了k8s集群内置coredns

默认CoreDNS scrap
====================

- 默认 ``values.yaml`` 中配置scrap coreDns的配置如下:

.. literalinclude:: kube-prometheus-stack_coredns/values.yaml
   :language: yaml
   :caption: 默认coreDns的scrap配置
   :emphasize-lines: 5-7

修订node抓取配置
==================
