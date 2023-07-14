.. _process-exporter:

==========================================
process-exporter (通用CPU监控metrics输出)
==========================================

对于Intel处理器，Intel公司官方提供了 :ref:`pcm-exporter` 。但是，很不幸，AMD对标的 :ref:`amd_uprof` 没有提供Prometheus的exporter，导致很难做到通用的处理器监控。

Linux内核对于处理器有 ``/proc`` 文件系统管理，这是处理器通用的监控入口，所以 `process-exporter (GitHub) <https://github.com/ncabatoff/process-exporter>`_ 提供了处理器无关的 :ref:`metrics` 输出exporter，方便我们集成到监控系统:

Grafana集成
=============

有2个基于 ``process-exporter`` Grafana Dashboard:

- `Grafana Dashboard 249: Named processes <https://grafana.com/grafana/dashboards/249-named-processes/>`_
- `Grafana Dashboard 715: Named processes stacked <https://grafana.com/grafana/dashboards/715-named-processes-stacked/>`_ 相同数据源采用了Stacked bar graphs

参考
=======

- `process-exporter (GitHub) <https://github.com/ncabatoff/process-exporter>`_
