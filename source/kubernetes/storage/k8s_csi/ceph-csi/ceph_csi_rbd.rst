.. _ceph_csi_rbd:

====================
Ceph CSI RBD Plugin
====================

Ceph CSI RBD plugin 可以提供一个 :ref:`ceph_rbd` 镜像，并将其附加和挂载到 :ref:`k8s_workloads` :

在Kubernetes中部署CSI RBD
============================

`CSI driver for Ceph <https://github.com/ceph/ceph-csi>`_ (GitHub仓库)提供部署的模版文件(源代码 ``deploy/rbd/kubernetes`` 目录下)，可以帮助我们在Kubernetes中部署:

- csi-config-map.yaml
- csidriver.yaml
- csi-nodeplugin-rbac.yaml
- csi-provisioner-rbac.yaml
- csi-rbdplugin-provisioner.yaml
- csi-rbdplugin.yaml

Kubernetes集群需要允许运行 :ref:`k8s_privileged_pod`

参考
======

- `ceph-csi/docs/deploy-rbd.md <https://github.com/ceph/ceph-csi/blob/devel/docs/deploy-rbd.md>`_
