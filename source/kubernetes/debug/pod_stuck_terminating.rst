.. _pod_stuck_terminating:

==============================
停滞在"Terminiating"状态Pod
==============================

在Kubernetes中，有些pod删除后一直显示 ``Terminating`` 状态无法清理，通常我们需要释放掉这个资源，需要采用一些措施

常见原因:

- pod有一个没有完成的 ``finalizer``
- pod没有响应终止信号

检查
=======

- 使用 ``get pods`` 命令检查::

   kubeclt get pods

看到类似::

   NAME                     READY     STATUS             RESTARTS   AGE
   nginx-7ef9efa7cd-qasd2   1/1       Terminating        0          1h

处理方法
=============

方法一: ``finalizers``
--------------------------

- 检查pod是否存在 ``finalizers`` ::

   kubectl get pod -n [NAMESPACE] -p [POD_NAME] -o yaml

输出中如果在 ``metadata`` 部分存在 ``finalizers`` 段落，则通过删除掉 ``finalizers`` 来解决::

   kubectl patch pod [POD_NAME] -p '{"metadata":{"finalizers":null}}'

方法二: 强制删除
-----------------

如果清理了 ``finalizers`` 没有解决问题，则强制删除::

   kubectl delete pod --grace-period=0 --force --namespace [NAMESPACE] [POD_NAME]

.. warning::

   强制删除时候会提示::

      warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
      pod "XXXXX" force deleted

   这其实表明节点上的资源并没有释放，因为节点上还残留运行的容器，所以可能需要登陆到worker节点上来手工处理

根因排查
==========

导致kuberntes无法终止pod的原因通常是因为worker节点存在异常，导致资源不释放进而容器不能终止。一般需要检查 ``kubelet`` 的日志，排查为何无法停滞容器，例如卷不能卸载常会触发这样的问题。

参考
======

- `Pod Stuck In Terminating State <https://containersolutions.github.io/runbooks/posts/kubernetes/pod-stuck-in-terminating-state/>`_
- `Force Delete StatefulSet Pods <https://kubernetes.io/docs/tasks/run-application/force-delete-stateful-set-pod/>`_
