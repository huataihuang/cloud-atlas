.. _prometheus:

======================
Prometheus监控
======================

监控是自动化运维的重要组成，没有监控，对于海量服务器的集群运维，就如同盲人摸象。

.. toctree::
   :maxdepth: 1

   introduce_prometheus.rst
   prometheus_startup.rst
   node_exporter.rst
   run_prometheus_in_k8s.rst
   run_prometheus_in_k8s_arm.rst
   k8s_kube_state_metircs.rst
   helm3_prometheus_grafana.rst
   update_prometheus_config_k8s.rst
   prometheus_configuration.rst
   promql/index
   prometheus_rules/index
   prometheus_service_discovery.rst
   kube-prometheus-stack_additionalScrapeConfigs.rst
   kube-prometheus-stack_scrape_node_metrics.rst
   prometheus_operator.rst
   prometheus_metrics_connect_refuse.rst
   prometheus_metrics_context_deadline_exceeded.rst
   prometheus_monitor_kubelet_controller-manager_scheduler.rst
   using_prometheus.rst
   z-k8s_gpu_prometheus_grafana.rst
   kube-prometheus-stack_persistent_volume.rst
   kube-prometheus-stack_persistent_volume_grafana_debug.rst
   kube-prometheus-stack_persistent_nodeselector.rst
   kube-prometheus-stack_tsdb_retention.rst
   kube-prometheus-stack_hostnetwork.rst
   kube-prometheus-stack_etcd.rst
   kube-prometheus-stack_etcd_http.rst
   kube-prometheus-stack_extraargs.rst
   monitor_etcd_with_prometheus_operator.rst
   kube-prometheus-stack_longhorn.rst
   aliyun_prometheus.rst
   prometheus_backup_and_restore.rst
   grafana_backup_and_restore.rst
   prometheus_monitor_calico.rst
   scalable/index

推荐阅读:

- `Prometheus操作指南 <https://github.com/yunlzheng/prometheus-book>`_ 这是阿里巴巴的yunlzheng撰写的Prometheus手册，非常完备，在github上有3k的star，特别是集成钉钉的webhook，可以解决国内用户的通知痛点
- `OReilly - Prometheus Up & Running <https://www.amazon.cn/dp/1492034142/ref=sr_1_1?__mk_zh_CN=亚马逊网站&keywords=Prometheus+Up+%26+Running&qid=1561039024&s=gateway&sr=8-1>`_ 本章节将根据自己学习这本书的实践来撰写
- 中文书籍在亚马逊上有一个 `深入浅出Prometheus：原理、应用、源码与拓展详解 <https://www.amazon.cn/dp/B07QVZ346C/ref=tmm_kin_swatch_0?_encoding=UTF8&qid=1561039024&sr=8-2>`_ 不过我还没有读过
- `YouTube上Prometheus Monitoring官方视频 <https://www.youtube.com/channel/UC4pLFely0-Odea4B2NL1nWA>`_
