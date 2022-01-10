.. _edge_cloud_infra:

======================
边缘云计算架构
======================

我陆续购买多多代 :ref:`raspberry_pi` 设备，在最初构建 :ref:`priv_cloud_infra` 时，我采用的还是完整的 :ref:`kubernetes_arm` 。不过，我也在思考如何能够尽可能少消耗树莓派的硬件资源来完成更多的计算。轻量级始终是ARM架构(资源有限的系统)的技术关键，类似 :ref:`akraino` ，我逐步想要在ARM架构上构建一个轻量级的边缘计算平台。

硬件环境
=========

我购买过多代树莓派产品以及 :ref:`jetson_nano` :

- :ref:`pi_1` - 构建边缘云计算(监控)
- :ref:`pi_3` - 构建边缘云计算(管控节点)
- :ref:`pi_4` - 构建边缘云计算(计算节点)
- :ref:`jetson_nano` - 构建边缘云计算( :ref:`machine_learning` )
- :ref:`pi_400` - 作为管理和操作

ARM服务器分布
=============

.. csv-table:: ARM边缘计算主机分配
   :file: edge_cloud_infra/hosts.csv
   :widths: 20, 10, 10, 10, 20, 30
   :header-rows: 1

ARM架构的边缘计算采用了 ``192.168.7.x`` 作为网络IP段，和 :ref:`priv_cloud_infra` 的 ``192.168.6.x`` 隔离，中间采用 3层 :ref:`cisco` 路由

虽然也可以在树莓派上实现 :ref:`arm_kvm` ，但是考虑到边缘计算硬件性能有限，所以采用轻量级 :ref:`kubernetes` 实现 :ref:`k3s` 来构建mini集群，目标是实现:

- 任意调度计算资源实现服务的伸缩、高可用
- 构建边缘计算场景: 传感器数据采集、存储、传输，以及独立的AI计算，结合 :ref:`private_cloud` 的强大算力，实现云计算的合理分布

