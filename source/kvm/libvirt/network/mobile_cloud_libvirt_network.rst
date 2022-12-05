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
