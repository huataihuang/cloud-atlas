.. _ceph_csi_arch:

=====================
Ceph CSI架构
=====================

`CSI driver for Ceph <https://github.com/ceph/ceph-csi>`_ 提供了 :ref:`ceph_rbd` , :ref:`cephfs` 的驱动，以及Kubernetes :ref:`sidecar` 部署YAML来支持CSI功能:

- provisioner
- attacher
- resizer
- driver-register
- snapshotter

概览
=======

Ceph CSI plugins 实现了一个 CSI-enabled 容器编排(Container Orchestrator, CO) 和 Ceph 集群之间的接口，可以动态提供Ceph 卷并将卷添加到 :ref:`k8s_workloads` :

- 支持 :ref:`ceph_rbd` 和 :ref:`cephfs` 后端卷:

  - :ref:`ceph_csi_rbd`
  - :ref:`ceph_csi_cephfs`

参考
==========

- `CSI driver for Ceph <https://github.com/ceph/ceph-csi>`_
