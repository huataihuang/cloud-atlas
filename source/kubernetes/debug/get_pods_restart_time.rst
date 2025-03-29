.. _get_pods_restart_time:

======================
获取pod重启时间
======================

当线上出现大量pod被重建，需要快速找出那些pod重建过:

通过描述pod可以知道pod的字段结构::

   kubectl get pods -o yaml my-nginx-5b56ccd65f-4vmms

假设在 ``metadata`` 段落可以看到::

   apiVersion: v1
   kind: Pod
   metadata:
     annotations:
     ...
     creationTimestamp: "2022-01-18T08:20:23Z"
     finalizers:
     ...

那么我们就可以知道查询出 ``creationTimestamp`` 可以获得这个容器的创建时间

我们可以使用如下命令查询出这个指定容器的启动时间::

   kubectl get pods -o yaml my-nginx-5b56ccd65f-4vmms -o custom-columns:NAME:.metadata.name,FINISHED:.metadata.creationTimestamp

输出就是类似::

   NAME                                            FINISHED
   my-nginx-5b56ccd65f-4vmms                       2022-01-18T08:20:23Z

依次类推，我们要查询所有pods::

   kubectl get pods -o yaml --all-namespaces  -o custom-columns:NAME:.metadata.name,FINISHED:.metadata.creationTimestamp
   
然后排序就可以获得时间  

参考
======

- `kubectl get last restart time of a pod <https://stackoverflow.com/questions/66601827/kubectl-get-last-restart-time-of-a-pod>`_
