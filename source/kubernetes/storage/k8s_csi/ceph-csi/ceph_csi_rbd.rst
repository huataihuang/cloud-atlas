.. _ceph_csi_rbd:

====================
Ceph CSI RBD Plugin
====================

Ceph CSI RBD plugin 可以提供一个 :ref:`ceph_rbd` 镜像，并将其附加和挂载到 :ref:`k8s_workloads` :

Ceph创建存储池
===============

- 默认情况戏，Ceph块设备使用 ``rbd`` 存储池。可以为Kubernetes集群创建一个Kubernetes卷存储池(确保Ceph集群运行状态，执行创建存储池。方法同 :ref:`ceph_rbd_libvirt` )，我这里创建了一个独立存储池给 ``y-k8s`` 集群使用，命名为 ``y-k8s-pool`` :

.. literalinclude:: ceph_csi_rbd/create_rbd_pool
   :caption: 为Kubernetes创建存储池

.. note::

   命令行操作创建存储池之后需要进行初始化才能使用。我这里实际上是采用 :ref:`ceph_dashboard` 完成，更为方便

在Kubernetes中部署CSI RBD
============================

`CSI driver for Ceph <https://github.com/ceph/ceph-csi>`_ (GitHub仓库)提供部署的模版文件(源代码 ``deploy/rbd/kubernetes`` 目录下)，可以帮助我们在Kubernetes中部署:

- csi-config-map.yaml
- csidriver.yaml
- csi-nodeplugin-rbac.yaml
- csi-provisioner-rbac.yaml
- csi-rbdplugin-provisioner.yaml
- csi-rbdplugin.yaml

Kubernetes集群需要

- 允许运行 :ref:`k8s_privileged_pod` : 即 ``apiserver`` 和 ``kubelet`` 的运行参数中具备 ``--allow-privileged=true`` (我使用 :ref:`kubespray_startup` 部署的 ``y-k8s`` 集群默认设置 )
- 在集群工作节点上 Docker daemon允许 :ref:`k8s_volume_mount_propagation` ，也就是允许共享挂载( **警告:安全隐患** )

创建 ``CSIDriver``
--------------------

- 创建 ``CSIDriver`` 对象:

.. literalinclude:: ceph_csi_rbd/create_csidriver
   :caption: 创建 ``CSIDriver`` 对象

.. literalinclude:: ceph_csi_rbd/csidriver.yaml
   :caption: ``csidriver.yaml``

此时检查 ``csidriver`` 对象:

.. literalinclude:: ceph_csi_rbd/get_csidriver
   :caption: 检查 ``csidriver``

输出显示:

.. literalinclude:: ceph_csi_rbd/get_csidriver_output
   :caption: 检查 ``csidriver`` 的输出

检查 ``csidriver`` 对象 spec:

.. literalinclude:: ceph_csi_rbd/get_csidriver_yaml
   :caption: 检查 ``csidriver`` 对象 spec

输出显示:

.. literalinclude:: ceph_csi_rbd/get_csidriver_yaml_output
   :caption: 检查 ``csidriver`` 对象 spec输出

部署sidecar容器和节点plugins的 ``RBACs``
------------------------------------------

使用清单(manifests) 部署服务账号，集群角色以及集群的角色绑定。这些设置是RBD和 :ref:`ceph_csi_cephfs` 共享的配置，所以必须是相同的权限

- 执行以下命令部署 ``RBACs`` :

.. literalinclude:: ceph_csi_rbd/csi_rbac
   :caption: 部署sidecar和node plugins的 ``RBACs``

.. literalinclude:: ceph_csi_rbd/csi-provisioner-rbac.yaml
   :caption: ``csi-provisioner-rbac.yaml``

.. literalinclude:: ceph_csi_rbd/csi-nodeplugin-rbac.yaml
   :caption: ``csi-nodeplugin-rbac.yaml``


部署CSI plugins的 ``ConfigMap``
-----------------------------------

`ceph-csi/docs/deploy-rbd.md <https://github.com/ceph/ceph-csi/blob/devel/docs/deploy-rbd.md>`_ 采用了一个空白CSI配置来挂载Ceph CSI plugin pods的卷，我没有理解为何这样操作。实际我参考 `BLOCK DEVICES AND KUBERNETES <https://docs.ceph.com/en/latest/rbd/rbd-kubernetes/>`_ 提供的 `GENERATE CEPH-CSI CONFIGMAP <https://docs.ceph.com/en/latest/rbd/rbd-kubernetes/#generate-ceph-csi-configmap>`_ 来生成这个configmap配置

``ceph-csi`` 需要一个ConfigMap对象来定义Ceph monitor地址，所以需要先搜集Ceph集群的 ``fsid`` 和 monitor 地址:

.. literalinclude:: ceph_csi_rbd/ceph_mon_dump
   :caption: 执行 ``ceph mon dump`` 获取集群配置信息

输出信息如下:

.. literalinclude:: ceph_csi_rbd/ceph_mon_dump_output
   :caption: 我的Ceph集群monitor信息
   :emphasize-lines: 2,7-9

- 根据上述信息，我们创建一个 ``csi-config-map.yaml`` 

参考
======

- `ceph-csi/docs/deploy-rbd.md <https://github.com/ceph/ceph-csi/blob/devel/docs/deploy-rbd.md>`_ README中，有关ceph config-map语焉不详，所以config-map参考 `BLOCK DEVICES AND KUBERNETES <https://docs.ceph.com/en/latest/rbd/rbd-kubernetes/>`_
- `BLOCK DEVICES AND KUBERNETES <https://docs.ceph.com/en/latest/rbd/rbd-kubernetes/>`_ Ceph官方文档提供了较为清晰的configmap生成方法
- `An Innovator’s Guide to Kubernetes Storage Using Ceph <https://www.velotio.com/engineering-blog/kubernetes-storage-using-ceph>`_
