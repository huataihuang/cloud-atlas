.. _helm3_prometheus_grafana:

====================================================
使用Helm 3在Kubernetes集群部署Prometheus和Grafana
====================================================

Prometheus 社区提供了 `kube-prometheus-stack <https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack>`_ :ref:`helm` chart，一个完整的Kubernetes manifests，包含 :ref:`grafana` dashboard，以及结合了文档和脚本的 :ref:`prometheus_rules` 以方便通过 :ref:`prometheus_operator`

.. note::

   `kube-prometheus runbooks <https://runbooks.prometheus-operator.dev/>`_ 是社区提供的排查运行手册，非常适合学习案例以及排查问题参考

.. note::

   `SysEleven: Kube-Prometheus-Stack <https://docs.syseleven.de/metakube-accelerator/building-blocks/observability-monitoring/kube-prometheus-stack>`_ 提供了一个快速配置的精要手册，可以参考学习

helm3
=======

- :ref:`helm` 提供方便部署:

.. literalinclude:: ../../deploy/helm/helm_startup/helm_install_by_script
   :language: bash
   :caption: 使用官方脚本安装 helm

安装Prometheus 和 Grafana
===========================

- 添加 Prometheus 社区helm chart:

.. literalinclude:: helm3_prometheus_grafana/helm_repo_add_prometheus
   :language: bash
   :caption: 添加 Prometheus 社区helm chart

.. note::

   参考 :ref:`intergrate_gpu_telemetry_into_k8s` 可以看到NVIDIA文档中对 :ref:`helm` 部署社区 ``prometheus-community/kube-prometheus-stack`` 做了一些定制修改，方法值得参考。后续我部署会做一些改进，例如:

   - 传递 ``--namespace prometheus`` 指定部署到 ``prometheus`` 名字空间
   - 通过 ``--values /tmp/kube-prometheus-stack.values`` 添加定制的 ``additionalScrapeConfigs``

   不过，即使已经部署好的集群，也可以通过 :ref:`update_prometheus_config_k8s` 修订

- 安装:

.. literalinclude:: helm3_prometheus_grafana/helm_install_prometheus
   :language: bash
   :caption: 使用helm install安装prometheus

如果一切正常，最后会输出:

.. literalinclude:: helm3_prometheus_grafana/helm_install_prometheus_output
   :language: bash
   :caption: 使用helm install安装prometheus最后输出信息

- 检查:

.. literalinclude:: helm3_prometheus_grafana/get_prometheus_pods
   :language: bash
   :caption: 检查部署完成的Prometheus Pods

输出信息:

.. literalinclude:: helm3_prometheus_grafana/get_prometheus_pods_output
   :language: bash
   :caption: 检查部署完成的Prometheus Pods可以看到每个节点都运行了 ``node-exporter`` 且已经运行起 Prometheus和Grafana

排查和解决
============

实际上通过社区helm chart部署还是有一些困难的，这个困难不是社区的helm chart问题，而是GFW阻塞了镜像下载。

当你发现 ``helm list`` 显示 ``failed`` 时候，请使用 ``kubectl get pods XXXX -o yaml`` 检查错误原因，你可能会看到类似::

   ...
     containerStatuses:
     - image: registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6
       imageID: ""
       lastState: {}
       name: create
       ready: false
       restartCount: 0
       started: false
       state:
         waiting:
           message: Back-off pulling image "registry.k8s.io/ingress-nginx/kube-webhook-certgen:v20221220-controller-v1.5.1-58-g787ea74b6"
           reason: ImagePullBackOff

这种情况下，最好的解决方法是使用私有Registry: 通过翻墙将镜像 ``docker pull`` 下来，然后 ``docker push`` 到私有Registry中，然后修订 :ref:`helm` 部署的 ``deployments`` ，改成私有仓库镜像。

不过，还有一种方式(假如不方便使用Registry)，就是在墙外使用 :ref:`docker` ，然后在墙内将打包好的镜像搬运进来，再通过 :ref:`nerdctl` 的 ``nerdctl load -i`` 加载到集群节点来完成部署。

服务输出
===========

- 检查 ``svc`` :

.. literalinclude:: helm3_prometheus_grafana/get_svc
   :language: bash
   :caption: 检查部署完成的服务 ``kubectl get svc``

输出显示:

.. literalinclude:: helm3_prometheus_grafana/get_svc_output
   :language: bash
   :caption: ``kubectl get svc`` 输出显示当前服务都是使用Cluster IP，也就是无法直接外部访问

默认情况下， ``prometheus`` 和 ``grafana`` 服务都是使用ClusterIP在集群内部，所以要能够在外部访问，需要使用 :ref:`k8s_loadbalancer_ingress` 或者 ``NodePort`` (简单)

- 修改 ``stable-kube-prometheus-sta-prometheus`` 服务和 ``stable-grafana`` 服务，将 ``type`` 从 ``ClusterIP`` 修改为 ``NodePort`` 或者 ``LoadBalancer``

.. literalinclude:: helm3_prometheus_grafana/edit_svc
   :language: bash
   :caption: ``kubectl edit svc`` 将ClusterIP类型改为NodePort或LoadBalancer(案例是 ``grafana`` )

我在阿里云环境部署采用 ``LoadBalancer`` 似乎没有成功， ``kubectl get svc`` 一直显示外部IP ``pending`` ::

   NAME                                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
   ...
   stable-grafana                            LoadBalancer   10.233.19.177   <pending>     80:31365/TCP                 25h

所以我最终改为 ``NodePort`` 来绕过这个问题::

   NAME                                      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
   ...
   stable-grafana                            NodePort       10.233.19.177   <none>        80:31365/TCP                 25h
   stable-kube-prometheus-sta-alertmanager   NodePort       10.233.20.3     <none>        9093:32457/TCP               25h
   stable-kube-prometheus-sta-prometheus     NodePort       10.233.30.214   <none>        9090:30536/TCP               25h

此时在调度上述3个pod的物理主机上执行 ``netstat -an`` 可以看到对外监听的服务端口::

   tcp        0      0 0.0.0.0:31365           0.0.0.0:*               LISTEN
   ...
   tcp        0      0 0.0.0.0:32457           0.0.0.0:*               LISTEN
   ...
   tcp        0      0 0.0.0.0:30536           0.0.0.0:*               LISTEN

不过，这样外部访问的端口是随机的，有点麻烦。临时性解决方法，我采用 :ref:`nginx_reverse_proxy` 将对外端口固定住，然后反向转发给 ``NodePort`` 的随机端口，至少能临时使用。

.. note::

   我在采用 :ref:`nginx_reverse_proxy` 到Grafana时遇到 :ref:`grafana_behind_reverse_proxy` 问题，原因是Grafana新版本为了阻断跨站攻击，对客户端请求源和返回地址进行校验，所以必须对 :ref:`nginx` 设置代理头部

访问使用
==========

访问 Grafana 面板，初始账号 ``admin`` 密码是 ``prom-operator`` ，请立即修改

然后我们可以开始 :ref:`grafana_config_startup`

检查
=====

使用 :ref:`helm` 可以见擦好所有安装的对象:

.. literalinclude:: helm3_prometheus_grafana/helm_get_manifest
   :language: bash
   :caption: 获取 ``kube-prometheus-stack`` 安装的对象

输出类似:

.. literalinclude:: helm3_prometheus_grafana/helm_get_manifest_output
   :language: bash
   :caption: 获取 ``kube-prometheus-stack`` 安装的对象内容输出

参考
=======

- `How to Install Prometheus and Grafana on Kubernetes using Helm 3 <https://www.fosstechnix.com/install-prometheus-and-grafana-on-kubernetes-using-helm/>`_
- `Prometheus definitive guide part III – Prometheus operator <https://www.cncf.io/blog/2021/10/25/prometheus-definitive-guide-part-iii-prometheus-operator/>`_ 这篇非常详尽，特别是operator操作对象
