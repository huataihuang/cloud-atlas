.. _install_nvidia_device_plugin:

=========================================
安装NVIDIA Device Plugin(无需执行,存档)
=========================================

.. note::

   这里我搞错了，不需要单独安装 NVIDIA Device Plugin 。如果直接安装 ``NVIDIA GPU Operator`` 会自动安装 plugins

   本文仅存档

要在Kubernetes中使用GPU，需要安装 ``NVIDIA Device Plugins`` 。这个NVIDIA Device Plugin是一个daemonset，可以自动列出集群每个节点的GPU数量并允许在GPU上运行pod。

- 使用 :ref:`helm` 来部署 ``NVIDIA Device Plugins`` ，所以需要首先部署 helm (之前我在部署 :ref:`cilium` 时完成 :ref:`cilium_install_with_external_etcd` 已在集群安装过helm ):

.. literalinclude:: ../deploy/helm/linux_helm_install
   :language: bash
   :caption: 在Linux平台安装helm

- 添加 ``nvidia-device-plugin`` ``helm`` 仓库:

.. literalinclude:: install_nvidia_gpu_operator/helm_add_nvdp_repo
   :language: bash
   :caption: 添加nvidia-device-plugin helm仓库

- 部署 ``NVIDIA Device Plugins`` :

.. literalinclude:: install_nvidia_gpu_operator/helm_install_nvidia-device-plugin
   :language: bash
   :caption: 使用helm安装nvidia-device-plugin

安装后检查:

.. literalinclude:: install_nvidia_gpu_operator/kubectl_get_pods_nvidia-device-plugin
   :language: bash
   :caption: 检查nvidia-device-plugin安装

排查NVIDIA Device Plugin启动失败
----------------------------------

在安装完 ``NVIDIA Device Plugins`` 我发现容器启动失败:

.. literalinclude:: install_nvidia_gpu_operator/kubectl_get_pods_nvidia-device-plugin_fail
   :language: bash
   :caption: 检查nvidia-device-plugin容器，启动失败

参考 `CrashLoopBackOff when running nvidia-device-plugin-daemonset <https://github.com/NVIDIA/k8s-device-plugin/issues/105>`_ 可以采用以下方法来搜集信息:

.. literalinclude:: install_nvidia_gpu_operator/nvidia-container-cli_info
   :language: bash
   :caption: 使用 nvidia-container-cli 从控制台搜集NVDIA容器运行失败原因

可以看到有很多运行依赖缺失:

.. literalinclude:: install_nvidia_gpu_operator/nvidia-container-cli_info_fail_output
   :language: bash
   :caption: 使用 nvidia-container-cli 从控制台搜集NVDIA容器运行失败信息，显示有很多依赖缺失

删除NVIDIA Device Plugin
=========================

- 使用 :ref:`helm` 检查release:

.. literalinclude:: ../deploy/helm/helm_list
   :language: bash
   :caption: 检查通过helm已经安装的软件release(删除时候必须指定release)

- 删除错误部署的NVIDIA Device Plugin:

.. literalinclude:: ../deploy/helm/helm_uninstall
   :language: bash
   :caption: 使用helm uninstall删除指定release，注意必须指定namespace(如果不是默认namespace)

参考
==========

- `NVIDIA / k8s-device-plugin <https://github.com/NVIDIA/k8s-device-plugin>`_
  `
