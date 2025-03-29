.. _y-k8s_nvidia_gpu_operator:

=============================================================
y-k8s集群通过 :ref:`nvidia_gpu_operator` 部署 :ref:`gpu_k8s`
=============================================================

.. note::

   通过 :ref:`install_nvidia_gpu_operator_y-k8s` 实现 :ref:`gpu_k8s` ，为后续 :ref:`machine_learning` 做准备

说明
=======

- :ref:`install_nvidia_gpu_operator` 是最简便的部署 :ref:`nvidia_container_runtimes` 实现 :ref:`gpu_k8s` 的方案( 不需要手工完成 :ref:`install_nvidia_container_toolkit_for_containerd` )，只需要简单的 :ref:`helm` 部署迅速完成所有有关NVIDIA GPU Kubernetes部署
- 为模拟多实例GPU Kubernetes，我采用了 :ref:`vgpu` 技术:

  - :ref:`install_vgpu_license_server`
  - :ref:`install_vgpu_manager`
  - :ref:`install_vgpu_guest_driver`
  - :ref:`vgpu_unlock`

快速部署
=========

- 安装 :ref:`helm` :

.. literalinclude:: ../../kubernetes/deploy/helm/helm_startup/linux_helm_install
   :language: bash
   :caption: 在Linux平台安装helm

- 添加NVIDIA Helm仓库:

.. literalinclude:: ../../kubernetes/gpu/install_nvidia_gpu_operator/helm_add_nvidia_repo
   :language: bash
   :caption: 添加NVIDIA仓库

- 在Ubuntu的Bare-metal/Passthrough上使用默认配置:

.. literalinclude:: ../../kubernetes/gpu/install_nvidia_gpu_operator/helm_install_gnu-operator_baremetal_passthrough
   :language: bash
   :caption: Ubuntu上Barmetal/Passthrough默认配置，helm 安装GNU Operator 

SO EASY

一切顺利的话，就部署完成了采用 :ref:`vgpu` 技术模拟的 :ref:`gpu_k8s` ，可以完成大规模 :ref:`machine_learning` 模拟。如果有问题，可以参考我的实践笔记：:ref:`install_nvidia_gpu_operator`

.. note::

   为了方便观察部署的 :ref:`vgpu` 支持的 ``y-k8s`` 集群，也方便后续部署 :ref:`machine_learning` 能够掌控运行状态，接下来先 :ref:`y-k8s_kube-prometheus-stack`
