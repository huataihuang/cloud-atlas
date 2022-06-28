.. _get_pods_on_node:

=====================
获取指定节点上的pods
=====================

我们在线上环境经常需要检查一些服务器上运行的pods状态，特别是需要找出一些残留 :ref:`pod_stuck_terminating` 清理。由于Kubernetes集群可能有大量的namespace，以及海量的pods，所以如果不提供任何限定条件就直接查询，例如::

   kubectl get pods --all-namespaces -o wide 

.. warning::

   如果没有任何限定条件全量查询，会对apiserver和etcd产生极大的压力，甚至长时间无法返回数据。所以，绝不推荐采用这样粗暴的方式



参考
=======

- `Kubernetes API - Get Pods on Specific Nodes <https://stackoverflow.com/questions/39231880/kubernetes-api-get-pods-on-specific-nodes>`_
