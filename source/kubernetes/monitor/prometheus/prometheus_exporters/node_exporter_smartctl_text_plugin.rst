.. _node_exporter_smartctl_text_plugin:

===================================
Node Exporter smartctl 文本插件
===================================

监控磁盘 SMART 数据，原理也是采用 :ref:`node_exporter_textfile-collector`

- 使用修订过的 `janw / node-exporter-textfile-collector-scripts / smartmon.sh <https://github.com/janw/node-exporter-textfile-collector-scripts/blob/master/smartmon.sh>`_

  - `Grafana Dashboard 10664: SMART disk data <https://grafana.com/grafana/dashboards/10664-smart-disk-data/>`_ 也比较清晰

- 使用 `olegeech-me / S.M.A.R.T-disk-monitoring-for-Prometheus <https://github.com/olegeech-me/S.M.A.R.T-disk-monitoring-for-Prometheus/>`_ (从 `micha37-martins / S.M.A.R.T-disk-monitoring-for-Prometheus <https://github.com/micha37-martins/S.M.A.R.T-disk-monitoring-for-Prometheus>`_ fork出来):

  - `Grafana Dashboard 13654: S.M.A.R.T Dashboard <https://grafana.com/grafana/dashboards/13654-s-m-a-r-t-dashboard/>`_ 比较美观清晰，准备主要使用这个面板

- 使用 `micha37-martins / S.M.A.R.T-disk-monitoring-for-Prometheus <https://github.com/micha37-martins/S.M.A.R.T-disk-monitoring-for-Prometheus>`_ 采集:

  - `Grafana Dashboard 10530: S.M.A.R.T disk monitoring for Prometheus Dashboard <https://grafana.com/grafana/dashboards/10530-s-m-a-r-t-disk-monitoring-for-prometheus-dashboard/>`_ 这个概况比较好，准备使用
  - `Grafana Dashboard 10531: S.M.A.R.T disk monitoring for Prometheus Errorboard <https://grafana.com/grafana/dashboards/10531-s-m-a-r-t-disk-monitoring-for-prometheus-errorboard/>`_ 主要扩展error details
