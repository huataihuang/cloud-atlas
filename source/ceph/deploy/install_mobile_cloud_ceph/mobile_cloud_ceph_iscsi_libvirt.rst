.. _mobile_cloud_ceph_iscsi_libvirt:

================================
移动云计算Libvirt集成Ceph iSCSI
================================

由于 :ref:`arch_linux` ARM的软件仓库对 ``libvirt-storage-ceph`` 缺失，所以我在部署 :ref:`mobile_cloud_ceph_rbd_libvirt` 遇到较大困难暂时放弃。我调整方案，改为采用 :ref:`ceph_iscsi` 为 :ref:`kvm` 虚拟化服务器集群提供分布式存储。

待续
