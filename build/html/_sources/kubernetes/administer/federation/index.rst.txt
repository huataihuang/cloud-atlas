.. _federation:

======================
Kubernetes Federation
======================

Kubernetes提供了基础的部署应用程序到集群到方法：只需要简单的 ``kubectl create -f app.yaml`` ，但是部署应用到多个集群就没有这么方便了。如何分布应用程序负载，应用程序资源到复制，以及如何在集群中复制或分区。如何在现有都多个集群中的部分或全部分配资源等问题都是巨大的挑战。

Federation（联邦）是Kubernetes项目下的单个最大的子项目，用于管理多个Kubernetes集群。

.. toctree::
   :maxdepth: 1

   federation_evolution.rst
