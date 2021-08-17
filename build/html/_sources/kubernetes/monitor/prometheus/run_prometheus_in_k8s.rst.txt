.. _run_prometheus_in_k8s:

========================================
在Kubernetes中安装运行Prometheus
========================================

.. note::

    本文通过手工配置步骤，一步步在Kubernetes集群运行Prometheus进行集群监控，配合 :ref:`run_grafana_in_k8s` 可以实现Kubernetes集群常规监控和故障分析。后续再通过 :ref:`helm3_prometheus_grafana` 实现自动化部署整套监控系统。

Prometheus提供了官方docker hub的 `Prometheus docker image <https://hub.docker.com/r/prom/prometheus/>`_ ，可以用来安装。

Prometheus Kubernetes Manifest文件
=====================================

- 从 `bibinwilson/kubernetes-prometheus <https://github.com/bibinwilson/kubernetes-prometheus>`_ 下载帮助我们安装的配置文件::

   git clone https://github.com/bibinwilson/kubernetes-prometheus

创建Namespace和ClusterRole
=============================

- 首先创建一个用于所有监控组件的Kubernetes namespce，这样可以避免Prometheus Kubernetes部署对象被部署到默认namespace::

   kubectl create namespace monitoring

Prometheus使用Kubernetes API来获取节点、Pods、Deployments等的所有提供的metrics，所以需要创建一个 ``read access`` 的RBAC策略绑定到 ``monitoring`` namespace。

- 创建一个 ``clusterRole.yaml`` :

.. literalinclude:: run_prometheus_in_k8s/clusterRole.yaml
    :language: bash
    :linenos:
    :caption:

在权限中添加了 ``verbs: ["get", "list", "watch"]`` 提供了节点、服务、pods和ingress的对应权限，然后绑定到 ``monitoring`` namespace。

- 使用如下命令创建角色::

   kubectl create -f clusterRole.yaml

提示成功::

   clusterrole.rbac.authorization.k8s.io/prometheus created
   clusterrolebinding.rbac.authorization.k8s.io/prometheus created

创建Config Map来输出Prometheus配置
=======================================

- 配置文件:

  - ``prometheus.yaml`` 处理所有配置，服务发现，存储以及数据保留等有关Prometheus的配置
  - ``prometheus.rules`` 包含所有Prometheus告警规则

通过将Prometheus配置暴露给Kubernetes Config Map，就不需要在添加和删除配置时重建Prometheus镜像，你只需要更新config map并重启Prometheus Pod就可以使配置生效。

在 ``config-map.yaml`` 配置中包含了上述两个配置文件:

.. literalinclude:: run_prometheus_in_k8s/config-map.yaml
    :language: bash
    :linenos:
    :caption:

- scrape配置解析

  - ``kubernetes-apiservers`` 从API服务器获取所有metrics
  - ``kubernetes-nodes`` 搜集所有kubernetes node metrics
  - ``kubernetes-pods`` 如果pod的metadata通过 ``prometheus.io/scrape`` 和 ``prometheus.io/port`` 声明就采集
  - ``kubernetes-cadvisor`` 采集所有cAdvisor metrics
  - ``kubernetes-service-endpoints`` 如果service的pod的metadata通过 ``prometheus.io/scrape`` 和 ``prometheus.io/port`` 声明就采集

- ``prometheus.rules`` 包含所有发送告警规则

- 现在执行以下命令创建Config Map::

   kubectl create -f config-map.yaml

创建Prometheus Deployment
=============================

- 创建 ``prometheus-deployment.yaml`` :

.. literalinclude:: run_prometheus_in_k8s/prometheus-deployment.yaml
    :language: bash
    :linenos:
    :caption:

.. warning::

   这里没有设置 :ref:`k8s_persistent_volumes` 后续完善，生产环境已经要持久化存储

.. note::

   需要注意，我的实践环境是在 :ref:`arm_k8s_deploy` ，所以需要采用 ARM 版本prometheus镜像 ``prom/prometheus-linux-arm64`` ，如果是 x86 架构，则直接使用 ``prom/prometheus``

   pod的deployment中必须配置 ``nodeSelector`` ::

      spec:
      containers:
        - name: prometheus
          #image: prom/prometheus
          image: prom/prometheus-linux-arm64
          ...
      nodeSelector:
        kubernetes.io/arch: arm64

   如果你使用常规的x86环境，请将上述配置修订成::

      spec:
      containers:
        - name: prometheus
          image: prom/prometheus
          #image: prom/prometheus-linux-arm64
          ...
      #nodeSelector:
      #  kubernetes.io/arch: arm64

- 创建部署::

   kubectl create  -f prometheus-deployment.yaml

参考
===========

- `How to Setup Prometheus Monitoring On Kubernetes Cluster <https://devopscube.com/setup-prometheus-monitoring-on-kubernetes/>`_
- `Installing Prometheus on the Raspberry Pi <https://pimylifeup.com/raspberry-pi-prometheus/>`_
- `Monitoring – How to install Prometheus/Grafana on arm – Raspberry PI/Rock64 <https://www.mytinydc.com/en/blog/prometheus-grafana-installation/>`_