.. _prometheus_metrics_context_deadline_exceeded:

=========================================================
Prometheus监控对象metrics显示"context deadline exceeded"
=========================================================

我在排查 :ref:`prometheus_metrics_connect_refuse` 发现有的被监控对象并不是 ``connection refused`` ，而是显示错误 ``context deadline exceeded`` ，例如 :ref:`coredns` :

.. figure:: ../../../_static/kubernetes/monitor/prometheus/prometheus_metrics_context_deadline_exceeded.png
   :scale: 50

可以看到这2个 :ref:`coredns` 数据采集超过10秒导致报错

这个问题待查，我发现存在问题的2个coredns位于管控节点，而另外3个正常的coredns则位于工作节点

参考
======

- `Servicemonitor/monitor/coredns context deadline exceeded #1762 <https://github.com/prometheus-operator/kube-prometheus/issues/1762>`_ 也是coredns的监控超时，但是似乎没有解决
- `Context Deadline Exceeded - prometheus <https://stackoverflow.com/questions/49817558/context-deadline-exceeded-prometheus>`_
