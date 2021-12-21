.. _k8s_hosts:

=====================
Kubernetes部署服务器
=====================

在部署模拟Kubernetes集群的环境中，我采用如下虚拟机部署:

- 3台 Kubernetes Mster
- 5台 Kubernetes Node
- 2台 HAProxy
- 3台 etcd

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

   for i in {1..3};do
     virt-clone --connect qemu:///system --original centos7 --name etcd-${i} --file /var/lib/libvirt/images/etcd-${i}.qcow2
     virt-sysprep -d etcd-${i} --hostname etcd-${i} --root-password password:CHANGE_ME
     virsh start etcd-${i}
   done

.. note::

   稳定运行的Kubernetes集群需要3台Master服务器，这里多创建多 ``kubermaster-4`` 是为了演练Master服务器故障替换所准备的。

   haproxy-X是用于构建 :ref:`ha_k8s` 时所需的负载均衡，用于提供apiserver的负载均衡能力。

主机名解析
=============

在运行KVM的物理主机上 ``/etc/hosts`` 配置模拟集群的hosts域名解析

libvirt dnsmasq
-----------------

但是，在KVM虚拟机集群中，如何能够使得所有虚拟机都获得统一的DNS解析呢？显然，在集群中运行一个DNS服务器是一个解决方案。但是，请注意，在KVM libvirt的运行环境中，默认就在libvirt中运行了一个dnsmasq，实际上为 ``virtbr0`` 网络接口上连接的所有虚拟机提供了DNS解析服务。通过在物理服务器上检查 ``ps aux | grep dnsmasq`` 可以看到::

   nobody    13280  0.0  0.0  53884  1116 ?        S    22:15   0:00 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper
   root      13281  0.0  0.0  53856   380 ?        S    22:15   0:00 /usr/sbin/dnsmasq --conf-file=/var/lib/libvirt/dnsmasq/default.conf --leasefile-ro --dhcp-script=/usr/libexec/libvirt_leaseshelper

检查libvirt的dnsmasq配置文件 ``/var/lib/libvirt/dnsmasq/default.conf`` 可以看到::

   strict-order
   pid-file=/var/run/libvirt/network/default.pid
   except-interface=lo
   bind-dynamic
   interface=virbr0
   dhcp-range=192.168.122.51,192.168.122.254
   dhcp-no-override
   dhcp-authoritative
   dhcp-lease-max=204
   dhcp-hostsfile=/var/lib/libvirt/dnsmasq/default.hostsfile
   addn-hosts=/var/lib/libvirt/dnsmasq/default.addnhosts

上述配置:

- ``interface=virbr0`` 表示libvirt dnsmasq只对 ``virtbr0`` 接口提供服务，所以也就只影响NAT网络中对虚拟机
- ``dhcp-range=192.168.122.51,192.168.122.254`` 是我配置的DHCP范围
- ``dhcp-hostsfile=/var/lib/libvirt/dnsmasq/default.hostsfile`` 是配置静态分配DHCP地址的配置文件
- ``addn-hosts=/var/lib/libvirt/dnsmasq/default.addnhosts`` 是配置dnsmasq的DNS解析配置文件，类似 ``/etc/hots``

参考 `KVM: Using dnsmasq for libvirt DNS resolution <https://fabianlee.org/2018/10/22/kvm-using-dnsmasq-for-libvirt-dns-resolution/>`_ ，执行 ``virsh net-edit default`` 编辑 libvirt 网络，添加 ``<dns></dns>`` 段落:

.. literalinclude:: ../../../studio/libvirt_net_default.xml
   :language: xml
   :emphasize-lines: 7-53
   :linenos:
   :caption: virsh net-edit default

然后重启libvirt default网络::

   sudo virsh net-destroy default
   sudo virsh net-start default

此时检查物理服务器的 ``/var/lib/libvirt/dnsmasq/default.addnhosts`` 内容，原先空白的文件就会自动填写上类似 ``/etc/hosts`` 这样的配置静态IP解析::

   192.168.122.5    etcd-1.test.huatai.me
   192.168.122.6    etcd-2.test.huatai.me
   ...

.. note::

   之前我的实践发现，直接修改 ``/var/lib/libvirt/dnsmasq/default.addnhosts`` 添加静态解析内容，然后重建 ``default`` 网络也能够实现相同的DNS解析。但是，我发现过一段时间以后物理服务器的 ``/var/lib/libvirt/dnsmasq/default.addnhosts`` 会被清空。不过，在虚拟机网络中，依然能够解析DNS。似乎直接修改文件不是好的方法，所以还是参考上述文档通过修订default网络的xml来完成配置。

注意，重启网络之后，所有虚拟机的虚拟网卡会脱离网桥 ``virbr0`` ，需要重新连接::

   for i in {0..13};do sudo brctl addif virbr0 vnet${i};done

随后登陆任意虚拟机，尝试解析DNS，例如，解析后续作为apiserver的VIP地址::

   dig kubeapi.test.huatai.me

输出应该类似::

   kubeapi.test.huatai.me.    0    IN    A    192.168.122.10

而且可以使用短域名解析::

   dig kubeapi

输出::

   kubeapi.        0    IN    A    192.168.122.10

.. note::

   如果要使用独立的dnsmasq对外提供DNS解析服务，可以参考我之前的实践 `DNSmasq 快速起步 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/service/dns/dnsmasq/dnsmasq_quick_startup.md>`_ 或者 `KVM: Using dnsmasq for libvirt DNS resolution <https://fabianlee.org/2018/10/22/kvm-using-dnsmasq-for-libvirt-dns-resolution/>`_

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
