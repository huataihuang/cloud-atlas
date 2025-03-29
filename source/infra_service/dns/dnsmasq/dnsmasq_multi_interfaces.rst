.. _dnsmasq_multi_interfaces:

======================
DNSmasq多网卡
======================

我在 :ref:`priv_cloud_infra` 中同时构建了 :ref:`z-k8s` 和 :ref:`y-k8s` 两个 :ref:`kubernetes` 集群，分别使用了不同的网段 ``192.168.6.0/24`` 和 ``192.168.8.0/24`` 。在物理网卡 ``eno1`` 上通过 ``ip alias`` 为 :ref:`libvirt_bridged_network` 为多个虚拟机网络提供网段路由。此外，我也想为我的局域网客户端(例如我的工作笔记本)提供DNS解析，这就涉及到DNSmaq的多网卡DNS服务

参考 ``/etc/dnsmasq.conf`` 配置注释，也结合 :ref:`dnsmasq_domains_for_subnets` 采用如下配置:

.. literalinclude:: deploy_dnsmasq/dnsmasq.conf
   :language: ini
   :emphasize-lines: 6,8

这里 ``br0`` 上使用了 :ref:`netplan` 做了 IP Alias，也就是一个网卡上绑定多个IP地址来为 :ref:`libvirt_bridged_network` 的多个网段进行路由

参考
=====

- `Restricting dnsmasq's DHCP server to one interface <https://serverfault.com/questions/144674/restricting-dnsmasqs-dhcp-server-to-one-interface>`_
