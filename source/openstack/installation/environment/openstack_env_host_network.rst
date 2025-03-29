.. _openstack_env_host_network:

============================
OpenStack环境物理主机网络
============================

.. note::

   建议关闭物理主机自动网络管理工具并手工编辑发行版的相应配置文件。

所有OpenStack物理节点需要管理员权限的Internet访问，以完成：软件包安装，安全升级，DNS和NTP。大多数情况下，主机及诶单通过专用管理的网络接口获得Internet访问。对于安全要求高的网络系统，需要在管理专用网络中使用私有网络地址，并通过NAT方式访问Internet。

在provider网络架构(即直连经典网络)所有虚拟机实例直接连接provider网络。在self-service(私有网络，即VXLAN)网络架构，虚拟机实例是连接到self-service或provider网络。self-service网络可以整个部署在OpenStack之内或者使用NAT通过provider网络访问外部网络。

.. note::

   安全隔离网络：生产专用网络和管理专用网络应该隔离，并且物理主机的BMC网络也需要专用物理隔离网络。管理专用网络不能直接连接Internet，应该通过NAT方式只允许单向(从内向外)网络访问。如果有更高网络安全要求，可以隔离管理专用网络不连接Internet，而采用在内部局域网部署软件仓库，将Internet上软件仓库镜像到内部管理服务器上，并通过扫描和验证，才提供内部管理网络使用。

案例网络
========

.. figure:: ../../../_static/openstack/installation/environment/networklayout.png
   :scale: 90

案例网络解析：

- 管理专用网络使用 ``10.0.0.0/24`` 网段，网关 ``10.0.0.1``

在管理专用网络中设置网关提供了访问Internet能力，可以进行管理相关任务，如软件包安装，安全更新，DNS和NTP部署

- provider网络采用 ``203.0.113.0/24`` 网段，网关 ``203.0.113.1``

provider网络需要Internet访问以便提供OpenStack环境的虚拟机实例访问Internet

.. note::

   在 "案例网络" 中，OpenStack官方文档采用了 1 controller, 1 compute, 1 block, 2 object 的配置方案::

      # controller
      10.0.0.11       controller

      # compute1
      10.0.0.31       compute1

      # block1
      10.0.0.41       block1

      # object1
      10.0.0.51       object1

      # object2
      10.0.0.52       object2


   OpenStack官方文档的"案例网络"，请参考 `OpenStack官方安装指南 - Host networking <https://docs.openstack.org/install-guide/environment-networking.html>`_

我的实践网络
=============

我的实践采用的是 ``3台物理主机`` ，我计划先部署1个controller，然后再扩展成高可用HA模式管控服务器。计算节点将分布在3个物理主机上，存储采用Ceph来实现，所以存储是独立部署的3节点分布式存储。

物理服务器IP分配见 :ref:`real_prepare` :

.. literalinclude:: ../../../studio/hosts
   :language: bash
   :emphasize-lines: 72-80
   :linenos:


