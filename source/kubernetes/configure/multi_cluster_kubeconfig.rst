.. _multi_cluster_kubeconfig:

================================
多集群kubeconfig配置
================================

.. kubeconfig:

kubeconfig
===========

可以通过kubeconfig文件来组织有关集群，用户，namespace，以及认证机制的信息。 ``kubectl`` 命令使用kubeconfig来找到需要访问的集群和与集群的API服务器通讯。

默认情况下， ``kubectl`` 查看的是 ``$HOME/.kube`` 目录下的 ``config`` 配置文件。可以通过 ``KUBECONFIG`` 环境变量或者 ``--kubeconfig`` 参数来指定使用特定的kubeconfig文件。

::

   export KUBECONFIG=/home/huatai/kubeconfig/dev/admin.kubeconfig.yaml
   kubectl get nodes

这里可能会遇到报错::

   The connection to the server localhost:8080 was refused - did you specify the right host or port?

请检查一下 ``env`` 命令输出，如果你只是使用 ``KUBECONFIG=XXX`` 则可能环境变量没有生效，例如对于zsh，需要明确使用 ``export`` 命令，否则即使变量生效，但是 ``env`` 输出依然是错误的。

参考
=======

- `Organizing Cluster Access Using kubeconfig Files <https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/>`_
- `Configure Access to Multiple Clusters <https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters>`_
