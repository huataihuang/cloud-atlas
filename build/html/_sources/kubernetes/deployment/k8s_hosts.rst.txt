.. _k8s_hosts:

=====================
Kubernetes部署服务器
=====================

在部署模拟Kubernetes集群的环境中，我采用如下虚拟机部署:

- 3台 Kubernetes Mster
- 5台 Kubernetes Node

clone k8s虚拟机
==================

.. note::

   本案例在单台物理主机上部署多个KVM虚拟机，这些虚拟机是在该物理主机的NAT网络中，所以外部不能直接访问（需要端口映射）。

- clone虚拟就::

   virsh shutdown centos7

   for i in {1..4};do
     virt-clone --connect qemu:///system --original centos7 --name kubemaster-${i} --file /var/lib/libvirt/images/kubemaster-${i}.qcow2
     virt-sysprep -d kubemaster-${i} --hostname kubemaster-${i} --root-password password:CHANGE_ME
     virsh start kubemaster-${i}
   done

   for i in {1..5};do
     virt-clone --connect qemu:///system --original centos7 --name kubenode-${i} --file /var/lib/libvirt/images/kubenode-${i}.qcow2
     virt-sysprep -d kubenode-${i} --hostname kubenode-${i} --root-password password:CHANGE_ME
     virsh start kubenode-${i}
   done

   for i in {1..2};do
     virt-clone --connect qemu:///system --original centos7 --name haproxy-${i} --file /var/lib/libvirt/images/haproxy-${i}.qcow2
     virt-sysprep -d haproxy-${i} --hostname haproxy-${i} --root-password password:CHANGE_ME
     virsh start haproxy-${i}
   done


.. note::

   稳定运行的Kubernetes集群需要3台Master服务器，这里多创建多 ``kubermaster-4`` 是为了演练Master服务器故障替换所准备的。

   haproxy-X是用于构建 :ref:`ha_k8s` 时所需的负载均衡，用于提供apiserver的负载均衡能力。

主机名解析
=============

在运行KVM的物理主机上 ``/etc/hosts`` 提供了模拟集群的域名解析，在DNSmasq中可以提供配置

.. literalinclude:: hosts
   :language: bash
   :linenos:
   :caption:

pssh配置
==========

为了方便在集群多台服务器上同时安装软件包和进行基础配置，采用pssh方式执行命令，所以准备按照虚拟机用途进行分组如下：

.. literalinclude:: kube
    :language: bash
    :linenos:
    :caption:

.. literalinclude:: kubemaster
    :language: bash
    :linenos:
    :caption:

.. literalinclude:: kubenode
    :language: bash
    :linenos:
    :caption:

这样，例如需要同时安装docker软件包，只需要执行::

   pssh -ih kube 'yum install docker-ce -y'
