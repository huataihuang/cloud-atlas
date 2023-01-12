.. _install_nvidia_gpu_operator:

===========================
安装NVIDIA GPU Operator
===========================

准备工作
============

在安装NVIDIA GPU Operator之前，去需要确保 Kubernetes 集群 ( :ref:`z-k8s` )满足以下条件:

- Kubernetes工作节点已经配置好容器引擎如 :ref:`docker` CE/EE, :ref:`cri-o` 或 ;ref:`containerd` ( :ref:`install_nvidia_container_toolkit_for_containerd` )
- 每个节点都需要部署Node Feature Discovery (NFD) : 默认情况下 NVIDIA GPU Operator会自动部署NFD master 和 worker
- 在Kubernetes 1.13 和 1.14，需要激活 ``kubelet`` 的 ``KubeletPodResources`` 功能，从 Kubernetes 1.15以后是默认激活的

此外还需要确认:

- 每个hypervisor主机 :ref:`vgpu` 加速Kubernetes worker节点虚拟机必须先完成安装 NVIDIA vGPU Host Driver version 12.0 (or later)
- 需要安装NVIDIA vGPU License Server服务于所有Kubernetes虚拟机节点
- 部署好私有仓库以便能够上传NVIDIA vGPU specific driver container image
- 每个Kubernetes worker节点能够访问私有仓库
- 需要使用 Git 和 Docker/Podman 来构建vGPU 驱动镜像(从源代码仓库)并推送到私有仓库

安装NVIDIA GPU Operator
===========================

- 安装 :ref:`helm` :

.. literalinclude:: ../deploy/helm/linux_helm_install
   :language: bash
   :caption: 在Linux平台安装helm

- 添加NVIDIA Helm仓库:

.. literalinclude:: install_nvidia_gpu_operator/helm_add_nvidia_repo
   :language: bash
   :caption: 添加NVIDIA仓库

Operands(操作数)
-------------------

默认情况下，GPU Operator operands会部署到集群中所有GPU工作节点。GPU工作节点的标签由 ``feature.node.kubernetes.io/pci-10de.present=true`` 标记，这里的 ``0x10de`` 是PCI vender ID，是分配给 NVIDIA 的供应商ID

- 首先给集群中安装了NVIDIA GPU的节点打上标签:

.. literalinclude:: install_nvidia_gpu_operator/label_nvidia_gpu_node
   :language: bash
   :caption: 为Kubernetes集群的NVIDIA GPU工作节点打上标签

-  要禁止在一个GPU工作节点部署operands，则对该节点标签 ``nvidia.com/gpu.deploy.operands=false`` :

.. literalinclude:: install_nvidia_gpu_operator/label_gpu_deploy_operands_false
   :language: bash
   :caption: 为Kubernetes集群GPU工作节点打上标签禁止部署operands

部署GNU Operator
--------------------

有多重安装场景，以下是常见场景，请选择合适的方法

- 在Ubuntu的Bare-metal/Passthrough上使用默认配置(很好，正是我需要的场景，因为我只有一个绩点有 passthrough 的 :ref:`tesla_p10` )

.. literalinclude:: install_nvidia_gpu_operator/helm_install_gnu-operator_baremetal_passthrough
   :language: bash
   :caption: Ubuntu上Barmetal/Passthrough默认配置，helm 安装GNU Operator

- 完成后见检查:

.. literalinclude:: install_nvidia_gpu_operator/get_gnu-operator_pods
   :language: bash
   :caption: 安装完GNU Operator之后，检查集群中nvidia gnu-operators相关pods

可以看到运行了如下pods:

.. literalinclude:: install_nvidia_gpu_operator/get_gnu-operator_pods_output
   :language: bash
   :caption: 安装完GNU Operator之后，检查集群中nvidia gnu-operators相关pods

运行案例GPU应用
=================

CUDA VectorAdd
-----------------

- 首先可以运行NVIDIA提供了一个简单的CUDA示例，将两个向量相加:

.. literalinclude:: install_nvidia_gpu_operator/simple_cuda_sample_1
   :language: bash
   :caption: 运行一个简单的CUDA示例，两个向量相加

提示信息::

   pod/cuda-vectoradd created

- 通过检查日志来了解计算结果

下一步
===========

有什么好玩的呢？

玩一下 :ref:`stable_diffusion_on_k8s` ，体验在GPU加速下的 ``文本倒置(Textual Inversion)`` 图像生成

参考
==========

- `NVIDIA Cloud Native: Install NVIDIA GPU Operator <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#install-nvidia-gpu-operator>`_
