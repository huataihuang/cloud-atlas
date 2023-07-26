.. _y-k8s_gpu_prometheus_grafana:

=============================================================
在Kubernetes集群(y-k8s)部署集成GPU监控的Prometheus和Grafana
=============================================================

.. note::

   对于 :ref:`ovmf_gpu_nvme` 的 :ref:`gpu_k8s` 集群，本文综合了 :ref:`helm3_prometheus_grafana` 和 :ref:`intergrate_gpu_telemetry_into_k8s` 实现 :ref:`priv_cloud_infra` 的 Kubernetes 监控

Prometheus 社区提供了 `kube-prometheus-stack <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>`_ :ref:`helm` chart，一个完整的Kubernetes manifests，包含 :ref:`grafana` dashboard，以及结合了文档和脚本的 :ref:`prometheus_rules` 以方便通过 :ref:`prometheus_operator` 。不过，对于GPU节点的监控，建议在部署时做一些修订(见本文)可以方便一气呵成。当然，先完成 :ref:`helm3_prometheus_grafana` 再通过 :ref:`update_prometheus_config_k8s` 也可以。

.. note::

   ``y-k8s`` 集群部署是在 ``z-k8s`` 集群部署的经验之上迭代改进，所以我尝试构建一个更为合理更为接近云计算生产环境的 :ref:`gpu_k8s` :

   - 集群部署采用 :ref:`kubespray` ，网络基于 :ref:`calico`
   - 集成 :ref:`istio` 来实现Service Mesh
   - 采用标准的 :ref:`metallb` 实现负载均衡

   所以在部署上会结合很多复杂方案，并非一蹴而就

helm3
=======

- :ref:`helm` 提供方便部署:

.. literalinclude:: ../../deploy/helm/helm_startup/helm_install_by_script
   :language: bash
   :caption: 使用官方脚本安装 helm

:ref:`install_nvidia_gpu_operator`
===================================

``y-k8s`` 集群和 ``z-k8s`` 集群的差异之一就是采用了 :ref:`vgpu` 来模拟多GPU的 :ref:`gpu_k8s` ，同样也可以通过 :ref:`install_nvidia_gpu_operator` 来快速完成集群的GPU支持升级: :ref:`y-k8s_nvidia_gpu_operator`

安装Prometheus 和 Grafana
===========================

helm配置
---------

- 添加 Prometheus 社区helm chart:

.. literalinclude:: helm3_prometheus_grafana/helm_repo_add_prometheus
   :language: bash
   :caption: 添加 Prometheus 社区helm chart

- NVIDIA对社区方案参数做一些调整，所以先导出 chart 使用的变量(以便修订):

.. literalinclude:: z-k8s_gpu_prometheus_grafana/values.yaml
   :language: bash
   :caption: ``helm inspect values`` 输出Prometheus Stack的chart变量值

- 修订一: 将metrics端口 ``30090`` 作为 ``NodePort`` 输出在每个节点(实际只需要修改 ``type: ClusterIP`` 改为 ``type: NodePort`` 行，建议同时修改 ``stable-grafana`` ( ``helm install`` 时支持传递参数 ``--set grafana.service.type=NodePort`` ，通过增加 ``nodePort`` 指定 80/30080映射), ``alertmanager`` (9093/30903) 和 ``prometheus`` (9090/30090) 对应的 ``svc`` ):

.. literalinclude:: z-k8s_gpu_prometheus_grafana/values.yaml
   :language: bash
   :caption: 修订服务类型NodePort
   :emphasize-lines: 38,48,49,82

.. note::

   我最初在 ``kube-prometheus-stack.values`` 没有找到修订 ``grafana`` 的 ``service.type`` 的地方，后来找到可以通过 传递参数 ``--set grafana.service.type=NodePort`` 实现，再仔细看了 ``values`` ，原来默认没有配置，所以需要自己手工添加

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

.. note::

   - :ref:`prometheus_configuration`

   - :ref:`prometheus_operator`

准备存储
---------

- 创建 :ref:`k8s_hostpath` 持久化存储卷:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/kube-prometheus-stack-pv.yaml
   :language: yaml
   :caption: ``kube-prometheus-stack-pv.yaml`` 创建 :ref:`k8s_hostpath` 持久化存储卷

.. note::

   只需要创建 PV 就可以， ``kube-prometheus-stack`` values.yaml 中提供了 PVC 配置，会自动创建PVC

- 执行:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/kube-prometheus-stack-pv_apply
   :language: bash
   :caption: 执行构建 ``kube-prometheus-stack-pv``

部署
------

- 执行部署，部署中采用自己定制的values:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/deploy_prometheus-stack
   :language: bash
   :caption: 使用定制helm chart values来安装部署 ``kube-prometheus-stack`` (传递定制存储参数没有成功，实际正确方法应该采用 :ref:`kube-prometheus-stack_persistent_volume` )
   :emphasize-lines: 5

.. note::

   持久化存储解决方案采用 :ref:`kube-prometheus-stack_persistent_volume` 验证通过

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

   在生产集群部署，遇到调度失败::

      kubectl --namespace prometheus get pods kube-prometheus-stack-1680962838-prometheus-node-exporter-5kk5q -o yaml

   ::

      ...
      status:
        conditions:
        - lastProbeTime: null
          lastTransitionTime: "2023-04-08T14:07:36Z"
          message: '0/12 nodes are available: 12 node(s) didn''t have free ports for the
            requested pod ports.'
          reason: Unschedulable 

   原因是Kubernetes集群在阿里云平台部署，已经购买了阿里云的 ``Prometheus`` 监控，所以集群已经提前部署了 ``node-exporter`` ，导致端口中途。解决方法是修订上文自定义values文件 ``kube-prometheus-stack.values`` ::

      ...
      ## Deploy node exporter as a daemonset to all nodes
      ##
      nodeExporter:
        enabled: false
     
   然后重新部署。(不过实践发现还是存在其他问题，遂放弃)

.. note::

   如果已经部署好 ``prometheus-stack`` ，需要添加 :ref:`dcgm-exporter` 数据采集支持，则可以通过 :ref:`update_prometheus_config_k8s` 修订

.. note::

   在墙内部署会遇到镜像下载问题，通过镜像导入目标节点::

      #下载
      docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
      docker pull registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.8.2

      #导出
      docker save -o kube-webhook-certgen.tar registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
      docker save -o kube-state-metrics.tar registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.8.2

      #导入
      nerdctl -n k8s.io load < /tmp/kube-webhook-certgen.tar
      nerdctl -n k8s.io load < /tmp/kube-state-metrics.tar

- 对于需要部署到指定监控服务器，可以采用 ``label`` 方法::

   kubectl label nodes i-0jl8d8r83kkf3yt5lzh7 telemetry=prometheus

依次修订 ``deployments`` ，例如 ``kubectl edit deployment stable-grafana`` ::

       spec:
         nodeSelector:
           telemetry: prometheus
         containers:
         ...

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

端口转发
============

.. note::

   我在上次实践 :ref:`intergrate_gpu_telemetry_into_k8s` 采用 :ref:`nginx_reverse_proxy` 到Grafana，遇到过 :ref:`grafana_behind_reverse_proxy` 问题，原因是Grafana新版本为了阻断跨站攻击，对客户端请求源和返回地址进行校验，所以必须对 :ref:`nginx` 设置代理头部

   另外可以采用 :ref:`apache_reverse_proxy` 来实现反向代理(因为我已经采用了 :ref:`apache_webdav` 实现 :ref:`joplin_sync_webdav` )

在通过 ``NodePort`` 输出 Prometheus/Grafana/Altermanager 时，pod容器可以在集群的任何node节点运行。对于外部访问，比较好的方式是采用 :ref:`metallb` 结合 :ref:`ingress` 来实现完整的云计算网络。

不过，出于快速构建，我当前采用简化的服务输出方式 ``NodePort`` ，所以再部署一个 :strike:`简单的WEB反向代理就能在外部访问` :ref:`iptables_port_forwarding` 实现访问。

- 检查 ``prometheus-stack`` 输出的 ``NodePort`` :

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_svc_nodeport
   :language: bash
   :caption: 检查服务的 ``NodePort``

输出显示:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_svc_nodeport_output
   :language: bash
   :caption: 检查服务的 ``NodePort`` 输出

- 检查 ``prometheus-stack`` 对应pods落在哪个 ``nodes`` 上:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_pods_nodes
   :language: bash
   :caption: 检查prometheus的服务对应 ``pods`` 落在哪个 ``nodes`` 上

输出显示

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_pods_nodes_output
   :language: bash
   :caption: 检查prometheus的服务对应 ``pods`` 落在哪个 ``nodes`` (对应3个NODE)
   :emphasize-lines: 2,4,8

- 检查 ``nodes`` 对应IP:

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_nodes_ip
   :language: bash
   :caption: 检查 ``nodes`` 对应 IP

.. literalinclude:: z-k8s_gpu_prometheus_grafana/get_nodes_ip_output
   :language: bash
   :caption: 检查 ``nodes`` 对应 IP
   :emphasize-lines: 5-7

整理对应关系:

.. csv-table:: ``prometheus-stack`` 服务 ``NodePort`` 对应关系
   :file: z-k8s_gpu_prometheus_grafana/prometheus-stack_nodeport.csv
   :widths: 20,30,10,30,10
   :header-rows: 1

- 执行以下端口转发脚本:

.. literalinclude:: ../../../linux/network/iptables/iptables_port_forwarding/iptables_port_forwarding_prometheus
   :language: bash
   :caption: 端口转发 ``prometheus-stack`` 服务端口

配置修订
=============

对于需要后续调整的配置，采用 :ref:`update_prometheus_config_k8s` 方法:

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

例如更新 ``scrape`` 配置

持久化存储
============

默认配置:

.. literalinclude:: update_prometheus_config_k8s/prometheus_default_storage.yaml
   :language: yaml
   :caption: 默认 prometheus 存储在内存

我最初按照上文 `Deploying kube-prometheus-stack with persistent storage on Kubernetes Cluster <https://blog.devops.dev/deploying-kube-prometheus-stack-with-persistent-storage-on-kubernetes-cluster-24473f4ea34f>`_ 构建了存储PV/PVC，但是采用了 ``helm install`` 参数 ``

访问使用
==========

访问 Grafana 面板，初始账号 ``admin`` 密码是 ``prom-operator`` ，请立即修改

然后我们可以开始 :ref:`grafana_config_startup`

- :ref:`intergrate_gpu_telemetry_into_k8s` 采用 NVIDIA官方提供的面板 `NVIDIA DCGM Exporter Dashboard <https://grafana.com/grafana/dashboards/12239-nvidia-dcgm-exporter-dashboard/>`_ ，可以直接导入监控我的 :ref:`tesla_p10`

:ref:`k8s_ingress` 改进
========================

我最初为了方便快速，采用了 ``NodePort`` 输出服务，所以简单部署了 :ref:`grafana_behind_reverse_proxy` ，后续尝试改进成 :ref:`k8s_ingress` 模式

参考
=======

- `How to Install Prometheus and Grafana on Kubernetes using Helm 3 <https://www.fosstechnix.com/install-prometheus-and-grafana-on-kubernetes-using-helm/>`_
- `Deploying kube-prometheus-stack with persistent storage on Kubernetes Cluster <https://blog.devops.dev/deploying-kube-prometheus-stack-with-persistent-storage-on-kubernetes-cluster-24473f4ea34f>`_ 这个持久化卷的配置方法不成功，但是持久化卷应用方法不通过。参考 `[kube-prometheus-stack] how to use persistent volumes instead of emptyDir <https://github.com/prometheus-community/helm-charts/issues/2816>`_
