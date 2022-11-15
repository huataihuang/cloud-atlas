.. _kind_cluster:

============================
kind集群
============================

使用 :ref:`kind_startup` 部署了Kubernetes集群，可以使用 kubectl 与该集群交互。

默认的集群访问配置存储在 ``${HOME}/.kube/config`` (如果没有设置 ``$KUBECONFIG`` 环境变量)。

创建集群
============

- 创建kind集群::

   kind create cluster

- 检查kind创建的集群::

   kind get clusters

可以看到默认创建的集群名称 ``kind``

- 通过 ``--name`` 参数，可以创建第二个集群::

   kind create cluster --name kind-2

- 然后检查可以看到系统创建了2个集群::

   kind get clusters

输出::

   kind
   kind-2

在创建了2个集群之后，用户目录下 ``~/.kube/config`` 将包含两个集群访问密钥，为了通过 ``kubectl`` 访问不同集群，需要使用上下文参数 ``--context`` ，上下文的名字是 ``kind-<集群名>`` ，例如 ``kind-kind`` 和 ``kind-kind-2`` 。举例，我们访问第二个集群 ``kind-2`` 使用::

   kubectl -n kube-system get pods --context kind-kind-2

删除集群
===========

kind删除集群命令也非常简单::

   kind delete cluster --name <集群名>

如果没有指定 ``--name`` 参数，则默认集群context名字 ``kind`` 将被删除。


