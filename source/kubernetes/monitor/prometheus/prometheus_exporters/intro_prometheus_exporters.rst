.. _intro_prometheus_exporters:

===============================
Prometheus exporter简介
===============================

Prometheus官方提供了大约十几种 `xxxx_exporters <https://github.com/orgs/prometheus/repositories?q=exporter&type=all&language=&sort=>`_ ，其中比较常用的有 

- ``mysqld_exporter``
- :ref:`node_exporter`
- ``memcached_exporter``
- ``influxdb_exporter``
- ``statsd_exporter``

`Prometheus Monitoring Community <https://github.com/prometheus-community>`_ 则进一步提供了更为广泛的exporter:

- ``postgres_exporter``
- ``elasticsearch_exporter``
- ``systemd_exporter``
- ``smartctl_exporter``
- ``ecs_exporter`` Amazone ECS的exporter
- ``ipmi_exporter`` 这是一个非常有用的exporter，特别是对于物理服务器的监控，如 :ref:`server_hpe` 有人还专门定制了 `hpe-exporter <https://github.com/pyguy/hpe-exporter>`_ (可以借鉴)

   - `IPMI Exporter Grafana Dashboard <https://grafana.com/grafana/dashboards/15765-ipmi-exporter/>`_ 或许可以借鉴
   - 我准备用 ``impi_exporter`` 来监控我的 :ref:`hpe_dl360_gen9`


此外，很多重量级的开源软件也提供了各自的 Prometheus exporter:

- `Prometheus exporter for Gluster Metrics <https://github.com/gluster/gluster-prometheus>`_ :ref:`gluster` 官方提供的exporter - 对应 `glusterfs dashboard <https://grafana.com/grafana/dashboards/10041-glusterfs/>`_

  - 其他可借鉴的Grafana Dashboard: `GlusterFS Statistics Grafana Dashboard <https://grafana.com/grafana/dashboards/10704-glusterfs-test-cluster/>`_ / `GlusterFS Grafana Dashboard <https://grafana.com/grafana/dashboards/8376-glusterfs/>`_

- `HPE Storage Array Exporter for Prometheus <https://hpe-storage.github.io/array-exporter/>`_ HP官方提供的存储监控exporter for Prometheus (可以参考 `Configuring HPE Primary Storage on-prem real-time performance monitoring with Grafana <https://community.hpe.com/t5/around-the-storage-block/configuring-hpe-primary-storage-on-prem-real-time-performance/ba-p/7176372>`_ 和 `Get started with Prometheus and Grafana on Docker with HPE Storage Array Exporter
  <https://developer.hpe.com/blog/get-started-with-prometheus-and-grafana-on-docker-with-hpe-storage-array-exporter/>`_ )

- ``HPE OneView`` (HP官方的服务器管理软件，商用付费软件) 也提供了 `Integration of HPE OneView with Prometheus <https://hewlettpackard.github.io/hpe-solutions-openshift/46-synergy/Additional-Features-and-Functionality/Integration-with-Prometheus.html>`_ (可以参考 `How to monitor HPE OneView infrastructure with Grafana Metrics Dashboards and InfluxDB <https://developer.hpe.com/blog/how-to-monitor-hpe-oneview-infrastructure-with-grafana-metrics-dashboards-and-influxdb/>`_ )

  - 可以在 `HPE Management Component Pack for CentOS 8 (x86_64) <https://support.hpe.com/connect/s/softwaredetails?language=en_US&softwareId=MTX_b024334abf764df4a692b491d5&tab=Installation+Instructions>`_ 之上开发监控
