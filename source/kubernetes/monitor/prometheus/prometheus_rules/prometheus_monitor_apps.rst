.. _prometheus_monitor_apps:

===============================
Prometheus监控应用实战
===============================

.. note::

   在实践中，你可能如我一般，花费了很多时间克服各种困难终于部署好了一套 ``kube-prometheus-stack`` 监控系统，看着美观的dashborad却发现不知从何着手打通 **最后一公里** : 将异常按照设定规则发送出告警

   Promethues的官方文档非常枯燥，纯粹是技术参考手册，缺乏引导性的指南；网上大多数资料都是有关部署的，缺少配置的细节，所以自己摸索还是非常费力的

   我希望作为小白学习和实践之后留下的笔记能够清晰地解释和完成一个完整的案例作为参考

参考
=======

- `Prometheus and Kubernetes: Monitoring Your Applications <https://www.weave.works/blog/prometheus-and-kubernetes-monitoring-your-applications/>`_
- `Monitoring Your Kubernetes Infrastructure with Prometheus <https://www.weave.works/blog/monitoring-kubernetes-infrastructure/>`_
