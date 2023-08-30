.. _workload_resources:

======================================
workload resources(工作负载资源)
======================================

在Kubernetes中，所谓 ``workload`` (工作负载) 就是指在 Kubernetes 上运行的应用程序。(这句话我感觉是误导)

我们知道 :ref:`pods` 是一组容器的集合，而 workload resources (或者简称为 workload) 是一组Pods的集合: 之所以发明出workload resources概念，是为了简化一组pods的管理。也就是说，我们不需要分别管理一个个pods，只需要将相同的pods组合成一个workload，就可以统一管理，Kubernetes会通过 :ref:`controllers` 来确保这组Pods保持一致的运行状态以及指定数量:

- :ref:`deployment` 和 :ref:`replicaset` : ``deployment`` 适合管理集群上的无状态应用，在 ``deployment`` 汇总所有 ``pod`` 完全等价，并且在需要时被替换
- :ref:`statefulset` : 运行一个或多个需要跟踪应用状态的 :ref:`pods` 。例如，数据需要持久化的Pod就可以使用 ``StatefulSet`` ，将每个Pod和某个 :ref:`k8s_persistent_volumes` 对应起来(也就是共享存储)，这样 ``StatefulSet`` 的各个Pod可以通过共享的 :ref:`k8s_persistent_volumes` 交换数据提高整体服务可靠性(你可以 ``StatefulSet`` 理解成共享NAS的WEB服务器，高可用)
- :ref:`job` : 创建一个或多个Pod，并持续重复Pod的执行，直到指定数量的Pod成功终止。也就是说定义Job可以确保一组Pod围绕一个任务来反复执行直到最终目标达成后Job终止 (通常在 :ref:`machine_learning` 大规模并行计算时使用)

参考
======

- `Kubernetes 文档 概念 工作负载 <https://kubernetes.io/zh-cn/docs/concepts/workloads/>`_
