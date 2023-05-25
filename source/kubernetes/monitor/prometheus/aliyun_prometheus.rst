.. _aliyun_prometheus:

=========================
阿里云Prometheus监控产品
=========================

阿里云为用户提供了基于开源 :ref:`prometheus` 和 :ref:`grafana` 构建的 `阿里云实时监控服务ARMS <https://help.aliyun.com/product/34364.html?spm=a2c4g.443952.0.0.2c547cd5MDv7oZ>`_ 监控产品。其主要产品 ``Prometheus监控`` / ``Grafana服务`` 是基于开源软件构建:

- 定制了开箱即用的Grafana面板
- 提供WEB页面一键安装Prometheus全家桶(其实就是类似社区的 :ref:`helm3_prometheus_grafana` 不过把所有步骤都集成起来提供了一个页面导引 )
- 解决了大陆用户(是的，很不幸就是我们)无法正常访问github仓库/google仓库的安装问题(这是开源社区 ``prometheus-stack`` 安装的最大障碍)
- 集成了日志服务 SLS 和 云监控 CMS插件

  - 这个功能实际上可以采用社区的 :ref:`thanos` 来实现，社区thanos是Grafana的全家桶之一，与Prometheus集成完成度非常好

.. note::

   `阿里云实时监控服务ARMS - Kubernetes监控 <https://help.aliyun.com/document_detail/260777.htm?spm=a2c4g.42781.0.0.7a843e6dUFIzGQ#concept-2364008>`_ 类似于 :ref:`cilium` 的eBPF技术，可能也是在开源基础上做的定制。

.. note::

   以下是我的一些使用体验和架构分析，作为云产品的调研和参考

阿里云提供了 ``prometheus`` 部署监控，实际上也是社区版本的魔改::

   kubectl get all -n arms-prom

可以看到::

   NAME                                                               DESIRED   CURRENT   READY   AGE
   replicaset.apps/arms-prom-operator-ack-arms-prometheus-9db46f96c   1         1         1       2d4h
   ...

这里检查 ``arms-prom-operator-ack-arms-prometheus-9db46f96c`` replicaset::

   kubectl get replicaset arms-prom-operator-ack-arms-prometheus-9db46f96c -o yaml -n arms-prom

可以看到::

   ...
         containers:
         - args:
           - --port=9335
           - --yaml=/etc/config/prometheusDisk/prometheus.yaml
   ...
           volumeMounts:
           - mountPath: /etc/config/prometheusDisk
             name: prom-config
   ...
         volumes:
   ...
         - emptyDir: {}
           name: prom-config

也就是说部署这个 ``replicaset`` 的节点，本地有一个 ``tmpfs`` 目录 ``prom-config`` ::

   kubectl get pods -A -o wide | grep arms-prom-operator-ack-arms-prometheus-9db46f96c

这个容器内部 ``/etc/config/prometheusDisk`` 是空目录::

   # df -h
   Filesystem                Size      Used Available Use% Mounted on
   ...
   /dev/nvme3n1              3.4T     17.5G      3.2T   1% /etc/config/prometheusDisk

容器内部检查进程::

   # ps aux | grep pro
       1 root      3h12 /entry --port=9335 --yaml=/etc/config/prometheusDisk/prometheus.yaml ...

然而，在容器中 ``/etc/config/prometheusDisk/prometheus.yaml`` 并不存在

通过CM修改阿里云prometheus配置
==============================

- 可以通过以下 YAML 模版结合jobs来修订阿里云prometheus配置:

.. literalinclude:: aliyun_prometheus/arms-prom-prometheus.yaml
   :language: yaml
   :caption: 通过CM合并到阿里云prometheus配置

- 执行::

   kubectl apply -f arms-prom-prometheus.yaml

不支持 ``web.enable-lifecycle``
===================================

阿里云prometheus配置关闭了通过HTTP POST ``reload`` :

参考 `Updating a k8s Prometheus operator's configs to add a scrape target <https://stackoverflow.com/questions/63496950/updating-a-k8s-prometheus-operators-configs-to-add-a-scrape-target>`_ ，实际上Prometheus是支持动态加载配置的，无需重启::

   curl -X POST http://localhost:9090/-/reload

不过，在阿里云平台，提示::

   Lifecycle API is not enabled.

.. note::

   Prometheus can reload its configuration at runtime. If the new configuration is not well-formed, the changes will not be applied. A configuration reload is triggered by sending a SIGHUP to the Prometheus process or sending a HTTP POST request to the /-/reload endpoint (when the --web.enable-lifecycle flag is enabled). This will also reload any configured rule files.

参考 `Correct way to update rules and configuration for a Prometheus installation on a Kubernetes cluster that was setup by prometheus-operator helm chart? <https://stackoverflow.com/questions/54766301/correct-way-to-update-rules-and-configuration-for-a-prometheus-installation-on-a>`_

.. _aliyun_starship:

``starship`` Agent
====================

阿里云的GPU服务器也采用了 :ref:`dcgm-exporter` 来实现 :ref:`nvidia_gpu` 监控，不过阿里云做了定制打包成 ``starship`` Agent，作为物理主机上的 :ref:`systemd` 服务运行。这个服务和 :ref:`intergrate_gpu_telemetry_into_k8s` 方案中采用的 :ref:`daemonset` 模式运行有冲突，两者必须只取一种。否则会出现冲突而出现 :ref:`dcgm-exporter_context_deadline_exceeded` 

.. note::

   在测试 ``startship`` Agent 和 :ref:`dcgm-exporter` 共存方案: 可以采用 :ref:`daemonset_nodeaffinity` 来实现对打标的节点安装 :ref:`dcgm-exporter` DS 以及采用同样的方法 ``nodeAntiAffinity`` 来避开 ``systemd`` 模式运行的 ``startship`` 节点。

参考
=====

- `阿里云实时监控服务ARMS <https://help.aliyun.com/product/34364.html?spm=a2c4g.443952.0.0.2c547cd5MDv7oZ>`_ 官方帮助文档
