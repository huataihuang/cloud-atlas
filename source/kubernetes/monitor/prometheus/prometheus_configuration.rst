.. _prometheus_configuration:

==========================
Prometheus配置(文件)
==========================

Prometheus使用配置文件有2个:

- ``prometheus.yaml`` : 主要配置文件，包含所有的 ``scrape`` 配置， ``service discovery`` 详情，存储位置，数据保留(data retention)配置等
- ``prometheus.rules`` : 包含所有告警规则

对于扩展 Prometheus配置到一个Kubernetes config map，不需要build Prometheus镜像(不管是添加或移除配置)；只需要更新 config map 然后重启Prometheus pods来使用新配置。

`Prometheus scrape config <https://raw.githubusercontent.com/bibinwilson/kubernetes-prometheus/master/config-map.yaml>`_ 是默认标准

在 :ref:`z-k8s_gpu_prometheus_grafana` 以及 :ref:`intergrate_gpu_telemetry_into_k8s` 采用了 ``intergrate_gpu_telemetry_into_k8s`` 在 :ref:`helm` 中添加了抓取任务，那么这个 ``config map`` 在哪里呢？

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/add_gpu-metrics_config
   :language: bash
   :caption: 在 ``configMap`` 配置 ``additionalScrapeConfigs`` 添加 ``gpu-metrics``
   :emphasize-lines: 19-21

可以看到 ``namespace`` 是 ``gpu-operator``

所以检查有哪些 CM

.. literalinclude:: prometheus_configuration/get_cm_gpu-operator
   :language: bash
   :caption: 获取 ``gpu-operator`` namesapce中的CM

输出内容:

.. literalinclude:: prometheus_configuration/get_cm_gpu-operator_output
   :language: bash
   :caption: 获取 ``gpu-operator`` namesapce中的CM输出项

从 Prometheus 的WEB管理界面，可以选择菜单 ``Status >> Configuration`` 看到 :ref:`z-k8s_gpu_prometheus_grafana` 和 :ref:`intergrate_gpu_telemetry_into_k8s` 增加的配置部分:

.. literalinclude:: prometheus_configuration/prometheus.yaml
   :language: yaml
   :caption: Prometheus 的配置文件 ``prometheus.yaml`` 增加了 ``gpu-metrics``

那么究竟改如何修订这个配置呢？

我发现，实际上 ``prometheus`` 这个 namespace 中，执行::

   kubectl -n prometheus get all

会看到::

   ...
   NAME                                                                    READY   AGE
   statefulset.apps/alertmanager-kube-prometheus-stack-1680-alertmanager   1/1     3d3h
   statefulset.apps/prometheus-kube-prometheus-stack-1680-prometheus       1/1     3d3h

也就是说 ``prometheus-kube-prometheus-stack-1680-prometheus`` 这个pods实际上是 ``statefulset`` ，所以检查如下::

   kubectl -n prometheus get statefulset prometheus-kube-prometheus-stack-1680-prometheus -o yaml

可以看到如下::

   ...
           volumeMounts:
           - mountPath: /etc/prometheus/config
             name: config
           - mountPath: /etc/prometheus/config_out
             name: config-out
           - mountPath: /etc/prometheus/rules/prometheus-kube-prometheus-stack-1680-prometheus-rulefiles-0
             name: prometheus-kube-prometheus-stack-1680-prometheus-rulefiles-0
         dnsPolicy: ClusterFirst
         initContainers:
         - args:
           - --watch-interval=0
           - --listen-address=:8080
           - --config-file=/etc/prometheus/config/prometheus.yaml.gz
           - --config-envsubst-file=/etc/prometheus/config_out/prometheus.env.yaml
           - --watched-dir=/etc/prometheus/rules/prometheus-kube-prometheus-stack-1680-prometheus-rulefiles-0
           command:
           - /bin/prometheus-config-reloader
   ...
           volumeMounts:
           - mountPath: /etc/prometheus/config
             name: config
           - mountPath: /etc/prometheus/config_out
             name: config-out
           - mountPath: /etc/prometheus/rules/prometheus-kube-prometheus-stack-1680-prometheus-rulefiles-0
             name: prometheus-kube-prometheus-stack-1680-prometheus-rulefiles-0
         restartPolicy: Always
   ,..
         volumes:
   ...
         - emptyDir:
             medium: Memory
           name: config-out
   ...

登陆到容器内部检查::

   kubectl exec -it prometheus-kube-prometheus-stack-1680-prometheus-0 -n prometheus -- /bin/sh

可以在容器内部 ``/etc/prometheus/config_out`` 目录下找到gpu配置文件 ``prometheus.env.yaml`` ，其中包含了 ``gpu-metrics`` ::

   - job_name: gpu-metrics
     kubernetes_sd_configs:
     - namespaces:
         names:
         - gpu-operator
       role: endpoints
     metrics_path: /metrics
     relabel_configs:
     - action: replace
       source_labels:
       - __meta_kubernetes_pod_node_name
       target_label: kubernetes_node
     scheme: http
     scrape_interval: 1s

那么，对于已经部署了 :ref:`dcgm-exporter` 的集群，该如何添加这段 ``prometheus.env.yaml`` 呢?

根据 ``prometheus-kube-prometheus-stack-1680-prometheus`` 这个 ``statefulset`` 配置yaml，可以看到卷挂载::

           - mountPath: /etc/prometheus/config_out
             name: config-out
   ...
         volumes:
   ...
         - emptyDir:
             medium: Memory
           name: config-out

奇怪，为何要使用 ``tmpfs`` 内存文件系统作为卷挂载呢？

登陆到 ``prometheus-kube-prometheus-stack-1680-prometheus`` 调度所在的节点 ``z-k8s-n-2`` ，确实::

   df -h | grep config-out

可以看到::

   tmpfs           7.6G   36K  7.6G   1% /var/lib/kubelet/pods/74ff8d0b-baa1-4cf3-b2f1-dcc2e47b6925/volumes/kubernetes.io~empty-dir/config-out

在这个 ``/var/lib/kubelet/pods/74ff8d0b-baa1-4cf3-b2f1-dcc2e47b6925/volumes/kubernetes.io~empty-dir/config-out`` 可以看到一个 ``prometheus.env.yaml``

参考
=====

- `How to Setup Prometheus Monitoring On Kubernetes Cluster <https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/>`_
