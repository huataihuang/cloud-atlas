.. _install_nvidia_gpu_operator_y-k8s:

==============================
y-k8s安装NVIDIA GPU Operator
==============================

.. note::

   之前实践过 :ref:`install_nvidia_gpu_operator` 是在 :ref:`priv_cloud_infra` 的 ``z-k8s`` 集群，当时还没有搞 :ref:`vgpu` ，所以是将完整的 :ref:`tesla_p10` 直接通过 :ref:`ovmf_gpu_nvme` 实现。

   为了能够更好迷你大规模 :ref:`gpu_k8s` ，我重新部署 :ref:`y-k8s` 来实现多 :ref:`vgpu` 的 :ref:`machine_learning` 

   本文为 :ref:`install_nvidia_gpu_operator` 再次实践

准备工作
============

在安装NVIDIA GPU Operator之前，去需要确保 Kubernetes 集群 ( :ref:`z-k8s` )满足以下条件:

- Kubernetes工作节点已经配置好容器引擎如 :ref:`docker` CE/EE, :ref:`cri-o` 或 :ref:`containerd` ( :ref:`install_nvidia_container_toolkit_for_containerd` )
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

.. literalinclude:: ../deploy/helm/helm_startup/linux_helm_install
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

这里我遇到启动问题(容器)

排查
~~~~~~

- 检查pod状态::

   kubectl get pods -o wide

可以看到没有就绪(NotReady)::

   NAME                              READY   STATUS      RESTARTS      AGE     IP           NODE        NOMINATED NODE   READINESS GATES
   cuda-vectoradd                    1/2     NotReady    0             9h      10.0.3.168   z-k8s-n-1   <none>           <none>

- 检查pods启动失败原因::

   kubectl describe pods cuda-vectoradd

输出显示:

.. literalinclude:: install_nvidia_gpu_operator/simple_cuda_sample_1_fail
   :language: bash
   :caption: 运行一个简单的CUDA示例失败原因排查(实际正常，见下文)
   :emphasize-lines: 17

.. note::

   汗，原来这是正常的，这个NVIDIA CUDA的案例就是运算完成后自动退出，所以服务状态就是不可访问的(这个是一次性运行)。其实只要查看pod日志就可以验证CUDA是否工作正常(见下文)

- 通过检查日志来了解计算结果::

   kubectl logs cuda-vectoradd

显示如下，表明NVIDIA GPU Operator安装正常::

   [Vector addition of 50000 elements]
   Copy input data from the host memory to the CUDA device
   CUDA kernel launch with 196 blocks of 256 threads
   Copy output data from the CUDA device to the host memory
   Test PASSED
   Done

.. _gpu_node_schedule_err_debug:

GPU节点调度异常排查
=====================

- 发现重启了一次 ``z-k8s-n-1`` 之后，出现部分 ``gpu-operator`` 容器没有正常运行:

.. literalinclude:: install_nvidia_gpu_operator/gpu-operator_pod_fail
   :language: bash
   :caption: 重启z-k8s-n-1之后 nvidia-device-plugin-validator pod没有启动
   :emphasize-lines: 15,16

- 通过 ``kubectl describe pods`` 命令检查没有启动原因:

.. literalinclude:: install_nvidia_gpu_operator/describe_pods_gpu-operator_pod_fail
   :language: bash
   :caption: 通过kubectl describe pods检查nvidia-operator-validator-rbmwr没有启动原因
   :emphasize-lines: 7,8

为何会出现 ``failed to get sandbox runtime: no runtime for "nvidia" is configured``

.. note::

   检查 ``z-k8s-n-1`` ，发现原来是 ``NVIDIA GPU Operator`` 安装会修改 ``/etc/containerd/config.toml`` ，把我上文通过 ``containerd-config.path`` 修订的配置给冲掉了。看起来NVIDIA官方文档中对containerd配置进行patch的方法现在应该不需要了，通过安装 ``nvidia-container-toolkit`` 就能够自动修正配置。

   这个猜测以后有机会再验证

``nvidia-device-plugin-validator`` 没有启动的原因是检查到设备为0导致无法运行:

.. literalinclude:: install_nvidia_gpu_operator/describe_pods_gpu-operator_pod_fail_1
   :language: bash
   :caption: 通过kubectl describe pods检查nvidia-device-plugin-validator没有启动是因为设备没有检测到
   :emphasize-lines: 6

为什么呢？

参考了 `pod的状态出现UnexpectedAdmissionError是什么鬼? <https://izsk.me/2022/01/27/Kubernetes-pod-status-is-UnexpectedAdmissionError/>`_ 有所启发:

- 因为是 :ref:`ovmf_gpu_nvme` 而不是 :ref:`vgpu` ，实际上虚拟机中只有一块GPU卡
- 对于passthrough的GPU卡，实际上只能分配个一个pod容器，一旦分配，第二个需要使用GPU的pods就无法调度到这个节点上
- ``NVIDIA GPU Operator`` 的一组pod中的 ``nvidia-device-plugin-validator`` 是一个特殊的pod，你会看到每次启动之后，这个pods都会进入 ``Completed`` 状态

  - ``nvidia-device-plugin-validator`` 只在节点启动时运行一次，功能就是检查验证工作节点是否有NVIDIA的GPU设备，一旦检查通过就会结束自己这个pod运行
  - 另外一个类似的验证功能的pods是 ``nvidia-cuda-validator`` 也是启动时运行一次检验

- 我之前为了验证 ``NVIDIA GPU Operator`` 运行了一个 ``简单的CUDA示例，两个向量相加`` ，这个pods运行完成后不会自动删除，一直保持在 ``NotReady`` 状态。问题就在这里，这个pod占用了GPU设备，导致后续的Pods，例如 :ref:`stable_diffusion_on_k8s` 无法调度
- 我重启了GPU工作节点，上述 ``简单的CUDA示例，两个向量相加`` pod没有删除，在启动时会抢占GPU设备，这也就导致了 ``nvidia-device-plugin-validator`` 无法拿到GPU设备进行检测，无法通过验证

**解决方法**

- 删除掉不使用的 ``简单的CUDA示例，两个向量相加`` pod，然后就会看到 ``nvidia-device-plugin-validator`` 正常运行完成，进入了 ``Completed`` 状态
- 这也就解决了 :ref:`stable_diffusion_on_k8s` 无法调度的问题


下一步
===========

有什么好玩的呢？

玩一下 :ref:`stable_diffusion_on_k8s` ，体验在GPU加速下的 ``文本倒置(Textual Inversion)`` 图像生成

参考
==========

- `NVIDIA Cloud Native: Install NVIDIA GPU Operator <https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/getting-started.html#install-nvidia-gpu-operator>`_
