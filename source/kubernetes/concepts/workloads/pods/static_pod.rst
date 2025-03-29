.. _static_pod:

==================
静态Pods
==================

static pods是在特定节点由kubelet直接管理的pod，无需API server管理这些pod。和常规的由控制平面(control plane)管理的pod不同，例如 :ref:`deployment` 就是由control palne维护的，对于static pod，则完全由本地 ``kubelet`` 监视并在故障时自动重启。

当使用 ``kubeadm`` 部署管控节点，管控节点的三大组件 ``apiserver`` , ``control-manager`` 和 ``scheduler`` 就是 static pods。这些static pods的配置 YAML 位于管控服务器本地 ``/etc/kubernetes/manifests`` 目录下，任何修订都会触发 ``kubelet`` 自动重建该pod并刷新配置。

这就非常类似 :ref:`systemd` 管理本地服务。

参考
======

- `Create static Pods <https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/>`_
