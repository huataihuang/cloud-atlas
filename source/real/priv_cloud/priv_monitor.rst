.. _priv_monitor:

====================
私有云监控
====================

虽然是在一台二手服务器上通过 :ref:`kvm` 虚拟化出云计算集群，但是随着服务器增多和架构部署的复杂化，我渐渐发现，没有一个完善的监控，是很难排查出系统问题和及时发现故障的:

- :ref:`ntp` 异常会导致分布式集群出现很多意想不到的错误，例如 :ref:`squid_ssh_proxy` 遇到 ``kex_exchange_identification: Connection closed`` 异常
- :ref:`dns` 异常会导致服务调用失败

物理主机监控
==============

采用 :ref:`prometheus` 能够对 :ref:`kubernetes` 集群进行监控，也能够通过 :ref:`ipmi_exporter` 采集物理主机的温度、主频等基础数据，所以在物理主机中:

- 物理主机部署 :ref:`cockpit` ，通过 :ref:`pcp` 集成插件方式来实现底层系统的性能数据采集和分析
- (可选)物理主机独立部署 :ref:`prometheus` 和 :ref:`ipmi_exporter` (采用 :ref:`systemd` 运行)，这样可以持续采集监控数据
- 物理主机上部署一个独立 :ref:`grafana` 来汇总基础运行监控，将 :ref:`pcp` 数据可视化，例如底层的 :ref:`ceph` :ref:`gluster` :ref:`zfs` 等监控数据
- 通过 :ref:`prometheus-webhook-dingtalk` 发送钉钉消息，也通过 微信 来发送通知，此外还可以尝试自己接入一个短信、语音网关来实现通知

另外一个轻量级的主机监控是 :ref:`cockpit` ，发行版已经提供了集成，并且可以快速激活，也可以尝试实现上述 :ref:`prometheus` 的监控服务，同时提供对服务器的配置管理:

- 通过激活 :ref:`cockpit-pcp` 可以监控 :ref:`metrics` 实现服务器的温度监控

.. note::

   最优的监控解决方案是 :ref:`opentelemetry` : :ref:`prometheus` 和 :ref:`pcp` 仅提供了 :ref:`metrics` 监控，两者的层次和功能其实非常类似，而 :ref:`opentelemetry` 集成了 Traces, Metrics, Logs 实现了完整的软件堆栈分析，当然这也更为复杂，更适合分布式集群的深入分析。不过，OpenTelemetry专注于数据生成、采集和管理，实际完整产品化方案可以采用 :ref:`signoz` ，或者结合 :ref:`prometheus` + :ref:`jaeger` + :ref:`fluentd` 来构建解决方案

.. note::

   经过对比不同的主机监控方案，我在 :ref:`hpe_server_monitor` 方案中筛选了上述几个方案综合监控服务器集群

物理主机部署 Prometheus 软件堆栈非常简便，采用 :ref:`prometheus_startup` 简单步骤就能初步完成部署

.. note::

   对于生产环境，如果服务器操作系统是CentOS7 则采用以下组合:

   - :ref:`prometheus_startup_centos7`
   - :ref:`install_grafana_centos7`
   - :ref:`node_exporter`

部署Prometheus
================

除了在 :ref:`y-k8s` 采用 :ref:`y-k8s_kube-prometheus-stack` 部署Kubernetes集群内的 :ref:`prometheus` 监控外，在物理主机上直接部署一套 :ref:`prometheus` + :ref:`grafana` ，以提供基础监控并集成 :ref:`pcp` 来实现集成性能监控，并且将 :ref:`intel_pcm` 集成在监控中，对物理主机的 :ref:`intel_cpu` 进行深入的性能分析。


- 准备用户账号:

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_startup/add_prometheus_user
   :language: bash
   :caption: 在操作系统中添加 prometheus 用户

- 创建配置目录和数据目录:

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_startup/mkdir_prometheus
   :language: bash
   :caption: 在操作系统中创建prometheus目录

- 下载最新prometheus二进制程序:

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_startup/ubuntu_install_prometheus
   :language: bash
   :caption: 在Ubuntu环境安装Prometheus

- 在解压缩的Prometheus软件包目录下有配置案例以及 console libraries :

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_startup/config_prometheus
   :language: bash
   :caption: 简单配置

- 创建 Prometheus 的 :ref:`systemd` 服务管理配置文件 ``/etc/systemd/system/prometheus.service`` :

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_startup/prometheus.service
   :caption: Prometheus :ref:`systemd` 服务管理配置文件 ``/etc/systemd/system/prometheus.service``

- 启动服务:

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_startup/start_prometheus
   :caption: 启动Prometheus

部署Grafana
===============

由于物理主机使用的是 :ref:`ubuntu_linux` 22.04，Grafana提供了非常方便的软件仓库安装方式，可以快速完成 :ref:`install_grafana`

- 安装社区版APT源:

.. literalinclude:: ../../kubernetes/monitor/grafana/install_grafana/ubuntu_install_grafana
   :caption: 在Ubuntu中安装Grafana

- 启动服务:

.. literalinclude:: ../../kubernetes/monitor/grafana/install_grafana/ubuntu_start_grafana
   :caption: 启动Grafana

反向代理
==========

:ref:`prometheus` (端口9090) 和 :ref:`grafana` (端口3000)都内置提供了 :ref:`web` 服务，为了方便访问，采用 :ref:`nginx` 反向代理 :ref:`grafana_behind_reverse_proxy` :

.. literalinclude:: ../../kubernetes/monitor/grafana/grafana_behind_reverse_proxy/alertmanager
   :caption: NGINX 反向代理 ``alertmanager`` 配置

.. literalinclude:: ../../kubernetes/monitor/grafana/grafana_behind_reverse_proxy/grafana
   :caption: NGINX 反向代理 ``grafana`` 配置

.. literalinclude:: ../../kubernetes/monitor/grafana/grafana_behind_reverse_proxy/prometheus
   :caption: NGINX 反向代理 ``prometheus`` 配置

启动 NGINX 后，通过域名访问:

- grafana.cloud-atlas.io
- prometheus.cloud-atlas.io
- alertmanager.cloud-atlas.io

安装 :ref:`prometheus` / :ref:`grafana` / :ref:`alertmanager` 只是提供了运行监控运行框架，我们需要通过丰富的 :ref:`prometheus_exporters` 以及第三方exporter来实现全面的系统监控:

Node Exporter
==============================

:ref:`node_exporter` 是首先需要部署的重要Exporter

.. note::

   我的 :ref:`y-k8s` 采用了 :ref:`nvidia_gpu` 的 :ref:`vgpu` 构建模拟 :ref:`gpu_k8s` ，NVIDIA官方提供了 :ref:`dcgm-exporter` 可以实现GPU的全面监控。不过，由于GPU是结合 :ref:`kubernetes` 部署，所以我仅在 :ref:`y-k8s` 中通过 :ref:`helm3_prometheus_grafana` 部署整个GPU管理组件以及结合 :ref:`dcgm-exporter` 的监控，在物理服务器上就不再部署。

- 下载安装 Node Exporter 执行程序: 

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_exporters/node_exporter/install_node_exporter
   :caption: 安装Node Exporter执行程序

- 配置 ``/etc/systemd/system/node_exporter.service`` :

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_exporters/node_exporter/node_exporter.service
   :caption: 配置 Node Exporter 服务，通过 :ref:`systemd` 运行

- 启动:

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_exporters/node_exporter/systemd_node_exporter
   :caption: 通过 :ref:`systemctl` 启动 ``node_exporter`` 服务

- 修改 ``/etc/prometheus/prometheus.yaml`` 添加监控目标服务器 :ref:`node_exporter` 数据抓取:

.. literalinclude:: ../../kubernetes/monitor/prometheus/prometheus_exporters/node_exporter/prometheus_multi.yml
   :language: yaml
   :caption: 在 ``/etc/prometheus/prometheus.yml`` 中添加抓取node配置任务

- 在 Grafana Dashboard 搜索添加 ``1860`` ID 的Dashboard ( `Node Exporter Full <https://grafana.com/grafana/dashboards/1860-node-exporter-full/>`_ )

PCM监控
===========

对于 :ref:`intel_cpu` 可以采用 :ref:`pcm-exporter` 提供详细的CPU监控，结合 :ref:`pcm-grafana` 可以在日常生产中帮助我们定位CPU相关故障和异常:

- 大多数最新的主流发行版都包含了 Intel PCM 安装包，例如 :ref:`ubuntu_linux` 安装 ``pcm`` 之后就具备了 ``pcm-sensor-server`` :

.. literalinclude:: ../../performance/intel_pcm/intro_intel_pcm/ubuntu_install_pcm
   :caption: 在Ubuntu安装Intel PCM

- 虽然可以直接运行 ``pcm-sensor-server`` ，但是为了方便维护，采用 :ref:`systemd` 服务配置 ``/etc/systemd/system/pcm-exporter.service`` :

.. literalinclude:: ../../performance/intel_pcm/pcm-exporter/pcm-exporter.service
   :caption: ``/etc/systemd/system/pcm-exporter.service``

- 启动 ``pcm-exporter`` :

.. literalinclude:: ../../performance/intel_pcm/pcm-exporter/systemd_start_pcm-exporter
   :caption: 启动 ``pcm-exporter`` 服务

- 在 Grafana Dashboard 搜索添加 ``17108`` ID 的Dashboard ( `Grafana Dashboard 17108: Processor Counter Monitor (PCM) Dashboard <https://grafana.com/grafana/dashboards/17108-processor-counter-monitor-pcm-dashboard/>`_ )
