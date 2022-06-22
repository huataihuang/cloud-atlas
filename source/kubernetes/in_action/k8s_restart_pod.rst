.. _k8s_restart_pod:

=====================
Kubernetes重启pod
=====================

有以下集中方式重启(重建)pod

采用replicas重启pod
=====================

在 :ref:`replicaset` 中控制 :ref:`pod_lifecycle` ，实现原理是执行 ``kubectl scale --replicas=0`` 然后恢复 ``kubectl scale --replicas=N`` ，这个过程会重启容器

对于指定pod重启，可以通过保持 ``replicas`` 值不变情况下，直接 ``kubectl delete pod XXX`` 删除pod，然后 ``replicaset`` 会自动恢复pod，实现pod重启

采用 ``rollout restart`` 命令重启 pods
=======================================

采用 ``replicas`` 伸缩的问题是，有一段时间应用不可访问(因为所有pod都被缩容)。解决方法之一是上文通过手工方式一一删除pod，通过 ``replicaset`` 自动恢复重建。这种方式是手工控制重启进度。

另一种比较 **优雅** 的方式是使用 ``rollout restart`` 命令::

   kubectl rollout restart deployment nginx-deployment

上述命令会滚动重启 ``nginx-deployment`` 的所有pods

修改deployment环境变量重启pods
==================================

当修改pods的环境变量，pod会自动重启。也就是使用 ``kubectl set env`` 命令修改变量，则pods重启(因为pod的配置修改默认就是重建)::

   kubectl set env deployment nginx-deployment DATE=$()

此时pod重建，然后执行::

   kubectl describe <pod_name>

可以看到pod的环境变量::

   Containers:
     nginx-pod:
       ...
       Environment:
         DATE:
       ...

参考
=======

- `How to Restart Pods in Kubernetes [Step-by-Step] <https://adamtheautomator.com/restart-pod-kubernetes/>`_
