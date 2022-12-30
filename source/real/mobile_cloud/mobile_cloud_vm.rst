.. _mobile_cloud_vm:

=============================
移动云的虚拟机部署
=============================

从架构上来说，和 :ref:`priv_cloud_infra` 相似，我在Apple Silicon硬件上采用分工不同的两组虚拟化：

- 底层虚拟机: 一组由3个 :ref:`fedora` 虚拟机，每个虚拟机分配一个LVM卷作为虚拟磁盘，构建一个 :ref:`ceph` 分布式存储来模拟云计算底层存储
- 上层虚拟机: 一组由5个 :ref:`fedora` 虚拟机构建成一个 :ref:`kubernetes` 集群，来实现云计算的现代化容器云。这些虚拟机不直接使用物理主机的虚拟磁盘，而是使用 "底层虚拟机" 的分布式存储 :ref:`ceph` ，虽然结构复杂，但是能够模拟出云计算厂商的技术。

此外，还尝试探索ARM架构的嵌套虚拟化，也就是在 :ref:`kvm` 虚拟机内部再运行虚拟机，这样可以在一台主机上模拟出多个物理主机，理论上可以部署出规模化的虚拟化集群。(性能有限，但是虚拟化无限)

底层虚拟机
==============

按照 :ref:`mobile_cloud_infra` ，底层虚拟机运行:

- :ref:`fedora37_installation` (最小化安装)
- :ref:`mobile_cloud_libvirt_network` 配置静态IP地址

更新软件
-----------

- 更新软件并安装 ``systemd-networkd`` (用于配置静态IP)::

   dnf update
   dnf install systemd-networkd

设置主机名和静态IP
-------------------

- 使用 :ref:`hostnamectl` 配置主机名:

.. literalinclude:: mobile_cloud_vm/hostnamectl
   :language: bash
   :caption: 设置mobile cloud的虚拟机主机名

- 使用 :ref:`systemd_networkd_static_ip` :

.. literalinclude:: mobile_cloud_vm/systemd_networkd_mobile_cloud_vm_ip
   :language: bash
   :caption: 使用systemd-networkd配置mobile cloud的虚拟机IP

并切换到 ``systemd-networkd`` 使得静态IP地址生效:

.. literalinclude:: ../../linux/redhat_linux/systemd/systemd_networkd/switch_systemd-networkd
   :language: bash
   :caption: NetworkManager切换到systemd-networkd使静态IP生效

.. note::

   :ref:`fedora` 默认使用 :ref:`networkmanager` 管理网络，我最初想简化为采用 :ref:`systemd_networkd` 来管理网络(毕竟操作系统都采用了 :ref:`systemd` )，但是我发现 Fedora Server 启用的 :ref:`cockpit` 网络是采用 :ref:`networkmanager` ，切换后反而引发不能通过cockpit管理网络的问题，所以我在后续的 :ref:`mobile_cloud_k8s` 中使用的虚拟机操作系统，就保留默认 :ref:`networkmanager` 管理网络。

上层虚拟机
================

上层虚拟机模拟运行在 :ref:`ceph` 分布式存储上，和云计算厂商，如阿里云、AWS等相似，通过分布式存储来实现高可用和高性能存储。当出现上前述作为存储的 "底层虚拟机" (对应于云厂商的物理服务)单机故障，不会影响到整个模拟云计算系统的故障。

在上层虚拟机同样采用 :ref:`fedora` :

- 作为Red Hat Enterprise Linux企业级Linux发行版的上游项目， :ref:`fedora` 提供了最新的Linux技术预览，不仅能够尝试最新的社区技术，而且能够兼容Red Hat企业部署
- 内核主线是目前主流发行版中最新(kernel 6.0.7)，可以充分发挥 Apple Silicon 处理器优势

按照 :ref:`mobile_cloud_infra` ，底层虚拟机运行:

- :ref:`fedora37_installation` (最小化安装)

配置静态IP
-----------

- 使用 :ref:`networkmanager` 命令行 ``nmcli`` 完成静态IP配置:

.. literalinclude:: ../../linux/redhat_linux/fedora/fedora_networkmanager/nmcli_con_static_ip
   :language: bash
   :caption: nmcli con mod (connection modify) 修改网络配置(静态IP)

激活sudo
------------

- 配置 ``huatai`` 用户的 sudo 权限:

.. literalinclude:: mobile_cloud_vm/sudo
   :language: bash
   :caption: 配置sudo无密码

更新软件
-----------

- 更新软件并安装 ``systemd-networkd`` (用于配置静态IP)::

   dnf update

