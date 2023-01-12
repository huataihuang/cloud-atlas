.. _install_kubeflow:

===================
安装Kubeflow
===================

Kubeflow作为Kubernetes的端到端机器学习 (ML) 平台，它为 ML 生命周期的每个阶段提供组件，从探索到训练和部署，都有相应的软件堆栈。用户可以根据自己的需求参考 :ref:`kubeflow_components` 来部署不同组件。

Kubeflow安装方式
===================

有两种安装和运行Kubeflow的方式:

- 使用打包的kubeflow发行版，可以针对不同平台(如云计算厂商)
- 使用 `MNIST on Kubeflow on Vanilla k8s <https://github.com/kubeflow/examples/tree/master/mnist#vanilla>`_ 在 :ref:`vanilla_k8s` 上部署 `Kubeflow Manifests <https://github.com/kubeflow/manifests>`_ 

  - 对于个人部署的 :ref:`priv_cloud_infra` 采用 `Kubeflow Manifests Installation <https://github.com/kubeflow/manifests#installation>`_

参考
=======

- `Installing Kubeflow <https://www.kubeflow.org/docs/started/installing-kubeflow/>`_
