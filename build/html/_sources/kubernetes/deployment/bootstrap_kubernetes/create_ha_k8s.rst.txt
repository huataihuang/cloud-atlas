.. _create_ha_k8s:

============================
使用kubeadm创建高可用集群
============================

正如 :ref:`ha_k8s` 所述，构建Kubernetes高可用集群，以etcd是否独立部署来划分两种不同对HA部署架构：

- 堆叠部署etcd
- 独立部署etcd

负载均衡
==========

不管采用哪种HA部署方式，都需要使负载均衡来分发worker节点对请求和连接给后端的多个apiserver。请先部署 :ref:`ha_k8s_lb` 实现通过负载均衡VIP访问已经创建的 :ref:`single_master_k8s` ，这样就可以在此基础上扩展部署多Master高可用架构。

.. note::

   由于负载均衡部署较为复杂，所以单独撰写了 :ref:`ha_k8s_lb` ，请先完成负载均衡部署再继续构建高可用集群。当然，负载均衡不仅仅是我的实践案例 ``Keepalived+HAProxy`` ，你也可以使用其他软件或硬件负载均衡。


不同类型高可用集群部署
============================

在完成了 :ref:`ha_k8s_lb` 之后，就可以按照不同类型高可用集群分别部署:

- :ref:`ha_k8s_stacked`
- :ref:`ha_k8s_external`

参考
==========

- `Creating Highly Available clusters with kubeadm <https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/>`_
