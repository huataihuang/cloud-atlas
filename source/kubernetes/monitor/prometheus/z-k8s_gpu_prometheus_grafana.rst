.. _z-k8s_gpu_prometheus_grafana:

=============================================================
在Kubernetes集群(z-k8s)部署集成GPU监控的Prometheus和Grafana
=============================================================

.. note::

   对于 :ref:`ovmf_gpu_nvme` 的 :ref:`gpu_k8s` 集群，本文综合了 :ref:`helm3_prometheus_grafana` 和 :ref:`intergrate_gpu_telemetry_into_k8s` 实现 :ref:`priv_cloud_infra` 的 Kubernetes 监控

Prometheus 社区提供了 `kube-prometheus-stack <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>`_ :ref:`helm` chart，一个完整的Kubernetes manifests，包含 :ref:`grafana` dashboard，以及结合了文档和脚本的 :ref:`prometheus_rules` 以方便通过 :ref:`prometheus_operator` 。不过，对于GPU节点的监控，建议在部署时做一些修订(见本文)可以方便一气呵成。当然，先完成 :ref:`helm3_prometheus_grafana` 再通过 :ref:`update_prometheus_config_k8s`
也可以。

helm3
=======

- :ref:`helm` 提供方便部署:

.. literalinclude:: ../../deploy/helm/helm_startup/helm_install_by_script
   :language: bash
   :caption: 使用官方脚本安装 helm

:ref:`install_nvidia_gpu_operator`
===================================

这段待整理

安装Prometheus 和 Grafana
===========================

- 添加 Prometheus 社区helm chart:

.. literalinclude:: helm3_prometheus_grafana/helm_repo_add_prometheus
   :language: bash
   :caption: 添加 Prometheus 社区helm chart

- NVIDIA对社区方案参数做一些调整，所以先导出 chart 使用的变量(以便修订):

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/helm_inspect_values_prometheus-stack
   :language: bash
   :caption: ``helm inspect values`` 输出Prometheus Stack的chart变量值

- 修订一: 将metrics端口 ``30090`` 作为 ``NodePort`` 输出在每个节点(实际只需要修改 ``type: ClusterIP`` 改为 ``type: NodePort`` 行，建议同时修改 ``stable-grafana`` (没有找到所以未修改，似乎是 Prometheus operator service, 30080), ``alertmanager`` (9093/30903) 和 ``prometheus`` (9090/30090) 对应的 ``svc`` ，这里案例仅演示 ``prometheus`` 段落修改):

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/change_prometheus_nodeport_30090
   :language: bash
   :caption: 修订输出端口30090
   :emphasize-lines: 27

其他修订::

   defaultDashboardsTimezone: Asia/Shanghai

- 修订二: 修改 ``prometheusSpec.serviceMonitorSelectorNilUsesHelmValues`` 设置为 ``false`` :

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/change_value
   :language: bash
   :caption: 修改 ``prometheusSpec.serviceMonitorSelectorNilUsesHelmValues`` 设置为 ``false``

- 修改三: 在 ``configMap`` 配置 ``additionalScrapeConfigs`` 添加 ``gpu-metrics`` :

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/add_gpu-metrics_config
   :language: bash
   :caption: 在 ``configMap`` 配置 ``additionalScrapeConfigs`` 添加 ``gpu-metrics``

- 执行部署，部署中采用自己定制的values:

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/deploy_prometheus-stack
   :language: bash
   :caption: 使用定制helm chart values来安装部署 ``kube-prometheus-stack``

输出信息:

.. literalinclude:: ../../gpu/intergrate_gpu_telemetry_into_k8s/deploy_prometheus-stack_output
   :language: bash
   :caption: 使用定制helm chart values来安装部署 ``kube-prometheus-stack`` 输出信息

.. note::

   在生产集群部署，遇到过如下报错::

      Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: error validating "": error validating data: ValidationError(ServiceMonitor.spec.endpoints[0]): unknown field "enableHttp2" in com.coreos.monitoring.v1.ServiceMonitor.spec.endpoints

   参考 `prometheus-kube-stack helm install results in unknown field "enableHttp2" #2633 <https://github.com/prometheus-community/helm-charts/issues/2633>`_ 情况类似::

      Found same error upgrading from old Prometheus installation.
      Solution: uninstall prometheus, delete CRDs and install again.
      https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack#uninstall-helm-chart

   原因是我之前的一次安装 ``prometheus-stack`` 安装，中途按下了 ``ctrl-c`` ，然后执行了一次 ``helm uninstall stack`` 来卸载。但是根据文档，CRD是不会自动清理掉，这可能导致了冲突。需要手工清理相关监控的CRD::

      kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
      kubectl delete crd alertmanagers.monitoring.coreos.com
      kubectl delete crd podmonitors.monitoring.coreos.com
      kubectl delete crd probes.monitoring.coreos.com
      kubectl delete crd prometheuses.monitoring.coreos.com
      kubectl delete crd prometheusrules.monitoring.coreos.com
      kubectl delete crd servicemonitors.monitoring.coreos.com
      kubectl delete crd thanosrulers.monitoring.coreos.com

.. note::

   如果已经部署好 ``prometheus-stack`` ，需要添加 :ref:`dcgm-exporter` 数据采集支持，则可以通过 :ref:`update_prometheus_config_k8s` 修订

- 检查 ``prometheus`` namespace中部署的容器:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/check_prometheus-stack_deploy_pods
   :language: bash
   :caption: 检查 ``kube-prometheus-stack`` 部署容器

输出显示类似如下:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/check_prometheus-stack_deploy_pods_output
   :language: bash
   :caption: 检查 ``kube-prometheus-stack`` 部署容器输出显示

检查部署完成的Prometheus Pods可以看到每个节点都运行了 ``node-exporter`` 且已经运行起 Prometheus和Grafana(注意，位于 ``prometheus`` namespace)

.. note::

   如果有遇到镜像无法下载问题，请参考 :ref:`helm3_prometheus_grafana` 我的实践经验

服务输出
===========

- 检查 ``svc`` :

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_svc
   :language: bash
   :caption: 检查部署完成的服务 ``kubectl get svc``

输出显示:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_svc_output
   :language: bash
   :caption: ``kubectl get svc`` 输出显示当前grafana服务还是ClusterIP，需要修订
   :emphasize-lines: 3,5

默认情况下， ``prometheus`` 和 ``grafana`` 服务都是使用ClusterIP在集群内部，所以要能够在外部访问，需要使用 :ref:`k8s_loadbalancer_ingress` 或者 ``NodePort`` (简单) 。上文我采用了NVIDIA官方部署文档方法，将 ``alertmanager`` 和 ``prometheus`` 修订成了 ``NodePort`` 模式，但是没有修订 ``grafana`` ，所以下面我再手工修订 ``grafana`` 设置为 ``NodePort`` 模式

- 修改 ``stable-grafana`` 服务，将 ``type`` 从 ``ClusterIP`` 修改为 ``NodePort`` 或者 ``LoadBalancer``

.. literalinclude:: z-k8s_gpu_prometheus_grafana/edit_svc
   :language: bash
   :caption: ``kubectl edit svc`` 将ClusterIP类型改为NodePort

最终检查 ``svc`` 如下:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_svc_output_changed
   :language: bash
   :caption: ``kubectl get svc`` 输出显示NodePort类型就是在运行服务节点对外提供服务
   :emphasize-lines: 3,5,6

不过，这样外部访问的端口是随机的，有点麻烦。临时性解决方法，我采用 :ref:`nginx_reverse_proxy` 将对外端口固定住，然后反向转发给 ``NodePort`` 的随机端口，至少能临时使用。

.. note::

   我在采用 :ref:`nginx_reverse_proxy` 到Grafana时遇到 :ref:`grafana_behind_reverse_proxy` 问题，原因是Grafana新版本为了阻断跨站攻击，对客户端请求源和返回地址进行校验，所以必须对 :ref:`nginx` 设置代理头部

访问使用
==========

访问 Grafana 面板，初始账号 ``admin`` 密码是 ``prom-operator`` ，请立即修改

然后我们可以开始 :ref:`grafana_config_startup`

参考
=======

- `How to Install Prometheus and Grafana on Kubernetes using Helm 3 <https://www.fosstechnix.com/install-prometheus-and-grafana-on-kubernetes-using-helm/>`_
