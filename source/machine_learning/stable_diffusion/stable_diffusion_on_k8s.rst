.. _stable_diffusion_on_k8s:

===================================
在Kubernetes部署Stable Diffusion
===================================

在 :ref:`kubernetes` 上部署 :ref:`stable_diffusion_infra` (包括 `Stable Diffusion web UI <https://github.com/Sygil-Dev/sygil-webui>`_ 和 自动模型获取)，可以快速完成一个基于 :ref:`nvidia_gpu` (我使用 :ref:`tesla_p10` )的 :ref:`machine_learning` 案例。此外，我的部署在 :ref:`priv_cloud_infra` 构建的 :ref:`ovmf_gpu_nvme` 虚拟化，也验证了云计算方案。

功能
=======

- 自动模型获取
- 结合 :ref:`nvidia_gpu_operator` ，采用 :ref:`cuda` 库，具有多功能交互UI
- GFPGAN 用于人脸重建，RealESRGAN 用于超采样
- 文本倒置(Textual Inversion)

准备工作
==========

- 首先部署一个至少有一个节点具备GPU的Kubernetes集群:

  - 部署 :ref:`z-k8s` 
  - 配置 :ref:`ovmf_gpu_nvme`
  - :ref:`install_nvidia_linux_driver_in_ovmf_vm`

- 在上述Kubernetes集群 :ref:`z-k8s` :ref:`install_nvidia_gpu_operator`

- 本地安装好 :ref:`helm`

安装
========

- 添加helm仓库 ``stable-diffusion-k8s`` :

.. literalinclude:: stable_diffusion_on_k8s/helm_add_stable-diffusion-k8s_repo
   :language: bash
   :caption: 添加stable-diffusion-k8s helm仓库

- (可选)创建一个 ``values.yaml`` 配置定制设置:

  - 可能需要设置的参数有 ``nodeAffinity`` , ``cliArgs`` (见下文) 以及 ``ingress`` （这样就不需要使用 ``kubectl port-forward`` ，我采用 :ref:`cilium_k8s_ingress_http` )

.. literalinclude:: stable_diffusion_on_k8s/values.yaml
   :language: yaml
   :caption: 定制values.yaml
   :emphasize-lines: 24,65,66

values.yaml
-------------

- 在 ``values.yaml`` 中，修订 ``cliArgs`` 可以向WebUI传递参数。默认使用参数是 ``--extra-models-cpu --optimized-turbo`` ，此时会使用 6GB GPU
- 如果要激活 文本倒置(Textual Inversion) ，则去除 ``--optimize`` 和 ``--optimize-turbo`` 参数，然后添加 ``--no-half`` 到 ``cliFlags`` （见上文我配置 ``values.yaml`` )
- 如果输出总是一个绿色图像，则使用参数 ``--precision full --no-half``

开始安装
----------

.. literalinclude:: stable_diffusion_on_k8s/helm_install_stable-diffusion-k8s
   :language: bash
   :caption: 安装stable-diffusion-k8s

提示信息:

.. literalinclude:: stable_diffusion_on_k8s/helm_install_stable-diffusion-k8s_output
   :language: bash
   :caption: 安装stable-diffusion-k8s的输出信息

问题排查
=============

调度到GPU节点
---------------

- 发现pod调度没有成功，始终pending:

- 检查 pods::

   kubectl describe pods stable-diffusion-1673539037-0

可以看到调度失败信息:

.. literalinclude:: stable_diffusion_on_k8s/stable-diffusion_pod_pending
   :language: bash
   :caption: stable-diffusion pod 调度失败信息
   :emphasize-lines: 9

显示调度失败是因为没有 ``PersistentVolumeClaims`` 持久化卷申明，也就是说集群需要先部署一个卷

这里 ``Node-Selectors:              nvidia.com/gpu.present=true`` ，可以通过 ``kubectl get nodes --show-labels`` 看到，安装了NVIDIA GPU的 ``z-k8s-n-1`` 是具备该标签的

这个报错 :ref:`fix_pod_has_unbound_immediate_persistentvolumeclaims` 经过排查是卷容量不足，原因是我部署节点都只分配了 ``9.5G`` 磁盘作为 :ref:`containerd` 存储目录，实际上多次安装以后磁盘空间只剩下 1.x GB，而这个 ``stable-diffusion`` 自身镜像就需要下载8G，同时卷申明也需要空间

检查::

   $ kubectl get pvc
   NAME                                                                    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   AGE
   stable-diffusion-1673539037-model-store-stable-diffusion-1673539037-0   Pending                                                     16m



参考
======

- `Stable Diffusion on Kubernetes with Helm <https://github.com/amithkk/stable-diffusion-k8s>`_
