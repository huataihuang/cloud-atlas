.. _k8s_rbd:

=============================
在Kubernetes中部署RBD存储
=============================

Kubernetes 的 RBD 存储制备器(Storage Provisioner)就是 :ref:`ceph_rbd` 内部驱动。但是， **Kubernetes v1.28已经废弃了Ceph RBD** ，改为采用 :ref:`ceph-csi` 。所以在最新的Kubernetes部署时，请顺应社区路线，采用标准 :ref:`k8s_csi` 实现 ``Ceph CSI`` 。
