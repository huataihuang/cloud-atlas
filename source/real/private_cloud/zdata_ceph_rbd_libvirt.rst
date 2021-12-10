.. _zdata_ceph_rbd_libvirt:

==================================
私有云基于 ZData Ceph 运行虚拟机
==================================

按照 :ref:`zdata_ceph` 部署作为整个虚拟化底层Ceph存储，用于第一层KVM虚拟机的镜像存储。

部署方案
==========

- :ref:`ceph_rbd_libvirt` 提供KVM虚拟机管理 :ref:`zdata_ceph`
- 基于 :ref:`ceph_rbd` 存储部署 :ref:`ubuntu_linux`
- :ref:`clone_vm_rbd` 复制出满足部署 :ref:`kubernetes` 和 :ref:`openstack` 集群的第一层虚拟机
- 采用 :ref:`kvm_libguestfs` 对clone后的VM镜像进行定制，正确配置主机名、IP以及必要配置


