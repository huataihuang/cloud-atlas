.. _install_kubeflow:

===================
安装Kubeflow
===================

Kubeflow作为Kubernetes的端到端机器学习 (ML) 平台，它为 ML 生命周期的每个阶段提供组件，从探索到训练和部署，都有相应的软件堆栈。用户可以根据自己的需求参考 :ref:`kubeflow_components` 来部署不同组件。

Kubeflow安装方式
===================

有两种安装和运行Kubeflow的方式:

- 使用打包的 ``kubeflow发行版`` ，可以针对不同平台(如云计算厂商)
- 使用 `MNIST on Kubeflow on Vanilla k8s <https://github.com/kubeflow/examples/tree/master/mnist#vanilla>`_ 在 :ref:`vanilla_k8s` 上部署 `Kubeflow Manifests <https://github.com/kubeflow/manifests>`_ 

  - 对于个人部署的 :ref:`priv_cloud_infra` 采用 `Kubeflow Manifests Installation <https://github.com/kubeflow/manifests#installation>`_

发行版kubeflow
----------------

- Canonical(也就是 :ref:`ubuntu_linux` 发行商)开发了 :ref:`charmed_kubeflow` ，可以在所有合适的Kubernetes上部署。目前我部署的 :ref:`z-k8s` 也是在 :ref:`ubuntu_linux` 上，所以这是目前我首先尝试的实践线路
- :ref:`openshift` 是 :ref:`redhat_linux` 发行商红帽的产品，也是可以自建Kubeflow的方式，我计划在下一阶段实践

Kubeflow Manifests
----------------------

``Kubeflow Manifests`` 是在纯粹的Kubernetes机群上通过 :ref:`kustomize` 和 :ref:`kubectl` 完成Kubeflow部署，是一种更为底层和复杂的部署技术。

我的实践计划是想在 :ref:`kubespray` 部署的 :ref:`y-k8s` 集群上迭代部署 ``Kubeflow Manifests`` :

- GPU节点采用 :ref:`vgpu` 将单块 :ref:`tesla_p10` 拆分成2块，模拟集群的2个 :ref:`gpu_k8s` 节点
- 首先尝试 :ref:`install_kubeflow_single_command`

参考
=======

- `Installing Kubeflow <https://www.kubeflow.org/docs/started/installing-kubeflow/>`_
