.. _libvirt_routed_network:

======================
libvirt 路由型网络
======================

.. note::

   ``routed network`` 是仅用于 :ref:`libvirt_bridged_network` 无法使用的特殊情况: :ref:`libvirt_bridged_network` 不支持无线网络。

   但是 ``routed network`` 有一个极大的局限性: 必须将局域网的一部分IP地址段预留给VM。这个限制在很多动态分配IP(不能自主控制的)无线网络是无法避免的，所以实际使用也不是很方便。

.. warning::

   本文内容我尚未实践，主要是我阅读 `libvirt Networking Handbook - NAT-based network <https://jamielinux.com/docs/libvirt-networking-handbook/routed-network.html>`_ 后发现使用场景非常有限，尚未有迫切需求部署这样的网络。

参考
========

- `libvirt Networking Handbook - NAT-based network <https://jamielinux.com/docs/libvirt-networking-handbook/routed-network.html>`_
