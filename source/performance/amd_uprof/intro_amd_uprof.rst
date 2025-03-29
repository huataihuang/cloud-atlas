.. _intro_amd_uprof:

=====================
AMD uProf简介
=====================

AMD uProf("MICRO-prof")是AMD公司开发的针对AMD Zen处理器和AMD Instinct MI系列加速器的软件性能分析工具。AMD uProf可以让开发者更好理解应用的性能瓶颈以及改进提高。

AMD uProf提供以下功能:

- 性能分析: 找出应用程序的运行性能瓶颈
- 系统分析: 监控系统性能 metrics
- 电源特性: 监控系统的温度和电力特性
- 电能消耗: (仅限Windows系统)分析应用程序电能消耗的热点
- 远程观测: 提供了远程Linux系统连接(从Windows系统)，触发将远程系统的数据采集/转换到本地GUI


监控集成
=========

虽然AMD uProf PCM 对标 :ref:`intel_pcm` ，但是很不幸，目前AMD uProf没有提供 :ref:`prometheus_exporters` 输出，所以还不能实现 :ref:`grafana` 集成( `AMD uProf PCM support with Prometheus Grafana <https://community.amd.com/t5/server-gurus-discussions/amd-uprof-pcm-support-with-prometheus-grafana/m-p/560626>`_ )

不过，Linux内核对CPU处理器有通用的 ``/proc`` 对象，所以可以采用 :ref:`process-exporter` 来统一监控Intel和AMD处理器(Intel处理器的精细监控可以采用官方的 :ref:`pcm-exporter` )

参考
======

- `AMD Developer Resources > AMD uProf <https://www.amd.com/en/developer/uprof.html>`_
- `AMD uProf User Guide <https://www.amd.com/content/dam/amd/en/documents/developer/uprof-v4.0-gaGA-user-guide.pdf>`_
