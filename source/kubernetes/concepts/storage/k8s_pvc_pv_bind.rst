.. _k8s_pvc_pv_bind:

============================
Kubernetes  PV 和 PVC 绑定
============================

需要澄清一些概念:

- 在Kubernetes中，PV和PVC是一一对应关系，所以不能将多个PVC绑定到一个PV上
- 对于同一个目录挂载，例如 :ref:`k8s_nfs` 或者 :ref:`k8s_hostpath` ，也是需要为每个 :ref:`k8s_workloads` 配置PV和PVC对: 

  - 如果一个NFS共享必须被多个服务器/应用程序使用，则需要创建多个PV指向一个NFS共享。
  - 实践案例 :ref:`kube-prometheus-stack_persistent_volume`

- 一个 PV 绑定到一个 PVC 后，该 PV 不能再绑定到其他 PVC
- PV是物理主机概念，没有 ``namespace`` ；PVC是pod概念，所以有 ``namespace`` : 当PVC绑定了PV，也就限定饿了PV为某个单一namespace服务的效果

参考
======

- `Can Multiple PVCs Bind to One PV in OpenShift? <https://access.redhat.com/solutions/3064941>`_
