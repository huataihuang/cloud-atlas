.. _pod_lifecycle:

===================
Pod生命周期
===================

伸缩(replicas)
====================

和 :ref:`kvm` 不同，容器并不支持suspend操作，在Kubernetes中也不支持暂停pod的功能，因为对于Kubernetes来说，重新调度到新节点上创建一个新的pod来说更为轻易。

所以在Kubernetes中，如果要暂停某个部署的pod，实际上是将这个deployment的replicas设置为0，这样Kubernetes就会终止所有pod。要恢复，则再恢复之前的replicas设置值就可以。举例，例如要停止 ``test-space`` 这个namespace中的apiserver，则执行::

   kubectl -n test-space scale --replicas=0 deployment/apiserver

恢复时候，执行::

   kubectl -n test-space scale --replicas=3 deployment/apiserver


.. note::

   语法::

      kubectl scale --replicas=0 deployment/<pod name> --namespace=<namespace>

参考
===========

- `Suspending a container in a kubernetes pod <https://stackoverflow.com/questions/43617044/suspending-a-container-in-a-kubernetes-pod>`_
- `How to Restart Pods in Kubernetes [Step-by-Step] <https://adamtheautomator.com/restart-pod-kubernetes/>`_
