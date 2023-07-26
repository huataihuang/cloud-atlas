.. _z-k8s_prometheus-stack:

===========================================
Kubernetes集群(z-k8s)部署Prometheus-stack
===========================================

.. note::

   我最初是通过 :ref:`zcloud_host_install_prometheus` 来部署监控，不过standalone方式运行监控部署步骤比较繁琐。现在社区提供了非常完善的通过 :ref:`helm` 在 :ref:`kubernetes` 集群部署 :ref:`prometheus` + :ref:`grafana` 的方案，所以我改变了部署方式。

由于我的 :ref:`z-k8s` 有一个虚拟化节点 ``z-k8s-n-1`` 通过 :ref:`ovmf_gpu_nvme` ，在 :ref:`z-k8s_nvidia_gpu_operator` 后，就可以 :ref:`helm3_prometheus_grafana` 。详细步骤记录在 :ref:`z-k8s_gpu_prometheus_grafana`

