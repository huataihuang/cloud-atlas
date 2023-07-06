.. _istio-proxy_metrics:

======================
istio-proxy metrics
======================

.. interalinclude:: istio-proxy_metrics/curl_istio-proxy_metrics
   :language: bash
   :caption: 获取 istio-proxy 的metrics

由于metrics内容过多，服务器端断开下载连接:

.. interalinclude:: istio-proxy_metrics/curl_istio-proxy_metrics_output
   :language: bash
   :caption: 获取 istio-proxy 的metrics失败，原因是metrics过大

参考
=====

- `Prometheus, Istio, and mTLS: the definitive explanation <https://superorbital.io/blog/istio-metrics-merging/>`_
- `Istio Standard Metrics <https://istio.io/latest/docs/reference/config/metrics/>`_

