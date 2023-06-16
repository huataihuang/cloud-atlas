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

   所以我暂停这个实践测试，改为先构建 :ref:`vgpu` ，将物理 :ref:`tesla_p10` 拆分成 2 块 vgpu (每个12G显存)，然后分别 :ref:`ovmf_gpu_nvme` 直通到2个虚拟机中进行模拟测试(其中2个vgpu准备通过切换方式用于 :ref:`container_runtimes` 和 :ref:`kvm` 虚拟机)，这样就能实现不同的场景。

再次准备工作
==============

在完成 :ref:`vgpu_quickstart` 之后，我现在有2个虚拟机分别各配置一块 vGPU。需要注意，PyTorch运行环境非常占用磁盘空间，需要将默认虚拟机磁盘 :ref:`ceph_extend_rbd_drive_with_libvirt_xfs` 将 ``vda`` 扩展到 ``32GB``

.. literalinclude:: pytorch_startup/rbd_resize
   :caption: 将虚拟机磁盘扩展(xfs和btrfs)

START LOCALLY
=================

.. note::

   测试环境采用 :ref:`vgpu_quickstart` 构建的虚拟机内部 vGPU

- 安装 python3 / pip3 ( 采用 :ref:`virtualenv` ):

.. literalinclude:: ../../python/startup/virtualenv/apt_install_pip3_venv
   :language: bash
   :caption: 在 :ref:`ubuntu_linux` 22.04 LTS 安装 ``pip3`` 以及 ``venv``

- 创建virtualenv:

.. literalinclude:: ../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

- 激活:

.. literalinclude:: ../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

- 安装:

.. literalinclude:: pytorch_startup/pip3_install_pytorch
   :caption: 使用 ``pip3`` 安装 pytorch

- 验证:

.. literalinclude:: pytorch_startup/verify_pytorch.py
   :language: python
   :caption: 验证torch工作

输出类似:

.. literalinclude:: pytorch_startup/verify_pytorch_output
   :language: python
   :caption: 验证torch工作代码运行输出

验证Pytorch的FP16
=====================



参考
======

- `PyTorch Start Locally <https://pytorch.org/get-started/locally/>`_
- `FP16 in Pytorch <https://medium.com/@dwightfoster03/fp16-in-pytorch-a042e9967f7e>`_
