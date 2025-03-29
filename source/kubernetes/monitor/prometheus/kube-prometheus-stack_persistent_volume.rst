.. _kube-prometheus-stack_persistent_volume:

================================================
``kube-prometheus-stack`` 持久化卷
================================================

:ref:`helm3_prometheus_grafana` 默认部署的监控采用了内存储存( ``emptyDir`` 类型内存储存)，我当时找到 `Deploying kube-prometheus-stack with persistent storage on Kubernetes Cluster <https://blog.devops.dev/deploying-kube-prometheus-stack-with-persistent-storage-on-kubernetes-cluster-24473f4ea34f>`_ 参考，想构建一个PV/PVC来用于Prometheus，但是没有成功。

手工编辑 :ref:`statefulset` prometheus，添加存储 PV/PVC 实际上不能成功，包括我想编辑 ``nodeSelector`` 来指定服务器，也完全无效。正在绝望的时候，找到 `[kube-prometheus-stack] [Help] Persistant Storage #186 <https://github.com/prometheus-community/helm-charts/issues/186>`_ 和 `[prometheus-kube-stack] Grafana is not persistent #436 <https://github.com/prometheus-community/helm-charts/issues/436>`_ ，原来 ``kube-prometheus-stack`` 使用了 `Prometheus Operator <https://github.com/prometheus-operator/prometheus-operator>`_ 来完成部署，实际上在最初生成 ``kube-prometheus-stack.values`` 这个文件中已经包含了大量的配置选项(包括存储)以及注释:

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/helm_inspect_values_prometheus-stack
   :language: bash
   :caption: ``helm inspect values`` 输出Prometheus Stack的chart变量值

检查生成的 ``kube-prometheus-stack.values`` 可以看到如下配置内容:

.. literalinclude:: kube-prometheus-stack_persistent_volume/kube-prometheus-stack.values
   :language: yaml
   :caption: ``kube-prometheus-stack.values`` 包含的持久化存储配置模版，prometheus部分
   :emphasize-lines: 15-28

``hostPath`` 存储卷
=====================

.. note::

   请注意， ``alertmanager`` 和 ``prometheus`` 共用一个存储目录，但是需要注意 ``即使挂载同一个目录，也必须为每个 PV/PVC 完成配置，因为 PV/PVC 是一一对应的的`` (参考 `Can Multiple PVCs Bind to One PV in OpenShift? <https://access.redhat.com/solutions/3064941>`_ )

我实现简单的 :ref:`k8s_hostpath` :

.. literalinclude:: kube-prometheus-stack_persistent_volume/kube-prometheus-stack.values_hostpath
   :language: yaml
   :caption: ``kube-prometheus-stack.values`` 配置简单的本地 ``hostPath`` 存储卷(案例包含了 prometheus/alertmanager/thanos/grafana)

.. note::

   这里配置 ``accessModes: ["ReadWriteOnce"]`` 表示只有一个节点(a single node)可以挂载卷。另外两种模式是 ``ReadOnlyMany`` (多个节点可以只读挂载) 和 ``ReadWriteMany`` (多个节点可以读写挂载) - `kubernetes persistent volume accessmode <https://stackoverflow.com/questions/37649541/kubernetes-persistent-volume-accessmode>`_

- 然后准备一个 PV 配置, 创建 :ref:`k8s_hostpath` 持久化存储卷:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/kube-prometheus-stack-pv.yaml
   :language: yaml
   :caption: ``kube-prometheus-stack-pv.yaml`` 创建 :ref:`k8s_hostpath` 持久化存储卷(案例包含了 prometheus/alertmanager/thanos/grafana)
   :emphasize-lines: 1-15

.. note::

   只需要创建 PV 就可以， ``kube-prometheus-stack`` values.yaml 中提供了 PVC 配置，会自动创建PVC

- 执行:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/kube-prometheus-stack-pv_apply
   :language: bash
   :caption: 执行构建 ``kube-prometheus-stack-pv``

- 更新:

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

Grafana持久化存储
-------------------

我检查 ``kube-prometheus-stack-pv`` ，惊讶地发现，只有 ``prometheus`` , ``alertmanager`` 和 ``thanos`` 有对应的 ``storageSpec`` ，但是没有找到 ``grafana`` 的配置入口。

参考 `[prometheus-kube-stack] Grafana is not persistent #436 <https://github.com/prometheus-community/helm-charts/issues/436>`_ 原来配置方式略有不同，不是使用类似 ``prometheus.prometheusSpec.storageSpec`` ，而是使用 ``grafana.persistence`` 。这是因为上游 :ref:`grafana` 的 :ref:`helm` chart 不同:

.. literalinclude:: kube-prometheus-stack_persistent_volume/kube-prometheus-stack.values_grafana_persistence
   :language: yaml
   :caption: ``kube-prometheus-stack.values`` 配置Grafana持久化存储
   :emphasize-lines: 7-15

.. note::

   Grafana持久化的卷目录结构和 prometheus/alertmanager 不同:

   - ``prometheus/alertmanager`` 是在 ``PV`` 目录下又创建了一个子目录来存储数据，例如在 ``/prometheus/data`` 目录下创建一个 ``prometheus-db`` 和 ``alertmanager-db`` 子目录
   - ``grafana`` 则直接在 ``PV`` 目录下存储数据，数据分散在多个子目录，所以看起来有点乱。为了能够和 ``prometheus/alertmanager`` 和谐共处，所以建议 ``grafana`` 的 ``PV`` 设置多一级子目录 ``grafana-db``

.. warning::

   :ref:`grafana` 的持久化卷目录和 ``prometheus`` 不同，一定要注意给 ``grafana`` 配置一个独立子目录或者其他目录，否则 ``grafana`` 持久化目录会和 ``prometheus`` 数据目录重合，并且由于 ``grafana`` 容器初始化时候自动修改目录属主，将会导致 ``prometheus`` 无法正常读写磁盘(数据采集终止)。 我不小心乌龙了 :ref:`kube-prometheus-stack_persistent_volume_grafana_debug` ，切切!!!

异常排查
============

admissionWebhooks错误
----------------------

报错信息

.. literalinclude:: kube-prometheus-stack_persistent_volume/helm_upgrade_gpu-metrics_config_err
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack 报错信息

我参考 `[stable/prometheus-operator] pre-upgrade hooks failed with prometheus-operator-admission: dial tcp 172.20.0.1:443: i/o timeout on EKS cluster #20480 <https://github.com/helm/charts/issues/20480>`_ 将 ``admissionWebhooks`` 改成 ``false`` :

.. literalinclude:: kube-prometheus-stack_persistent_volume/prometheusOperator_admissionWebhooks_enabled_false
   :language: yaml
   :caption: 关闭 Prometheus Operator 的 admissionWebhooks
   :emphasize-lines: 21

这里关闭掉 Prometheus Operator 的 admissionWebhooks 没有直接影响，但是不会自动检查Prometheus错误格式的rules

此外，开启了 Prometheus Operator 的 admissionWebhooks 就会看到每次部署时候会自动运行一个 ``kube-prometheus-stack-1681-admission-create-fdfs2`` 这样的pods，运行完成后停留在 ``Completed`` 状态，也就是完成部署Prometheus的规则格式检查。如果这个Pod迟迟无法运行成功(例如我遇到Calico网络分配IP异常 :ref:`containerd_cni_plugin` 存在bridge插件协议支持问题)，就会导致更新 alertmanager / prometheus 配置刷新非常缓慢问题。 

调度失败错误
---------------

调度失败::

   Events:
     Type     Reason            Age   From               Message
     ----     ------            ----  ----               -------
     Warning  FailedScheduling  106s  default-scheduler  0/8 nodes are available: 8 pod has unbound immediate PersistentVolumeClaims. preemption: 0/8 nodes are available: 8 Preemption is not helpful for scheduling

检查发现，原来 ``kube-prometheus-stack`` 会自动创建一个 ``pvc`` (根据定义)，然后去绑定你预先创建的 ``pv`` ；但是你千万不能预先创建一个 ``pvc`` (对应 ``pv`` )，这样就会抢在 ``kube-prometheus-stack`` 绑定，导致失败::

   $ kubectl get pvc -A
   NAMESPACE    NAME                                                                                                     STATUS    VOLUME                     CAPACITY   ACCESS MODES   STORAGECLASS      AGE
   prometheus   kube-prometheus-stack-pvc                                                                                Pending   kube-prometheus-stack-pv   0                                           89m
   prometheus   prometheus-kube-prometheus-stack-1680-prometheus-db-prometheus-kube-prometheus-stack-1680-prometheus-0   Pending                                                        prometheus-data   4m8s

   $ kubectl get pv -A
   NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS      REASON   AGE
   kube-prometheus-stack-pv   10Gi       RWO            Retain           Available           prometheus-data            89m

但是，发现 ``pvc`` 依然出于 pending状态::

   $ kubectl get pv -A
   NAME                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS      REASON   AGE
   kube-prometheus-stack-pv   10Gi       RWO            Retain           Available           prometheus-data            112m

   $ kubectl get pvc -A
   NAMESPACE    NAME                                                                                                     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS      AGE
   prometheus   prometheus-kube-prometheus-stack-1680-prometheus-db-prometheus-kube-prometheus-stack-1680-prometheus-0   Pending                                      prometheus-data   27m

为什么呢？ ``kubectl describe pvc prometheus-kube-prometheus-stack-1680-prometheus-db-prometheus-kube-prometheus-stack-1680-prometheus-0 -n prometheus`` 

我尝试删除 ``pvc`` ``prometheus-kube-prometheus-stack-1680-prometheus-db-prometheus-kube-prometheus-stack-1680-prometheus-0`` ，但是发现再也没有生成，并且调度失败::

   $ kubectl describe pods prometheus-kube-prometheus-stack-1680-prometheus-0 -n prometheus
   ...
   Events:
     Type     Reason            Age                 From               Message
     ----     ------            ----                ----               -------
     Warning  FailedScheduling  23m (x5 over 43m)   default-scheduler  0/8 nodes are available: 8 pod has unbound immediate PersistentVolumeClaims. preemption: 0/8 nodes are available: 8 Preemption is not helpful for scheduling.
     Warning  FailedScheduling  19m                 default-scheduler  0/8 nodes are available: 8 persistentvolumeclaim "prometheus-kube-prometheus-stack-1680-prometheus-db-prometheus-kube-prometheus-stack-1680-prometheus-0" is being deleted. preemption: 0/8 nodes are available: 8 Preemption is not helpful for scheduling.
     Warning  FailedScheduling  4m2s (x3 over 14m)  default-scheduler  0/8 nodes are available: 8 persistentvolumeclaim "prometheus-kube-prometheus-stack-1680-prometheus-db-prometheus-kube-prometheus-stack-1680-prometheus-0" not found. preemption: 0/8 nodes are available: 8 Preemption is not helpful for scheduling.

解决方法很简单: ``pvc`` 和 ``pv`` 都要删除，然后重新如上文创建一个 ``pv`` 就可以了， ``kube-prometheus-stack`` 会自动生成 ``pvc`` 并且 bind 到指定 ``pv``

pod启动失败错误
-----------------

已经正确调度到目标节点 ``i-0jl8d8r83kkf3yt5lzh7`` ，并且可以看到 ``pvc`` 正确绑定了 ``pv`` 。在目标服务器上检查 ``/home/t4/prometheus/data`` 目录下自动创建了 ``prometheus-db`` 目录。

但是发现 ``prometheus`` 出现 crash::

   # kubectl get pods -A -o wide | grep prometheus | grep -v node-exporter
   prometheus    alertmanager-kube-prometheus-stack-1681-alertmanager-0            2/2     Running             1          2m18s   10.233.127.15   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    kube-prometheus-stack-1681-operator-5b7f7cdc78-xqtm5              1/1     Running             0          2m25s   10.233.127.13   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    kube-prometheus-stack-1681228346-grafana-fb4695b7-2qhpp           3/3     Running             0          33h     10.233.127.3    i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    kube-prometheus-stack-1681228346-kube-state-metrics-89f44fm2qbb   1/1     Running             0          2m25s   10.233.127.14   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    prometheus-kube-prometheus-stack-1681-prometheus-0                1/2     CrashLoopBackOff    1          2m17s   10.233.127.16   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>

检查日志::

   # kubectl -n prometheus logs prometheus-kube-prometheus-stack-1681-prometheus-0 -c prometheus
   ts=2023-04-13T00:57:17.123Z caller=main.go:556 level=info msg="Starting Prometheus Server" mode=server version="(version=2.42.0, branch=HEAD, revision=225c61122d88b01d1f0eaaee0e05b6f3e0567ac0)"
   ts=2023-04-13T00:57:17.123Z caller=main.go:561 level=info build_context="(go=go1.19.5, platform=linux/amd64, user=root@c67d48967507, date=20230201-07:53:32)"
   ts=2023-04-13T00:57:17.123Z caller=main.go:562 level=info host_details="(Linux 3.10.0-1160.83.1.el7.x86_64 #1 SMP Wed Jan 25 16:41:43 UTC 2023 x86_64 prometheus-kube-prometheus-stack-1681-prometheus-0 (none))"
   ts=2023-04-13T00:57:17.123Z caller=main.go:563 level=info fd_limits="(soft=1048576, hard=1048576)"
   ts=2023-04-13T00:57:17.123Z caller=main.go:564 level=info vm_limits="(soft=unlimited, hard=unlimited)"
   ts=2023-04-13T00:57:17.124Z caller=query_logger.go:91 level=error component=activeQueryTracker msg="Error opening query log file" file=/prometheus/queries.active err="open /prometheus/queries.active: permission denied"
   panic: Unable to create mmap-ed active query log
   
   goroutine 1 [running]:
   github.com/prometheus/prometheus/promql.NewActiveQueryTracker({0x7fff8871300f, 0xb}, 0x14, {0x3d8ba20, 0xc00102e280})
   	/app/promql/query_logger.go:121 +0x3cd
   main.main()
   	/app/cmd/prometheus/main.go:618 +0x69d3 

参考 `prometheus: Unable to create mmap-ed active query log #21 <https://github.com/aws/eks-charts/issues/21>`_ 原因是 ``promethues`` 容器内部运行服务不是root身份，在目标服务器 ``i-0jl8d8r83kkf3yt5lzh7`` 启动pod后，初始化创建了 ``/home/t4/prometheus/data/prometheus-db`` 这个目录是 ``root`` 身份，所以后续容器内部进程无法写入该目录。

临时解决方法是登陆到目标服务器 ``i-0jl8d8r83kkf3yt5lzh7`` ，执行以下命令::

   sudo chmod 777 /home/t4/prometheus/data/prometheus-db

.. note::

   更好的解决方法是 ``initContainer`` ，具体待后续补充。 请参考 `Digitalocean kubernetes and volume permissions <https://faun.pub/digitalocean-kubernetes-and-volume-permissions-820f46598965>`_

   ``kube-prometheus-stack`` 应该也有解决方法，待补充

然后就可以看到正常运行起来了::

   # kubectl get pods -A -o wide | grep prometheus | grep -v node-exporter
   prometheus    alertmanager-kube-prometheus-stack-1681-alertmanager-0            2/2     Running             1          16m     10.233.127.15   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    kube-prometheus-stack-1681-operator-5b7f7cdc78-xqtm5              1/1     Running             0          16m     10.233.127.13   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    kube-prometheus-stack-1681228346-grafana-fb4695b7-2qhpp           3/3     Running             0          33h     10.233.127.3    i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    kube-prometheus-stack-1681228346-kube-state-metrics-89f44fm2qbb   1/1     Running             0          16m     10.233.127.14   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>
   prometheus    prometheus-kube-prometheus-stack-1681-prometheus-0                2/2     Running             0          16m     10.233.127.16   i-0jl8d8r83kkf3yt5lzh7   <none>           <none>


参考
======

- `Deploying kube-prometheus-stack with persistent storage on Kubernetes Cluster <https://blog.devops.dev/deploying-kube-prometheus-stack-with-persistent-storage-on-kubernetes-cluster-24473f4ea34f>`_ 这个持久化卷的配置方法不成功，但是持久化卷应用方法不通
- `[kube-prometheus-stack] how to use persistent volumes instead of emptyDir <https://github.com/prometheus-community/helm-charts/issues/2816>`_ 提供yaml配置定制helm安装
- `[prometheus-kube-stack] Grafana is not persistent #436 <https://github.com/prometheus-community/helm-charts/issues/436>`_ 提供了设置存储的案例，采用 StorageClass 会自动创建存储卷，不需要预先创建
