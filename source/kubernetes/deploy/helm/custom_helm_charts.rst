.. _custom_helm_charts:

=========================
定制Helm charts
=========================

在 :ref:`helm3_prometheus_grafana` 采用的是互联网上社区提供的helm仓库以及镜像，对于很多企业用户，内部网路无法直接下载镜像(安全原因)，所以我们需要自己定制Helm charts来实现企业级的"一键部署"。

.. note::

   :ref:`private_helm_repo` 可以进一步在内部局域网提供完整安装步骤，加速部署。

Helm create
================

Helm pull
===============

对于自己定义和部署 :ref:`helm3_prometheus_grafana` ，则采用先 ``pull`` 然后定制的方法:

- 添加 ``prometheus-community`` 仓库并下载 ``kube-prometheus-stack`` chart:

.. literalinclude:: custom_helm_charts/helm_pull_kube-prometheus-stack
   :language: bash
   :caption: 添加 ``prometheus-community`` 仓库并下载 ``kube-prometheus-stack`` chart

此时本地目录下载了一个 ``kube-prometheus-stack-46.6.0.tgz`` 文件，就是我们所需的chart打包文件，将这个文件解压缩后我们来做定制

- 我们来检查一下解压缩以后的 ``kube-prometheus-stack`` 目录内容( ``tree kube-prometheus-stack`` ):

.. literalinclude:: custom_helm_charts/tree_helm_kube-prometheus-stack
   :language: bash
   :caption: 检查 ``kube-prometheus-stack`` chart包含的文件结构

.. _helm_customize_kube-prometheus-stack:

helm定制 ``kube-prometheus-stack``
====================================

参考
======

- `How to create custom Helm charts <https://hackandslash.blog/how-to-create-custom-helm-charts/>`_ 使用了OpenProject项目部署作为案例
- `Create a Custom Helm Template <https://shashwotrisal.medium.com/create-a-custom-helm-template-63d1c5283a1a>`_
- `How to conditionally choose an image in Helm <https://gist.github.com/anderson-custodio/535a6cc01182e25e69f9302d0b701175>`_
- `How to Create a Helm Chart [Comprehensive Beginners Guide] <https://devopscube.com/create-helm-chart/>`_
- `How to create a Helm chart for your application deployment in Kubernetes <https://www.adfolks.com/blogs/how-to-create-a-helm-chart-for-your-application-deployment-in-kubernetes-native>`_
