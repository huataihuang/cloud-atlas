.. _finalizers:

===============
Finalizers
===============

Finalizer 是带有名字空间的键(namespaced keys)，告诉Kubernetes需要等待特定条件满足后，才能完全删除标记为删除的资源。Finalers通知控制器清理被删除对象拥有的资源。

当通知Kubernetes删除一个指定了 Finalizers 的对象时，Kubernetes API通过填充 ``.metadata.deletionTimestamp`` 来标记要删除的对象，并返回 ``202`` 状态码(HTTP "已接受")使对象进入只读状态。此时控制平面(control plane)或其他组件会采用 Finalizers 所定义的动作，而目标对象仍然处于终止(Terminating)状态。

.. note::

   你可以理解为 ``Finalizers`` 是对象删除前需要完成的一系列动作清单，只有 ``metadata.finalizers`` 字段清空之后，Kubernetes踩认为系列动作已经完成，才会删除对象。

可以使用 Finalizer 控制资源的垃圾回收。例如可以定义Finalizer，在删除目标资源之前清理相关资源或基础设施。

删除该资源时，处理删除请求的 API 服务器会注意到 ``finalizers`` 字段中的值， 并进行以下操作：

- 修改对象，将你开始执行删除的时间添加到 ``metadata.deletionTimestamp`` 字段
- 禁止对象被删除，直到其 ``metadata.finalizers`` 字段内的所有项被删除
- 返回 ``202`` 状态码（HTTP "Accepted"）

.. warning::

   在对象卡在删除状态的情况下，要避免手动移除 Finalizers，以允许继续删除操作。 Finalizers 通常因为特殊原因被添加到资源上，所以强行删除它们会导致集群出现问题。 只有了解 finalizer 的用途时才能这样做，并且应该通过一些其他方式来完成 （例如，手动清除其余的依赖对象）。

通过patch方式更新对象去除finalizers
=====================================

实际生产维护，因为节点故障导致资源没有摘除的情况较多，例如公司的 ``cni-services`` 组件没有处理掉宕机节点(因为节点agent没有正确完成IP处理流程，宕机了啊)。此时紧急情况下，我们需要通过去除pod的 ``finalizers`` 来完成资源释放::

     finalizers:
       - pod.beta1.sigma.ali/cni-allocated

- 单个处理节点上pod的释放脚本:

.. literalinclude:: finalizers/patch_clean_finalizer
   :language: bash
   :caption: 通过 ``patch`` 清理掉pod的finalizers

- 批量处理多个节点上pod释放脚本:

.. literalinclude:: finalizers/batch_patch_clean_finalizer
   :language: bash
   :caption: 批量通过 ``patch`` 清理掉pod的finalizers

参考
======

- `Kubernetes 文档/概念/概述/Kubernetes 对象/Finalizers <https://kubernetes.io/zh-cn/docs/concepts/overview/working-with-objects/finalizers/>`_
- `remove kubernetes service-catalog finalizer with cli <https://stackoverflow.com/questions/52819428/remove-kubernetes-service-catalog-finalizer-with-cli>`_
