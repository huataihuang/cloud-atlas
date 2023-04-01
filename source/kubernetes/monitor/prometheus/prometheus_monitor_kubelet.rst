.. _prometheus_monitor_kubelet:

==============================
Prometheus监控Kubelet
==============================

在排查 :ref:`prometheus_metrics_connect_refuse` 时可以看到，Kubelet的metrics监控采集并不是 ``connection refused`` 报错，而是 ``server returned HTTP status 403 Forbidden``

而且我也发现，并不是所有节点都出现 ``403 Forbidden`` ，管控服务器 ``control001`` 到 ``control003`` 这3台服务器的kubelet是正常监控的(实际上工作节点采用了手工安装的定制 ``kubelet`` 软件包)

.. figure:: ../../../_static/kubernetes/monitor/prometheus/prometheus_monitor_kubelet_403_forbidden.png
   :scale: 50

这是因为 ``kubelet`` 的 ``metrics`` 访问采用了 ``https`` ，需要为采集提供访问证书

参考
=======

- `How to Monitor the Kubelet <https://sysdig.com/blog/how-to-monitor-kubelet/>`_
