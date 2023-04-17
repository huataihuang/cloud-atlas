.. _kube-prometheus-stack_etcd:

====================================
``kube-prometheus-stack`` 监控etcd
====================================

默认部署好 ``kube-prometheus-stack`` ，如果Kubernetes集群采用了外部 :ref:`etcd` (例如: :ref:`deploy_etcd_cluster_with_tls_auth` )，那么 :ref:`grafana` 中显示 :ref:`etcd` 的内容是空白的。此时需要定制 ``values`` 并通过 :ref:`update_prometheus_config_k8s` 提交etcd相关配置(包括证书)，这样才能对 ``etcd`` 完整监控。
