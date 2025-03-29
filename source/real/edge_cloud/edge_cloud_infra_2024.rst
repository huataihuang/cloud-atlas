.. _edge_cloud_infra_2024:

======================
边缘云计算架构(2024)
======================

2024年，由于 :ref:`whats_past_is_prologue` 而在各地旅行，为了能够继续学习和实践云计算技术，我在旅途中携带 :ref:`raspberry_pi` 组建的 ARM 堆叠集群，力图能够在低功耗、轻量级的环境中构建企业级边缘云计算。

.. note::

   部署 :ref:`k3s` 集群时候，将部分参考 `rpi4cluster.com <https://rpi4cluster.com/>`_ 方案，但我的个人实践采用的硬件和方法不同

   我准备借鉴并尝试不同的应用应用迭代，构建适合自己同时能够进一步完善的解决方案。

我将树莓派组建成一个微型集群，运行 :ref:`k3s` 并通过 :ref:`rancher` 实现一个PaaS环境。这是一个个人开发和实践环境，通过完整的CI/CD来实现个人工作室。

.. note::

   2024年3月，重新部署 :ref:`raspberry_pi` 集群，采用了树莓派官方 :ref:`raspberry_pi_os` 操作系统，原因是官方系统现已完美支持64位，并且由于使用广泛，可以通过社区获得较好的支持。我计划重新部署 :ref:`kubernetes` 集群，构建完整的模拟Cloud Atlas集群

硬件环境
=========

我最初主要考虑省钱，有几个思路:

- 只购买一台 :ref:`pi_5` ，然后通过部署 :ref:`kind` 来模拟整个 :ref:`kubernetes` 集群
- 想利旧我之前购买的 :ref:`pi_4` ，也就是将3台 :ref:`pi_4` 作为管控节点，运行起一个初始化的 :ref:`kubernetes` ，然后将 :ref:`pi_5` 来作为工作节点(最初只购买一台)，这样也能通过降低硬件成本来节约资金

不过最终我还是没有忍住，陆续购买了3台 :ref:`pi_5` ，并且配套 :ref:`pi_5_pcie_m.2_ssd` ，目标是能够实现和 :ref:`priv_cloud` 相似功能(但性能较弱):

- :ref:`k3s` 实现 :ref:`kubernetes` ，部署企业级的业务容器
- 后端持久化存储采用 :ref:`ceph` :ref:`gluster` :ref:`zfs` ，实践 :ref:`arm` 边缘计算
- 后续补充 :ref:`hailo_ai` 学习实践 :ref:`machine_learning`
- 如果还能修好 :ref:`jetson_nano`

ARM服务器分布
=============

.. csv-table:: ARM边缘计算主机分配
   :file: edge_cloud_infra_2024/hosts.csv
   :widths: 20, 10, 10, 10, 20, 30
   :header-rows: 1

ARM架构的边缘计算采用了 ``192.168.7.x`` 作为网络IP段，和 :ref:`priv_cloud_infra` 的 ``192.168.6.x`` 隔离

虽然也可以在树莓派上实现 :ref:`arm_kvm` ，但是考虑到边缘计算硬件性能有限，所以采用轻量级 :ref:`kubernetes` 实现 :ref:`k3s` 来构建mini集群，目标是实现:

- 任意调度计算资源实现服务的伸缩、高可用
- 构建边缘计算场景: 传感器数据采集、存储、传输，以及独立的AI计算

.. note::

   - 服务器主机IP段位于:

     - 192.168.7.1 ~ 192.168.7.150
     - 192.168.7.200 ~ 192.168.7.254

   - 保留一段IP用于内网DHCP，提供手机等移动客户端使用:

     - 192.168.7.151 ~ 192.168.7.199
