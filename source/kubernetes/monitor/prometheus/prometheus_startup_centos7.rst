.. _prometheus_startup_centos7:

===============================
CentOS 7环境Prometheus快速起步
===============================

.. note::

   由于生产环境依然在使用RHEL 7(稳定为主)，所以在 :ref:`prometheus_startup` ( :ref:`ubuntu_linux` 22.04 LTS )基础上，再次以 CentOS 7 企业级古老的操作系统为基础，部署Prometheus监控

安装
====

`Prometheus官方网站提供下载 <https://prometheus.io/download/>`_ ，可以获得不同平台 （macOS, Linux, Windows）的版本:

* prometheus
* alertmanager
* 不同的exporter

CentOS 7安装Prometheus
===============================

- 操作系统: :ref:`redhat_linux` (CentOS 7)

- 准备用户账号:

.. literalinclude:: prometheus_startup/add_prometheus_user
   :language: bash
   :caption: 在操作系统中添加 prometheus 用户

CentOS 7 的 ``system`` 系统用户账号的ID从500开始递减，所以这里 ``prometheus`` 用户账号分配到的uid/gid是499

- 创建配置目录和数据目录:

.. literalinclude:: prometheus_startup_centos7/mkdir_prometheus
   :language: bash
   :caption: 在操作系统中创建prometheus目录(选择 ``/home`` 主目录)

- 下载最新prometheus二进制程序:

.. literalinclude:: prometheus_startup_centos7/centos_install_prometheus
   :language: bash
   :caption: 在CentOS7环境安装Prometheus

配置以及systemd运行Prometheus
===============================

- 在解压缩的Prometheus软件包目录下有配置案例以及 console libraries :

.. literalinclude:: prometheus_startup/config_prometheus
   :language: bash
   :caption: 简单配置

- 创建 Prometheus 的 :ref:`systemd` 服务管理配置文件 ``/etc/systemd/system/prometheus.service`` :

.. literalinclude:: prometheus_startup_centos7/prometheus.service
   :caption: Prometheus :ref:`systemd` 服务管理配置文件 ``/etc/systemd/system/prometheus.service``

.. note::

   这里部署的 ``prometheus`` 数据存储在 ``/home/data/prometheus`` 目录，所以需要先创建这个目录才能运行服务::

      mkdir -p /home/data/prometheus
      chown prometheus:prometheus /home/data/prometheus

- 启动服务:

.. literalinclude:: prometheus_startup/start_prometheus
   :caption: 启动Prometheus

.. warning::

   如果系统启用了 :ref:`cockpit` ，会遇到端口冲突导致无法启动。请先执行 :ref:`cockpit_port_address` 调整(我设置成 ``9091`` )

反向代理和url
===============

对于采用 :ref:`prometheus_behind_reverse_proxy` 部署，如果采用了 :ref:`prometheus_sub-path_behind_reverse_proxy` ，则还需要修订 ``/etc/systemd/system/prometheus.service`` ，添加 ``--web.external-url`` 运行参数，否则反向代理会提示页面不存在

- 配置 ``/etc/nginx/conf.d/onesre-core.conf`` 设置反向代理:

.. literalinclude:: prometheus_behind_reverse_proxy/sub-path_nginx.conf
   :caption: nginx反向代理，prometheus使用sub-path模式 ``/etc/nginx/conf.d/onesre-core.conf``

- 修订 ``/etc/systemd/system/prometheus.service`` 添加 ``--web.external-url`` 运行参数:

.. literalinclude:: prometheus_behind_reverse_proxy/prometheus.service
   :caption: 添加 ``--web.external-url`` 运行参数 的 ``/etc/systemd/system/prometheus.service``
   :emphasize-lines: 21

注意，此时默认内置的 ``prometheus`` job也需要修订将 ``sub-path`` 添加上去，以便能够抓去mtrics:

- 修改 ``/etc/prometheus/prometheus.yml`` :

.. literalinclude:: prometheus_startup_centos7/prometheus.yml
   :caption: 根据prometheus运行参数 ``--web.external-url`` 修订抓去路径
   :emphasize-lines: 27

配套安装exporter
===================

我的主要目标是实现 :ref:`hpe_server_monitor` ，所以继续安装以下组件:

- :ref:`node_exporter`

参考
========

- `How To Install and Configure Prometheus On a Linux Server <https://devopscube.com/install-configure-prometheus-linux/>`_
- `Install Prometheus Server on Ubuntu 22.04|20.04|18.04 <https://computingforgeeks.com/install-prometheus-server-on-debian-ubuntu-linux/>`_
- `How to Install Prometheus and Grafana on Ubuntu? <https://antonputra.com/monitoring/install-prometheus-and-grafana-on-ubuntu/>`_ 这篇非常详尽，建议参考
