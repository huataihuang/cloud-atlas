.. _intergrate_gpu_telemetry_into_k8s:

=====================================
在Kuternetes集成GPU可观测能力
=====================================

GPU现在已经成为Kubernetes环境重要资源，我们需要能够通过类似 :ref:`prometheus` 这样的统一监控来访问GPU指标以监控GPU资源，就像传统的CPU资源监控一样。

.. note::

   如果在Kubernetes集群已经部署了 :ref:`nvidia_gpu_operator` ，那么会自动在GPU节点上安装好 :ref:`dcgm-exporter` 。所以，采用 :ref:`nvidia_gpu_operator` 是 `NVIDIA/dcgm-exporter GitHub官方 <https://github.com/NVIDIA/dcgm-exporter>`_ 推荐的部署方式( Note: Consider using the `NVIDIA GPU Operator <https://github.com/NVIDIA/gpu-operator>`_  rather than DCGM-Exporter directly. )。

   实际上，我尝试了 `NVIDIA/dcgm-exporter GitHub官方 <https://github.com/NVIDIA/dcgm-exporter>`_ 提供的通过Helm chart安装 ``DCGM-Exporter`` ，没有成功::

      helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
      helm repo update
      helm install --generate-name gpu-helm-charts/dcgm-exporter

   提示报错::

      Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: resource mapping not found for name: "dcgm-exporter-1679911060" namespace: "default" from "": no matches for kind "ServiceMonitor" in version "monitoring.coreos.com/v1"
      ensure CRDs are installed first

   不过，如果 :ref:`install_nvidia_gpu_operator` 就直接解决了这个问题，会自动完成GPU节点的 ``dcgm-exporter`` 安装。

对于一些生产环境，可能不会部署完整的 :ref:`nvidia_gpu_operator` (而采用自己的解决方案)，这种情况依然可以独立部署 :ref:`dcgm-exporter` ，本文即参考官方文档实现这种部署模式。此时在GPU节点上本机安装，也就是既不使用 :ref:`nvidia_gpu_operator` 也不容器化驱动程序( :ref:`nvidia-docker` )

NVIDIA驱动
=============



参考
=====

- `Integrating GPU Telemetry into Kubernetes <https://docs.nvidia.com/datacenter/cloud-native/gpu-telemetry/dcgm-exporter.html#integrating-gpu-telemetry-into-kubernetes>`_
