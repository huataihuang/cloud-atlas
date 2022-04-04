.. _edge_jetson_net:

========================
边缘计算Jetson Nano网络
========================

组建 :ref:`edge_cloud_infra` 中的 :ref:`edge_jetson` 采用 :ref:`ubuntu_linux` ，硬件上采用了外接无线模块，类似于无线路由器:

.. figure:: ../../_static/machine_learning/jetson/hardware/jetson_shell.png
   :scale: 75

我的模拟云计算环境， :ref:`priv_cloud_infra` 采用一台二手到 :ref:`hpe_dl360_gen9` 构建的 :ref:`kvm_nested_virtual` ，所以这台物理服务器是稳定运行的关键基础。现代服务器都具备 :ref:`ipmi` 支持，可以通过主板集成的BMC进行管理。对于这台决定整个云计算模拟集群关键基础的服务器，需要有独立通道来访问带外管理，包括重启以及服务器终端访问。 我选择这台Jetson Nano主机来管理服务器带外:

 - 配置Nano的WiFi连接局域网
 - Nano的有线网络通过交换机和 :ref:`hpe_dl360_gen9` 连接，通过 :ref:`conman` 来管理终端
 - 配置Nano主机的SSH tunnel端口转发，可以从外部直接访问服务器 :ref:`hp_ilo` 的WEB管理管控服务器运维，包括升级系统

Jetson Nano WiFi
====================

:ref:`jetson_nano` 操作系统是 :ref:`ubuntu_linux` WorkStation版本，使用 :ref:`networkmanager` 管理维护网络，以下为快速配置方法:

- 检查无线网络AP::

   sudo nmcli device wifi list

- 配置 ``/etc/default/crda`` 设置5GHz无线网络国家编码::

   REGDOMAIN=CN

- 增加连接到 ``office`` 热点的网络连接:

.. literalinclude:: ../../linux/ubuntu_linux/network/networkmanager/nmcli_wifi_wpa-eap
   :language: bash
   :caption: nmcli添加wpa-eap认证(802.1x)wifi

- 连接 ``office`` 热点::

   nmcli con up office

端口转发 - :ref:`hp_ilo`
==========================

:ref:`hpe_dl360_gen9` 的带外管理网口是内部独立网段 ``192.168.6.x`` 上的 ``192.168.6.254`` ，从外部无法直接访问，所以我通过 :ref:`jetson_nano` 的 :ref:`ssh_tunneling` 做端口转发，这样只要ssh登陆到网关主机( :ref:`jetson_nano` )就可以从外部访问到服务器的 :ref:`hp_ilo`

- 配置 ``~/.ssh/config`` (采用 :ref:`ssh_multiplexing` 结合 :ref:`ssh_tunneling` ):

.. literalinclude:: ../../infra_service/ssh/ssh_multiplexing/ssh_config
   :language: bash
   :caption: ~/.ssh/config 配置所有主机登陆激活ssh multiplexing,压缩以及不检查服务器SSH key(注意风险控制)

.. literalinclude:: ../../infra_service/ssh/ssh_tunneling/ssh_config
   :language: bash
   :caption: ~/.ssh/config 配置SSH端口转发


