.. _pcm-grafana:

==================
Intel PCM Grafana
==================

.. note::

   Intel早期(2022年11月停止开发)还开发过一个 `Snap Telemetry Framework (GitHub) <https://github.com/intelsdi-x/snap>`_ 也可以和Grafana结合观测Intel处理器( `Grafana Labs and Intel partner on Grafana and Snap <https://grafana.com/blog/2016/04/11/grafana-labs-and-intel-partner-on-grafana-and-snap/>`_ )，可以参考实现方式。不过，目前看Intel PCM是Intel官方持续开发，并且在Linux主要发行版都提供，提供了非常详细的处理器监控。

.. note::

   `pcm/scripts/grafana/README.md <https://github.com/intel/pcm/blob/master/scripts/grafana/README.md>`_ 提供了通过脚本拉起 :ref:`grafana` 和 :ref:`prometheus` 容器的方法，不过我准备自己独立部署 Grafana 和 Prometheus (同时监控多项服务器目标)，然后将 Intel :ref:`pcm-exporter` 采集数据集成:

   - 先用Intel官方提供的脚本拉起容器
   - 从Grafana中导出Dashboard进行迁移

参考
=====

- `Grafana Dashboard 17108: Processor Counter Monitor (PCM) Dashboard <https://grafana.com/grafana/dashboards/17108-processor-counter-monitor-pcm-dashboard/>`_
