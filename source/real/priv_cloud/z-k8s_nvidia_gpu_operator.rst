.. _z-k8s_nvidia_gpu_operator:

===============================================
Kubernetes集群(z-k8s)部署NVIDIA GPU Operator
===============================================

:ref:`ovmf_gpu_nvme` 在虚拟机 ``z-k8s-n-1`` 节点Passthrough :ref:`tesla_p10` ，这样就在 :ref:`z-k8s` 构建了一个具备 :ref:`nvidia_gpu` 的工作节点。在Kubernetes集群，通过 :ref:`install_nvidia_gpu_operator` 可以为 :ref:`gpu_k8s` 集群添加自动管理 :ref:`nvidia_gpu` 的能力。


