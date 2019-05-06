.. _studio_ip:

=========================
Studio测试环境IP分配
=========================

在模拟测试环境中，采用了KVM虚拟化来实现单台主机（MacBook Pro）来模拟集群的部署，以下是部署的步骤，如果你准备借鉴我的实验环境部署方法，可以先跳到以下章节参考:

- :ref:`create_vm_in_studio`
- :ref:`clone_vm_in_studio`
- :ref:`nested_virtualization_in_studio`
- :ref:`libvirt_static_ip_in_studio`

为方便测试环境服务部署，部分关键服务器采用了静态IP地址，解析地址如下（配置在Host主机上）

.. literalinclude:: hosts
   :language: bash
   :linenos:
   :caption:

VMware虚拟环境IP分配
=======================

补充笔记本 :ref:`vmware_in_studio` 环境使用的IP::

   192.168.161.10  devstack
