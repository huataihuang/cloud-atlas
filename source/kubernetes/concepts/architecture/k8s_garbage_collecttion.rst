.. _k8s_garbage_collecttion:

=========================
Kubernetes垃圾收集
=========================

.. note::

   我在测试 :ref:`kube-prometheus-stack_alert_config` 时，验证磁盘告警，向磁盘目录下填充数据，意外发现Kuberntes会自动将磁盘打爆(默认超过85%)的节点容器驱逐

垃圾收集（Garbage Collection）是 Kubernetes 用于清理集群资源的各种机制的统称。

垃圾收集允许系统清理如下资源:

- 终止状态的Pod: 在 Pod 个数超出所配置的阈值 （根据 kube-controller-manager 的 terminated-pod-gc-threshold 设置）时删除已终止的 Pod（阶段值为 Succeeded 或 Failed）。

  - 检查了集群部署 ``kube-controller-manager`` 运行参数 ``--terminated-pod-gc-threshold=12500`` ，也就是当集群出现超过 ``1.25w`` 的终止状态Pod就开始清理垃圾pods

- 已完成的Job: Kubernetes不会立即删除已经结束的Job，以方便用户判断Job成功还是失败

  - Kubernetes ``TTL-after-finished`` 控制器只支持Job清理，通过指定 Job 的 ``.spec.ttlSecondsAfterFinished`` 来 :ref:`clean_up_finished_jobs_automatically` ( ``Complete`` 或 ``Failed`` )

kubelet ``image-gc-high-threshold``
=====================================

根据 ``kubelet -h | grep image-gc-high-threshold`` 可以看到 ``image-gc-high-threshold`` 控制了镜像garbage回收::

   --image-gc-high-threshold int32

   The percent of disk usage after which image garbage collection is always run. Values must be within the range [0, 100],
   To disable image garbage collection, set to 100.  (default 85)
   (DEPRECATED: This parameter should be set via the config file specified by the Kubelet's --config flag.
   See https://kubernetes.io/docs/tasks/administer-cluster/kubelet-config-file/ for more information.)

这个参数可以在 ``kubelet`` 启动配置文件 ``/etc/kubernetes/kubelet.env`` 中设置 (见 ``/etc/systemd/system/kubelet.service`` )



参考
=======

- `Kubernetes 文档/概念/Kubernetes 架构/垃圾收集 <https://kubernetes.io/zh-cn/docs/concepts/architecture/garbage-collection/>`_
