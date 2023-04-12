.. _update_prometheus_config_k8s:

====================================
更新Kubernetes集群的Prometheus配置
====================================

.. note::

   在 :ref:`helm3_prometheus_grafana` 中部署 :ref:`dcgm-exporter` 管理GPU监控，需要修订Prometheus配置来抓取特定节点和端口metrics，需要修订Prometheus配置。

对于采用Prometheus Operator(例如 :ref:`helm3_prometheus_grafana` 就是采用 `kube-prometheus-stack <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>`_ :ref:`helm` chart完成部署)构建Prometheus监控堆栈之后，可以通过设置附加的scrape配置来监控自己的自定义服务。

所谓的附加的scrape配置(additional scrape config)就是使用 **正则表达式** 来找寻匹配的服务，并根据 标签( ``label`` ), 注释( ``annotation`` )，命名空间( ``namespace`` )或命名( ``name`` )来定位一组服务。

附加的scrape配置(additional scrape config)是一项功能强大的底层操作，需要在 :ref:`helm` chart values的 ``prometheusSpec`` 部分 或者 Prometheus配置文件 中指定。所以非常适合实现一个平台界别的监控极致，而且可以控制Prometheus的安装和配置设置。

.. note::

   本文实践是在我的 :ref:`helm3_prometheus_grafana` 基础上完成，目标是 :ref:`intergrate_gpu_telemetry_into_k8s`

在 :ref:`helm3_prometheus_grafana` 没有包含 :ref:`intergrate_gpu_telemetry_into_k8s` 针对GPU监控所需的 ``additionalScrapeConfigs`` 所以 ``prometheus`` 此时无法抓取 ``9400`` 端口的GPU metrics 。以下是 :ref:`intergrate_gpu_telemetry_into_k8s` 所要求的 ``configMap`` :

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/add_gpu-metrics_config
   :language: bash
   :caption: 在 ``configMap`` 配置 ``additionalScrapeConfigs`` 添加 ``gpu-metrics``

- 获取当前 Prometheus ``helm`` :

.. literalinclude:: update_prometheus_config_k8s/helm_list_prometheus
   :language: bash
   :caption: 获取当前已经安装的prometheus helm

输出信息:

.. literalinclude:: update_prometheus_config_k8s/helm_list_prometheus_output
   :language: bash
   :caption: 获取当前已经安装的prometheus helm 输出信息

``dcgm-exporter`` 部署情况
==============================

参考 `how prometheus get dcgm-exporter metrics? #106 <https://github.com/NVIDIA/gpu-monitoring-tools/issues/106>`_ 对 ``dcgm-exporter`` 进行剖析:

- Namespace
- DaemonSet
- Service
- ServiceMonitor
- ServiceAccount

- 观察 :ref:`intergrate_gpu_telemetry_into_k8s` 部署的 ``service`` ，其中有 ``dcgm-exporter-1680364448`` ，检查内容::

   kubectl get svc dcgm-exporter-1680364448 -o yaml

输出 ``dcgm-exporter`` service配置:

.. literalinclude:: update_prometheus_config_k8s/dcgm-exporter_service.yaml
   :language: yaml
   :caption: ``kubectl get svc dcgm-exporter -o yaml`` 输出

- 观察 ``dcgm-exporter`` daemonset配置::

   kubectl get ds dcgm-exporter-1680364448 -o yaml

.. literalinclude:: update_prometheus_config_k8s/dcgm-exporter_ds.yaml
   :language: yaml
   :caption: ``kubectl get ds dcgm-exporter -o yaml`` 输出

更新 ``helm`` 部署
=====================

- 参考 :ref:`intergrate_gpu_telemetry_into_k8s` 方法，将 ``prometheus-community/kube-prometheus-stack`` chart的values导出:

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/helm_inspect_values_prometheus-stack
   :language: bash
   :caption: ``helm inspect values`` 输出Prometheus Stack的chart变量值

- 在 ``configMap`` 配置 ``additionalScrapeConfigs`` 添加 ``gpu-metrics`` :

.. literalinclude:: update_prometheus_config_k8s/add_gpu-metrics_config
   :language: bash
   :caption: 在 ``configMap`` 配置 ``additionalScrapeConfigs`` 添加 ``gpu-metrics`` (namespace由于部署原因设为default)
   :emphasize-lines: 21

- 更新:

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

我这里遇到一个报错，是因为我忘记我已经在 :ref:`helm3_prometheus_grafana` 步骤中修订了 prometheus / grafana 等 service，已经将 ``ClusterIP`` 修订为 ``NodePort`` ，所以提示错误(忽略)::

   Error: UPGRADE FAILED: cannot patch "stable-grafana" with kind Service: Service "stable-grafana" is invalid: spec.ports[0].nodePort: Forbidden: may not be used when `type` is 'ClusterIP' && cannot patch "stable-kube-prometheus-sta-alertmanager" with kind Service: Service "stable-kube-prometheus-sta-alertmanager" is invalid: spec.ports[0].nodePort: Forbidden: may not be used when `type` is 'ClusterIP' && cannot patch "stable-kube-prometheus-sta-prometheus" with kind Service:
   Service "stable-kube-prometheus-sta-prometheus" is invalid: spec.ports[0].nodePort: Forbidden: may not be used when `type` is 'ClusterIP'

.. note::

   更新helm需要2个参数: ``[RELEASE] [CHART]`` ，否则会报错::

      Error: "helm upgrade" requires 2 arguments

      Usage:  helm upgrade [RELEASE] [CHART] [flags]

   不过，比较反直觉，这里 ``[RELEASE]`` 需要使用 ``helm list`` 的 ``NAME`` ，而 ``[CHART]`` 则使用 ``repo_name/path_to_chart`` 格式，使用 ``prometheus-community/kube-prometheus-stack`` ，但不是 ``prometheus-community/kube-prometheus-stack-45.9.1``

.. note::

   ``helm upgrade`` 会再次拉取软件包，例如 ``Get "https://github.com/prometheus-community/helm-charts/releases/download/kube-prometheus-stack-45.9.1/kube-prometheus-stack-45.9.1.tgz"`` ，所以这个方法很沉重。我后续会找更好的更新方法

执行完成后，就可以在 :ref:`grafana` 面板看到GPU数据已经采集

问题
------

- 对于主机采用了复杂的网络接口(多个网口)， 上述抓取获得的主机实例IP地址可能不是想要的接口IP

参考
=====

- `Prometheus: monitoring services using additional scrape config for Prometheus Operator <https://fabianlee.org/2022/07/08/prometheus-monitoring-services-using-additional-scrape-config-for-prometheus-operator/>`_ 主要参考
- `How to update Prometheus config in k8s cluster <https://stackoverflow.com/questions/53227819/how-to-update-prometheus-config-in-k8s-cluster>`_
- `Prometheus, ConfigMaps and Continuous Deployment <https://www.weave.works/blog/prometheus-configmaps-continuous-deployment/>`_
- `Different Prometheus scrape URL for every target <https://stackoverflow.com/questions/44927130/different-prometheus-scrape-url-for-every-target>`_
