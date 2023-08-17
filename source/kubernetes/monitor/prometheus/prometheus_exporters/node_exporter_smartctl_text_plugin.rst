.. _node_exporter_smartctl_text_plugin:

===================================
Node Exporter smartctl 文本插件
===================================

监控磁盘 SMART 数据，原理也是采用 :ref:`node_exporter_textfile-collector` ，并且 Prometheus社区提供了 `node-exporter-textfile-collector-scripts <https://github.com/prometheus-community/node-exporter-textfile-collector-scripts>`_ 包含了 ``smartmon.sh`` 和 ``smartmon.py`` 来输出符合Prometheus文本采集的数据

准备工作
==========

.. note::

   这部分准备工作我已经在 :ref:`node_exporter_ipmitool_text_plugin` 完成

- 创建一个 ``/var/lib/node_exporter/textfile_collector/`` 用于存放 ``--collector.textfile.directory`` 对应的 ``*.prom`` 文件，以便转换成metrics:

.. literalinclude:: node_exporter_textfile-collector/textfile_collector_dir
   :caption: 准备 ``/var/lib/node_exporter/textfile_collector/`` 目录

- Prometheus社区提供了 `node-exporter-textfile-collector-scripts <https://github.com/prometheus-community/node-exporter-textfile-collector-scripts>`_ ，将这些脚本下载到服务器上:

.. literalinclude:: node_exporter_textfile-collector/git_node-exporter-textfile-collector-scripts
   :caption: 下载 ``node-exporter-textfile-collector-scripts`` 到本地( ``/etc/prometheus`` )

执行脚本
==========

- 社区脚本 ``smartmon.py`` 或 ``smartmon.sh`` 都可以用于输出，注意需要使用 ``sudo`` root权限::

   sudo /etc/prometheus/node-exporter-textfile-collector-scripts/smartmon.sh | sponge /var/lib/node_exporter/textfile_collector/smartmon.prom

- 检查 ``/var/lib/node_exporter/textfile_collector/smartmon.prom`` 内容无误之后，配置 crontab ::

   crontab -e

输入内容::

   * * * * * /etc/prometheus/node-exporter-textfile-collector-scripts/smartmon.sh | sponge /var/lib/node_exporter/textfile_collector/smartmon.prom

配置 ``node_exporter``
==========================

.. note::

   这部分准备工作我已经在 :ref:`node_exporter_ipmitool_text_plugin` 完成

按照 :ref:`node_exporter` 中 :ref:`systemd` 运行服务配置，修订 ``/etc/systemd/system/node_exporter.service`` ::

   ExecStart=/usr/local/bin/node_exporter \
       --collector.textfile.directory=/var/lib/node_exporter/textfile_collector

重启 ``node_exporter`` 服务

配置 Grafana Dashboard
=========================

在 :ref:`grafana` 中 ``import`` `Grafana Dashboard 16514: SMART + NVMe status <https://grafana.com/grafana/dashboards/16514-smart-nvme-status/>`_

改进版本(推荐)
====================================

- 使用修订过的 `janw / node-exporter-textfile-collector-scripts / smartmon.sh <https://github.com/janw/node-exporter-textfile-collector-scripts/blob/master/smartmon.sh>`_

  - `Grafana Dashboard 10664: SMART disk data <https://grafana.com/grafana/dashboards/10664-smart-disk-data/>`_ 这个面板强烈推荐，我发现比使用 `Grafana Dashboard 16514: SMART + NVMe status <https://grafana.com/grafana/dashboards/16514-smart-nvme-status/>`_ 更好更详细

.. figure:: ../../../../_static/kubernetes/monitor/prometheus/prometheus_exporters/node_exporter_with_smartmon_text_plugin.png

其他
=======

- 使用 `olegeech-me / S.M.A.R.T-disk-monitoring-for-Prometheus <https://github.com/olegeech-me/S.M.A.R.T-disk-monitoring-for-Prometheus/>`_ (从 `micha37-martins / S.M.A.R.T-disk-monitoring-for-Prometheus <https://github.com/micha37-martins/S.M.A.R.T-disk-monitoring-for-Prometheus>`_ fork出来):

  - `Grafana Dashboard 13654: S.M.A.R.T Dashboard <https://grafana.com/grafana/dashboards/13654-s-m-a-r-t-dashboard/>`_ 比较美观清晰，准备主要使用这个面板

- 使用 `micha37-martins / S.M.A.R.T-disk-monitoring-for-Prometheus <https://github.com/micha37-martins/S.M.A.R.T-disk-monitoring-for-Prometheus>`_ 采集:

  - `Grafana Dashboard 10530: S.M.A.R.T disk monitoring for Prometheus Dashboard <https://grafana.com/grafana/dashboards/10530-s-m-a-r-t-disk-monitoring-for-prometheus-dashboard/>`_ 这个概况比较好，准备使用
  - `Grafana Dashboard 10531: S.M.A.R.T disk monitoring for Prometheus Errorboard <https://grafana.com/grafana/dashboards/10531-s-m-a-r-t-disk-monitoring-for-prometheus-errorboard/>`_ 主要扩展error details

参考
======

- `Monitoring a mixed fleet of flash, HDD, and NVMe devices with node_exporter and Prometheus <https://www.wirewd.com/hacks/blog/monitoring_a_mixed_fleet_of_flash_hdd_and_nvme_devices_with_node_exporter_and_prometheus>`_
