.. _kube-prometheus-stack_etcd_http:

============================================================
``kube-prometheus-stack`` 使用HTTP方式获取etcd的metrics监控
============================================================

我在 :ref:`kube-prometheus-stack_etcd` 实践遇到挫折，没有解决 ``https`` 方式获取metrics的问题(始终http)，即使配置了 ``scheme: https`` 。万般无奈，我暂时回退到采用 ``2381`` 的 HTTP方式获取监控数据

其实etcd官方对监控的文档也很粗疏，采用的也是比较简单的 http 方式

开启 2381 metrics
=====================

对于 :ref:`systemd` 运行的 :ref:`etcd` ，根据 systemd 配置文件，可以看到，etcd参数是通过 ``/etc/etcd.env`` 定制，所以在这个文件中加入以下行启动http的metrics::

   ETCD_LISTEN_METRICS_URLS=http://192.168.6.204:2381,http://127.0.0.1:2381

参考环境变量::

   –listen-metrics-urls
   List of additional URLs to listen on that will respond to both the /metrics and /health endpoints
   default: ""
   env variable: ETCD_LISTEN_METRICS_URLS

重启 ``etcd``

- 配置 ``kube-prometheus-stack.values`` :

.. literalinclude:: kube-prometheus-stack_etcd_http/kube-prometheus-stack.values
   :language: yaml
   :caption: 简单开启 2381 端口 metrics采集，无需证书(http)   

.. note::

   如果之前已经部署过一次 :ref:`helm3_prometheus_grafana` ( 实践案例 :ref:`z-k8s_gpu_prometheus_grafana` ) ，则默认 ``kube-prometheus-stack.values`` 已经启用过 ``etcd`` 监控配置项::

      kubeEtcd:
        enabled: true

   那么在 ``kube-system`` 会有一个 ``endporint`` 类似名为 ``kube-prometheus-stack-1681-kube-etcd`` ，但是实际 ``ENDPOINTS`` 内容是空的::

      NAME                                      ENDPOINTS           AGE
      kube-prometheus-stack-1681-kube-etcd      <none>              5h29m

   那么直接执行 ``helm upgrade`` 会报错:

   .. literalinclude:: kube-prometheus-stack_etcd/helm_upgrade_gpu-metrics_config_error
      :language: bash
      :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack提示etcd相关错误

   所以先暂时去掉 ``etcd`` 监控:

   .. literalinclude:: kube-prometheus-stack_etcd/kube-prometheus-stack.values_disable_kubeetcd
      :language: yaml
      :caption: ``kube-prometheus-stack.values`` 配置暂时去除 ``etcd`` 监控
   
   然后再执行上面的 配置 ``kube-prometheus-stack.values`` (简单开启 2381 端口 metrics采集，无需证书(http))，再执行下一步 **更新helm** ，就能正常开启etcd监控

- 更新helm:

.. literalinclude:: update_prometheus_config_k8s/helm_upgrade_gpu-metrics_config
   :language: bash
   :caption: 使用 ``helm upgrade`` prometheus-community/kube-prometheus-stack

此时可以在 prometheus WEB界面看到 ``targets`` 中 ``etcd`` 采集成功

参考
=======

- `etcd: Monitoring etcd <https://etcd.io/docs/v3.5/op-guide/monitoring/>`_
- `etcd: Configuration options <https://etcd.io/docs/v3.5/op-guide/configuration/>`_
