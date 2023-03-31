.. _prometheus_metrics_connect_refuse:

=========================================
Prometheus访问监控对象metrics连接被拒绝
=========================================

:ref:`helm3_prometheus_grafana` 后，我发现一个奇怪的现象，在 Prometheus 的 ``Status >> Targets`` 中显示的监控对象基本上都是 ``Down`` 状态的:

.. figure:: ../../../_static/kubernetes/monitor/prometheus/prometheus_metrics_connect_refuse.png
   :scale: 50

   Prometheus 的 ``Status >> Targets`` 中显示的监控对象 ``Down``

这里访问的对象端口:

.. csv-table:: prometheus访问监控对象端口
   :file: prometheus_metrics_connect_refuse/prometheus_metrics_ports.csv
   :widths: 20,30,50
   :header-rows: 1

这里不能访问的监控对象 ``metrics`` 通常是因为组件启用了安全配置，也就是 ``metrics`` 仅在本地回环地址上提供。例如 ``kube-proxy`` 的 ``metric-bind-address`` 配置成 ``127.0.0.1:10249``

解决方法举例 ``kube-proxy`` ::

   $ kubectl edit cm/kube-proxy -n kube-system
   ## Change from
       metricsBindAddress: 127.0.0.1:10249 ### <--- Too secure
   ## Change to
       metricsBindAddress: 0.0.0.0:10249

   $ kubectl delete pod -l k8s-app=kube-proxy -n kube-system

注意，删除 ``kube-proxy`` 会导致网络短暂断开，所以要迁移容器或者在业务低峰时更新

参考
======

- `Kube-Proxy endpoint connection refused #16476 <https://github.com/helm/charts/issues/16476>`_
- `Expose kube-proxy metrics on 0.0.0.0 by default #74300 <https://github.com/kubernetes/kubernetes/pull/74300>`_
