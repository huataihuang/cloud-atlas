.. _kube-prometheus-stack_persistent_volume_grafana_debug:

====================================================
``kube-prometheus-stack`` Grafana持久化卷后问题排查
====================================================

我在 :ref:`kube-prometheus-stack_persistent_volume` 配置了 :ref:`grafana` 持久化，当时我还同时配置了 :ref:`nginx_reverse_proxy` ，但是没有想到启用域名之后 :ref:`grafana_behind_reverse_proxy` 始终无法登陆( ``401 Unauthorized`` )，不得已回退。

但是，没有想到回退了 :ref:`grafana_behind_reverse_proxy` (也就是去除 ``kube-prometheus-stack.values`` 中 ``domain`` 配置重新 :ref:`update_prometheus_config_k8s` )，我惊奇地发现， :ref:`grafana` 不能从 :ref:`prometheus` 获取数据，即使添加了数据源( ``test & save`` 之后)也不行。

排查
======

- 检查 ``grafana`` 日志::

   kubectl -n prometheus logs kube-prometheus-stack-1681228346-grafana-849b55868d-7msvq -c grafana

看到一个奇怪的:

.. literalinclude:: kube-prometheus-stack_persistent_volume_grafana_debug/grafana_query_prometheus_fail.log
   :caption: grafana查询prometheus失败日志
   :emphasize-lines: 1,2,5,8,10

- 检查 ``prometheus`` 日志::

   kubectl -n prometheus logs prometheus-kube-prometheus-stack-1681-prometheus-0 -c prometheus

除了 ``metrics`` 抓取错误，但是为何会有很多 ``write to WAL`` 没有权限的错误:

.. literalinclude:: kube-prometheus-stack_persistent_volume_grafana_debug/prometheus_fail.log
   :caption: prometheus失败日志
   :emphasize-lines: 1,2,5,8,10

- 登陆到 ``prometheus`` 容器内部检查::

   kubectl -n prometheus exec -it prometheus-kube-prometheus-stack-1681-prometheus-0 -c prometheus -- /bin/sh

然后进入 ``/prometheus`` 目录，尝试touch文件并检查文件权限:

.. literalinclude:: kube-prometheus-stack_persistent_volume_grafana_debug/prometheus_debug
   :caption: prometheus排查文件读写

我发现 ``prometheus`` 是使用 ``1000`` 作为 ``uid`` 的，但是，为何目录下文件权限都是 ``472`` 的 ``uid``

我突然想到我上午配置 :ref:`kube-prometheus-stack_persistent_volume` ，配置 :ref:`grafana` 持久化存储发现一个怪现象， ``grafana`` 持久化目录并没有自建独立子目录，而是把目录散在 ``/prometheus/data`` 目录下，而 ``prometheus`` 是独立的 ``prometheus-data`` 子目录。看来 ``grafana`` 完全认为自己独占目录，直接把目录下所有子目录都修订为自己的运行 ``uid 472`` 了。

解决方法是把 ``grafana`` 的目录独立出来，然后恢复 ``prometheus`` 目录的的 ``uid gid`` 为 ``1000     2000``

后续
======

这次意外导致我的集群数据采集数据丢失了几个小时，也是一个经验教训。这次意外也提醒我数据备份恢复的重要性(毕竟大家话费了大量世间配置Grafana的面板)，即使监控数据具有时效性，但是通常灰飞烟灭也是不能接受的。

我将实践:

- :ref:`grafana_backup_and_restore`
- :ref:`prometheus_backup_and_restore`
