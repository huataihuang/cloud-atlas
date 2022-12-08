.. _mobile_cloud_libvirt_network:

===============================
移动云计算libvirt网络
===============================

在构建 :ref:`mobile_cloud_infra` ARM架构的 :ref:`asahi_linux` ，除了需要手工部署 :ref:`mobile_cloud_libvirt_lvm_pool` 还需要构建一个连接在 :ref:`asahi_lnux_wifi` 的 ``libvirt`` 网络。由于libvirt网路限制，只能选择 :ref:`libvirt_nat_network`

NAT网络
=========

默认的 ``libvirt`` 已经构建了一个NAT网络::

   virsh net-list --all

可以看到::

    Name      State      Autostart   Persistent
   ----------------------------------------------
    default   inactive   no          yes

启动这个默认网络::

   virsh net-start default

设置NAT网络自动启动::

   virsh net-autostart default

此时使用 ``brctl show`` 可以看到::

   bridge name     bridge id               STP enabled     interfaces
   ...
   virbr0          8000.525400810f5a       yes

.. note::

   为了能够方便对外服务，我原本想构建 :ref:`libvirt_bridged_network` ，但是Apple Macbook Pro笔记本默认没有有线以太网卡，通常只能通过无线网络连接外部。这就带来一个问题， ``libvirt_bridge_network`` 只支持有线网络。

   然而， :ref:`libvirt_routed_network` 虽然支持无线网络，但是需要准备一批IP地址预分配给虚拟机(相当于虚拟机直连局域网)，并不适合我的模拟环境(因为我不能控制局域网IP地址分配)。所以，最终我还是只采用NAT网络。

固定IP地址
============

对于 :ref:`mobile_cloud_infra` ，虚拟机需要采用固定的IP地址，所以需要调整 ``libvirt`` 的 :ref:`dnsmasq` 采用规划的IP地址段以及让出固定IP地址不用于DHCP: 方法类似 :ref:`libvirt_static_ip_in_studio`

- 调整libvirt的地址段: 改成 192.168.8.x
- 调整libvirt的DHCP地址分配: 只分配 192.168.8.2~192.168.8.50

NAT网络也就是 ``default virtual network`` ，首先检查 ``libvirt`` 网络:

.. literalinclude:: mobile_cloud_libvirt_network/virsh_net-list
   :language: bash
   :caption: virsh net-list检查网络

输出显示:

.. literalinclude:: mobile_cloud_libvirt_network/virsh_net-list_output
   :language: bash
   :caption: virsh net-list检查网络，当先default网络已激活

- 修改 ``default`` 网络:

.. literalinclude:: mobile_cloud_libvirt_network/virsh_net-edit
   :language: bash
   :caption: virsh net-edit修改默认网络配置

默认配置如下:

.. literalinclude:: mobile_cloud_libvirt_network/virsh_default_net.xml
   :language: bash
   :caption: virsh 默认网络的配置

修订成:

.. literalinclude:: mobile_cloud_libvirt_network/virsh_default_net_change.xml
   :language: bash
   :caption: virsh 默认网络的配置修改IP段及网关地址

- 重新生成libvirt ``default`` NAT网络:

.. literalinclude:: mobile_cloud_libvirt_network/virsh_recreate_default_net
   :language: bash
   :caption: virsh 重建默认网络

然后需要重启虚拟机重联网络，或者重新将虚拟机网络连接::

   brctl addif virbr0 vnet0
   brctl addif virbr0 vnet1
   ...

.. note::

   :ref:`mobile_cloud_vm` 采用静态IP地址

参考
======

- `libvirt Networking Handbook - NAT-based network <https://jamielinux.com/docs/libvirt-networking-handbook/nat-based-network.html>`_
