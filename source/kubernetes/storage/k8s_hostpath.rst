.. _k8s_hostpath:

=================================
在Kubernetes中部署hostPath存储
=================================

:ref:`stable_diffusion_on_k8s` 和 :ref:`z-k8s_gpu_prometheus_grafana` 采用了 ``hostpath`` 这种简单粗暴的持久化存储，本文总结实践

参考
=====

- `Configure a Pod to Use a PersistentVolume for Storage <https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/>`_
