.. _prometheus_profiling:

==========================
Prometheus profiling
==========================

防护Prometheus profiling
============================

Prometheus 默认激活了 ``pprof`` debug功能，这对于一些漏洞扫描工具，如 :ref:`openvas` 会扫描出 "敏感信息泄漏" 告警。虽然 ``pprof`` 通常被视为一个安全入口，但是基于公司安全策略，可能还是会要求关闭这个入口。



参考
======

- `Monitoring and Debugging Prometheus: Profiling Overview <https://training.promlabs.com/training/monitoring-and-debugging-prometheus/profiling/overview>`_
