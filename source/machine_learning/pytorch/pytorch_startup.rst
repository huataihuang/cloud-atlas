.. _pytorch_startup:

====================
PyTorch快速起步
====================

准备工作
=========

`PyTorch Start Locally <https://pytorch.org/get-started/locally/>`_ 提供了一个快速部署安装，通过简单的排列选择就能够获得安装命令(请参考官网)。例如，我在虚拟机 ``z-k8s-n-1`` 中通过 :ref:`iommu` ( :ref:`ovmf_gpu_nvme` )实现虚拟机内部访问 :ref:`nvidia_gpu` 

对于运行 :ref:`gpu_k8s_arch` ，例如我的虚拟机 ``z-k8s-n-1`` 是Kubernetes集群中的一个worker节点，则只需要为 :ref:`container_runtimes` 安装对应的NVIDIA Container Toolkit( :ref:`install_nvidia_container_toolkit_for_containerd` 或 :ref:`install_nvidia_container_toolkit_for_docker` )，这样结合 :ref:`nvidia_gpu_operator` ( :ref:`install_nvidia_gpu_operator` )就能自动在 :ref:`gpu_k8s_arch` 调度运行支持 :ref:`cuda` 的容器 ``pods`` 。

.. note::

   这里我的虚拟机 ``z-k8s-n-1`` 已经 :ref:`install_nvidia_container_toolkit_for_containerd` ，所以实际虚拟机已经完成了 :ref:`install_cuda_prepare` ，并且配置了 :ref:`cuda_repo` 。这样仅需执行一步CUDA安装，如果你没有如我这样的准备工作，则可能需要补充完成这两个步骤。

不过，对于直接在虚拟机内部进行直接开发(训练/推理)，则需要 :ref:`install_nvidia_cuda` :

.. literalinclude:: ../../machine_learning/cuda/install_nvidia_cuda/cuda_toolkit_ubuntu_repo_install
   :language: bash
   :caption: Ubuntu 使用NVIDIA官方软件仓库安装CUDA

.. warning::

   这里我实践发现，已经 :ref:`install_nvidia_container_toolkit_for_containerd` 的虚拟机无法 :ref:`install_nvidia_cuda` ，会提示冲突::

      The following packages have unmet dependencies:
       libnvidia-extra-525 : Conflicts: libnvidia-extra
       libnvidia-extra-530 : Conflicts: libnvidia-extra
      E: Error, pkgProblemResolver::Resolve generated breaks, this may be caused by held packages. 

   所以我暂停这个实践测试，改为先构建 :ref:`vgpu` ，将物理 :ref:`tesla_p10` 拆分成 4 块 vgpu (每个6G显存)，然后分别 :ref:`ovmf_gpu_nvme` 直通到2个虚拟机中进行模拟测试(其中2个vgpu准备通过切换方式用于 :ref:`container_runtimes` 和 :ref:`kvm` 虚拟机)，这样就能实现不同的场景。

START LOCALLY
=================

待续...

参考
======

- `PyTorch Start Locally <https://pytorch.org/get-started/locally/>`_
