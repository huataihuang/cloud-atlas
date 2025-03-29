.. _debug_k8s_deleted_pods:

===========================
排查已经被删除pods(重启)
===========================

在kubernetes集群中， ``deployments`` 的pods在异常crash时会自动恢复，不过我们还是需要排查原先pods为何会crash::

   kubectl -n kube-system get pods -o wide| grep scheduler

显示::

   scheduler-86c895bdc9-b7rnr                 1/1     Running   3          65d     192.168.37.200    z-k8s-m-1  <none>           <none>
   scheduler-86c895bdc9-ng4gw                 1/1     Running   5          65d     192.168.37.192    z-k8s-m-2  <none>           <none>
   scheduler-86c895bdc9-w8mrh                 1/1     Running   4          60d     192.168.37.231    z-k8s-m-3  <none>           <none>

- 要知道哪个pod重启了，可以通过查看指定 ``namespace`` 的events::

   kubectl -n kube-system get event

会看到最近 ``1`` 小时事件::

   LAST SEEN   TYPE      REASON                 OBJECT                                   MESSAGE
   7m9s        Warning   Unhealthy              pod/apiserver-65cc4bc696-7grkn           Readiness probe failed: Get https://192.168.37.203:6443/readyz: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
   59m         Warning   Unhealthy              pod/apiserver-65cc4bc696-kndsn           Readiness probe failed: Get https://192.168.37.158:6443/readyz: net/http: request canceled while waiting for connection (Client.Timeout exceeded while awaiting headers)
   29m         Normal    Pulling                pod/scheduler-756b6fcfc7-9wxww   Pulling image "reg.docker.huatai.me/k8s/scheduler:release-v1.2.5_20211026111044_216c6766"
   29m         Normal    Pulled                 pod/scheduler-756b6fcfc7-9wxww   Successfully pulled image "reg.docker.huatai.me/k8s/scheduler:release-v1.2.5_20211026111044_216c6766"
   29m         Normal    Created                pod/scheduler-756b6fcfc7-9wxww   Created container scheduler
   29m         Normal    Started                pod/scheduler-756b6fcfc7-9wxww   Started container scheduler
   29m         Normal    WithOutPostStartHook   pod/scheduler-756b6fcfc7-9wxww   Container scheduler with out poststart hook
   29m         Normal    Pulling                pod/scheduler-86c895bdc9-ng4gw   Pulling image "reg.docker.huatai.me/k8s/scheduler:release-v1.2.4_20210928203943_53875ece"
   29m         Normal    Pulled                 pod/scheduler-86c895bdc9-ng4gw   Successfully pulled image "reg.docker.huatai.me/k8s/scheduler:release-v1.2.4_20210928203943_53875ece"
   29m         Normal    Created                pod/scheduler-86c895bdc9-ng4gw   Created container scheduler
   29m         Normal    Started                pod/scheduler-86c895bdc9-ng4gw   Started container scheduler
   29m         Normal    WithOutPostStartHook   pod/scheduler-86c895bdc9-ng4gw   Container scheduler with out poststart hook
   34m         Normal    Pulling                pod/scheduler-86c895bdc9-w8mrh   Pulling image "reg.docker.huatai.me/k8s/scheduler:release-v1.2.4_20210928203943_53875ece"
   34m         Normal    Pulled                 pod/scheduler-86c895bdc9-w8mrh   Successfully pulled image "reg.docker.huatai.me/k8s/scheduler:release-v1.2.4_20210928203943_53875ece"
   34m         Normal    Created                pod/scheduler-86c895bdc9-w8mrh   Created container scheduler
   34m         Normal    Started                pod/scheduler-86c895bdc9-w8mrh   Started container scheduler
   34m         Normal    WithOutPostStartHook   pod/scheduler-86c895bdc9-w8mrh   Container scheduler with out poststart hook

要过滤出指定pods，一种方法是直接使用 ``grep`` 命令，例如 ``kubectl get events | grep scheduler-86c895bdc9-w8mrh`` 。另外一种方法是采用标准的 ``field-selector`` ：

  - 首先找出 ``field`` ::

     kubectl -n kube-system get events --output json

  可以看到::

     ...
     {
        "apiVersion": "v1",
        ...
        "involvedObject": {
            ...
            "name": "scheduler-86c895bdc9-w8mrh",
            ...
        }
     }

  - 可以知道 ``field-selector`` 就是 ``involvedObject.name`` ，所以查询命令::

     kubectl -n kube-system get events --field-selector involvedObject.name=scheduler-86c895bdc9-w8mrh

  效果和使用 ``grep`` 相同

但是，这里存在一个问题，就是你不知道重启前，被替换掉的pod的名字，所以你就很难查看之前pods如何crash掉的。

- 以前版本有一个查询 ``-a`` 参数::

   kubectl -n kube-system get pods -a

类似于 ``docker ps -a`` 可以查看已经清理掉掉pods，不过，近期版本已经不再支持，需要采用命令::

   kubectl -n kube-system get event -o custom-columns=NAME:.metadata.name | cut -d "." -f1

但是，很不幸，这个命令只输出最近一个小时的时间。对于我上述案例，最近一小时并没有包含之前创建pods的情况记录，所以也找不到对应pods名字。

不过，对于管控pods，调度的 ``scheduler`` 只在限定的节点 ( ``z-k8s-m-1`` 到 ``z-k8s-m-3`` )，所以还是可以找到对于pods上的记录和日志

.. note::

   :ref:`get_pods_restart_time` 用于找出最近重启的应用服务器(重建)

参考
=========

- `How to list Kubernetes recently deleted pods? <https://stackoverflow.com/questions/40636021/how-to-list-kubernetes-recently-deleted-pods>`_
- `kubectl get events only for a pod <https://stackoverflow.com/questions/51931113/kubectl-get-events-only-for-a-pod>`_
