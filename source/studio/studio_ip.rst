.. _studio_ip:

=========================
Studio测试环境IP分配
=========================

在模拟测试环境中，采用了KVM虚拟化来实现单台主机（MacBook Pro）来模拟集群的部署，以下是部署的步骤，如果你准备借鉴我的实验环境部署方法，可以先跳到以下章节参考:

- :ref:`create_vm`
- :ref:`clone_vm`
- :ref:`kvm_nested_virtual`
- :ref:`libvirt_static_ip_in_studio`

物理机/虚拟化/容器
===================

纵观我的 :ref:`introduce_my_studio` 依旧 :ref:`real_think` ，始终都是结婚了物理主机、KVM虚拟化和容器即技术(Kubernetes)来实现的。为了区分不同的主机，我规划主机命名策略:

- worker-X :ref:`real` 真实物理主机
- machine-X 使用KVM的 :ref:`kvm_nested_virtual` 技术模拟物理主机
- vm-X 使用KVM虚拟化技术虚拟出来的Guest主机，通用虚拟机，不使用 :ref:`kvm_nested_virtual` 技术

  - kubemaster-X 在VKM虚拟机运行的Kubernetes集群master节点
  - kubenode-X 在VKM虚拟机运行的Kubernetes集群worker节点

- vc-X (较少使用)直接命名的运行容器，通常会做一些容器验证测试。不过，在 :ref:`kubernetes` 环境中通常容器会起一个和应用有关的命名，例如 ``mangdb-1``

MacBook模拟集群
==================

为方便测试环境服务部署，部分关键服务器采用了静态IP地址，解析地址如下（配置在Host主机上）

.. literalinclude:: hosts
   :language: bash
   :linenos:
   :caption:

VMware虚拟环境IP分配
=======================

补充笔记本 :ref:`vmware_fusion` 环境使用的IP::

   192.168.161.10  devstack
