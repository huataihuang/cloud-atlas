.. _get_pods_on_node:

=====================
获取指定节点上的pods
=====================

我们在线上环境经常需要检查一些服务器上运行的pods状态，特别是需要找出一些残留 :ref:`pod_stuck_terminating` 清理。由于Kubernetes集群可能有大量的namespace，以及海量的pods，所以如果不提供任何限定条件就直接查询，例如::

   kubectl get pods --all-namespaces -o wide 

.. warning::

   如果没有任何限定条件全量查询，会对apiserver和etcd产生极大的压力，甚至长时间无法返回数据。所以，绝不推荐采用这样粗暴的方式

那么，如何能够查询出成千上万个node节点中特定节点上的pod呢？其实有非常简单的方法，就类似 :ref:`sql` 一样，采用查询条件 ``--field-selector`` ::

   kubectl get pods --all-namespaces -o wide --field-selector spec.nodeName=<node>

这个添加了特定查询条件的查询效率极高，可以瞬间从上万个节点的集群中查询出指定节点的运行pod，并且对apiserver和etcd无压力。

另外一种方式也能获得指定节点上的容器，不过这种方式是为了获得指定节点较为详细的配置和监控信息，附带提供了运行pods的列表及状态，所以功能较为复杂、查询较为缓慢。如果要快速定位节点问题，可以尝试这个方法::

   kubectl describe node $NODE

输出信息还包含了node节点以及容器的负载概括，以及关键事件，可以快速发现一些运维问题。不过，这个 ``describe node`` 方式很沉重，仅仅用来查询节点上的pods有些杀鸡用牛刀了。

参考
=======

- `Kubernetes API - Get Pods on Specific Nodes <https://stackoverflow.com/questions/39231880/kubernetes-api-get-pods-on-specific-nodes>`_
