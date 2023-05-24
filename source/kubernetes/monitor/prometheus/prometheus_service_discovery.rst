.. _prometheus_service_discovery:

=============================
Prometheus服务发现
=============================



限定服务发现端口
===================

`Kuberenetes SD scrapes all service ports, not just the one annotated #2507 <https://github.com/prometheus/prometheus/issues/2507>`_ 提到的问题我似乎也遇到了， ``prometheus`` 自动发现的端口多于我期望的 ``metrics`` 端口。解决方法可以采用正则表达式

参考
======

- `How to set up Kubernetes service discovery in Prometheus <https://se7entyse7en.dev/posts/how-to-set-up-kubernetes-service-discovery-in-prometheus/>`_ 这个文章写得较好，还需要仔细学习
- `Kubernetes Service Discovery in Prometheus <https://kevinfeng.github.io/post/kubernetes-sd-in-prometheus/>`_
- `Prometheus service discovery: Supported service discovery configs <https://docs.victoriametrics.com/sd_configs.html>`_ 可借鉴
- `Kuberenetes SD scrapes all service ports, not just the one annotated #2507 <https://github.com/prometheus/prometheus/issues/2507>`_
- `How do I target endpoints with specific ports in prometheus <https://stackoverflow.com/questions/75670285/how-do-i-target-endpoints-with-specific-ports-in-prometheus>`_ 这里有一个指定端口8081的案例
