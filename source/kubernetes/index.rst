.. _kubernetes:

=================================
Kubernetes
=================================

Kubernetes是Google基于其内部容器管理技术研发的开源实现，简单而言，就是容器的编排管理平台(Orchestrate)。正如Docker技术使得容器易于分发和运行，Kubernetes的诞生带来了数据中心视野的容器调度能力。随着Kubernetes技术发展，它已经不仅是容器调度技术，也逐步发展为容器-原生虚拟化和serverless计算的平台。

kubernetes管理了容器规模，从边缘计算的微小集群到数据中心超大规模集群，在公有云和私有云环境都得到了广泛应用。由于按需调度运行容器，通过"复杂"的技术结合到当前广泛使用的云计算平台，可以充分释放云计算的灵活性和规模化。

.. note::

   虽然Docker/Kubernetes一直承诺我们更快速的部署，易于管理和强大的伸缩性，但是，就如同漂浮在海面上的冰山，你所看到的简洁易用是建立在底层无数辛勤开发和部署的云计算工作之上的。目前的技术发展趋势是，不断把客户的复杂度降低，把所有的脏活累活都下沉到系统平台。所以，决不要以为Kubernetes横空出世就解决了一切问题。恰恰相反，分布式、高可用、容灾、实时计算，随着规模的不断膨胀，这些技术的挑战越来越大。

   从阿里云转岗到蚂蚁金服，从事了五年的围绕Kubernetes的工作，这个领域太过复杂，需要重新 :ref:`think_k8s`

.. note::

   **学习资料**

   Google推出的Kubernetes提供了大规模部署和管理容器的基础平台，但是学习曲线比较陡峭。从我个人的学习经验来看，官方文档是最为全面和系统的，并且 `Google提供的在线教程 <https://kubernetes.io/docs/tutorials/>`_ 设计精巧，并且提供在线模拟，非常适合入门。难得的是，这部分官方教程是提供中文版的，方便了国内技术爱好者学习。本书的 :ref:`kubernetes_startup` 就是我学习该教程的实践笔记(我是从英文版翻译摘要和改写，并加入了我自己的一些实践内容，所以和官方教程有所差异)。

   `Google提供的在线教程 <https://kubernetes.io/docs/tutorials/>`_ 介绍了不同平台提供的 `kubernetes在线教程 <https://kubernetes.io/docs/tutorials/online-training/overview/>`_ ，我粗略看了一下各有侧重，值得尝试。

   `阿里云联合CNCF推出的云原生技术公开课 <https://edu.aliyun.com/course/1651?spm=5176.10731542.0.0.1cea20beUj7Oz0>`_ 由一线工程师和开源社区一起制作，讲解清晰，并且中文授课，推荐学习。

.. toctree::
   :maxdepth: 2

   think_k8s.rst
   kubernetes_overview.rst
   startup_prepare/index
   startup/index
   cli/index
   kind/index
   concepts/index
   deploy/index
   deploy_app/index
   manage_object/index
   administer/index
   access_application/index
   container_runtimes/index
   configure/index
   network/index
   in_action/index
   numa/index
   backup/index
   storage/index
   production/index
   service_mesh/index
   istio/index
   serverless/index
   ci_cd/index
   monitor/index
   self_healing/index
   debug/index
   knative/index
   security/index
   virtual/index
   arm/index
   gpu/index
   kubeflow/index
   argo/index
   kueue/index
   k8s_android/index
   k3s/index
   k3d/index
   k0s/index
   platform/index
   cloud/index
   cncf/index

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
