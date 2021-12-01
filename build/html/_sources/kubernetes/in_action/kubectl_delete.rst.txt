.. _kubectl_delete:

====================
kubectl的delete案例
====================

清理某个状态的pod
=====================

在Kubernetes集群中，经常会有一些pod已经 ``completed`` 但是没有清理的情况，我们找出这些状态进行清理::

   kubectl get pod --field-selector=status.phase==Succeeded

清理::

   kubectl delete pod --field-selector=status.phase==Succeeded

参考
=======

- `How to delete completed kubernetes pod? <https://stackoverflow.com/questions/55072235/how-to-delete-completed-kubernetes-pod>`_
