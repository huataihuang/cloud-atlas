.. _k8s_csi_arch:

=======================
Kubernetes CSI架构
=======================

CSI概念
=========

- CSI是容器存储接口(Container Storage Interface)，以建立一个行业标准接口规范，以便将任意存储系统暴露给容器 :ref:`k8s_workloads` 。
- ``csi`` 卷类型是一种 ``out-tree`` (in-tree是指跟其它存储插件在同一个代码路径下，随 Kubernetes 的代码同时编译，out-tree则刚好相反) 的CSI卷插件，用于Pod与同一个节点上运行的外部CSI卷驱动程序交互。部署了CSI兼容卷驱动后，用户就开业使用 ``csi`` 作为卷类型来关在驱动提供的存储。
- CSI持久化卷支持在Kubernetes v1.9引入，必须由集群管理员明确启用。也就是需要在 ``apiserver`` / ``controller-manager`` 和 ``kubelet`` 组件的 ``--feature-gates =`` 标志中加上 ``CSIPersistentVolume = true``
- CSI持久化卷具备以下字段可以让用户指定:

  - ``driver`` : 指定卷驱动程序名称
  - ``volumeHandle`` : 唯一标识从CSI卷插件的 ``CreateVolume`` 调用返回的卷名
  - ``readOnly`` : 指示卷是否发布为只读

CSI插件机制
=============

CSI插件包括:

- ``Controller Plugin`` : 以 ``Deployment`` 或 ``StatefulSet`` 形式部署，实现CSI Controller service。Controller负责与Kubernetes API, 外部存储服务的控制面交互，但并不实际处理存储卷在宿主机上的挂载等工作
- ``Node Plugin`` : Node插件需要在所有node节点上运行，所以通常以 ``Daemonset`` 形式部署。Node插件实现CSI Node service，会暴露出一个 ``uds`` 文件出来，从而让 ``kubelet`` 在进行存储卷操作时，通过这个 ``uds`` 文件调用它的 ``gRPC`` 接口

CSI插件需要实现 **3个** ``gRPC`` 接口服务:

- ``Identity Service`` : Node插件和Controller插件都需要实现Identity Service RPC
- ``Controller Service`` : 控制插件实现
- ``Node Service`` : Node插件实现

CSI插件部署通常采用官方提供的一系列sidecar来完成:

- ``external-provisioner``
- ``external-attacher``
- ``external-snapshotter``
- ``external-resizer``
- ``node-driver-registrar``
- ``livenessprobe``

.. note::

   我先实践 :ref:`ceph-csi` ，然后再回来补充理论知识

参考
=======

- `Kubernetes CSI Specification <https://cctoctofx.netlify.app/post/cloud-computing/k8s-csi-interprete/>`_ 这篇文章较为全面清晰，提供了不少索引信息，可以作为学习起点
- `Kubernetes Container Storage Interface (CSI) Documentation <https://kubernetes-csi.github.io/docs/introduction.html>`_ 详细全面的开发、部署、测试文档，作为主要参考资料
- `CSI Volume Plugins in Kubernetes Design Doc <https://github.com/kubernetes/design-proposals-archive/blob/main/storage/container-storage-interface.md>`_ CSI插件设计文档，非常详细，值得深入学习
