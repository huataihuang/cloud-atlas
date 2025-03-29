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

reddit 上有人讨论过这个问题 `Prometheus Stack deployment using private image registry <https://www.reddit.com/r/devops/comments/zozac8/prometheus_stack_deployment_using_private_image/>`_ 基本思路和我相同，就是找出image的配置替换为自己局域网私有registry。主要建议就是修订 ``values.yaml``

- 在 ``values.yaml`` 中有一个 ``Global image registry`` 配置项:

.. literalinclude:: custom_helm_charts/values.yaml
   :language: yaml
   :caption: ``values.yaml`` 中定义全局镜像仓库
   :emphasize-lines: 22,27

- 此外，纵观整个 ``values.yaml`` ，其中使用的不同仓库镜像，举例 :ref:`alertmanager` :

.. literalinclude:: custom_helm_charts/values_alertmanager_image.yaml
   :language: yaml
   :caption: ``values.yaml`` 中定义alertmanager镜像(案例)
   :emphasize-lines: 4-6

.. note::

   在 ``kube-prometheus-stack`` 各级子目录中也分布一些 ``values.yaml`` ::

      ./values.yaml                                    # 主要服务镜像
      ./charts/grafana/values.yaml                     # k8s-sidecar镜像
      ./charts/kube-state-metrics/values.yaml          # kube-state-metrics镜像
      ./charts/prometheus-node-exporter/values.yaml    # node-exporter镜像

   仔细观察了一下，镜像实际上也不少

- 执行以下 :ref:`grep` 可以看到 ``values.yaml`` 配置中，镜像没有配置 ``SHA`` 镜像校验:

.. literalinclude:: custom_helm_charts/grep_image_values
   :language: bash
   :caption: 执行 grep 命令从 ``values.yaml`` 获取所有使用的镜像配置

输出:

.. literalinclude:: custom_helm_charts/grep_image_values_output
   :language: bash
   :caption: 执行 grep 命令从 ``values.yaml`` 获取所有使用的镜像配置的输出内容

可以看到 ``kube-prometheus-stack`` 使用了 **2个** registry:

  - quay.io
  - registry.k8s.io

将上述两个镜像regristry替换成自己私有的registry:

.. literalinclude:: custom_helm_charts/replace_values_registry
   :language: bash
   :caption: 执行 sed 命令从 ``values.yaml`` 替换registry到自己私有仓库

- 在一个已经部署过 ``kube-prometheus-stack`` 的集群，扫描出所有已经部署的镜像 :ref:`change_k8s_image_registry`


参考
======

- `How to create custom Helm charts <https://hackandslash.blog/how-to-create-custom-helm-charts/>`_ 使用了OpenProject项目部署作为案例
- `Create a Custom Helm Template <https://shashwotrisal.medium.com/create-a-custom-helm-template-63d1c5283a1a>`_
- `How to conditionally choose an image in Helm <https://gist.github.com/anderson-custodio/535a6cc01182e25e69f9302d0b701175>`_
- `How to Create a Helm Chart [Comprehensive Beginners Guide] <https://devopscube.com/create-helm-chart/>`_
- `How to create a Helm chart for your application deployment in Kubernetes <https://www.adfolks.com/blogs/how-to-create-a-helm-chart-for-your-application-deployment-in-kubernetes-native>`_
