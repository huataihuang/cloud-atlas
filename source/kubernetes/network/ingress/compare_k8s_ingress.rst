.. _compare_k8s_ingress:

====================================
Kubernetes Ingress比较
====================================

:ref:`ingress` 提供了:

- 负载均衡
- HTTP/HTTPS请求映射
- SSL/TLS终止(termination)

使得 :ref:`k8s_services` 通过安全可达的域和URL暴露(expose)，这样Kubernetes生产环境中expose服务变得简单易行。

请注意 :ref:`k8s_loadbalancer_ingress` ，Ingress工作在OSI的第7层，也就是应用层，所以提供了HTTP/HTTPS请求的检查能力。同时，Ingress也提供了无需负载均衡就能向外提供服务资源(虽然通常会结合 LoadBalancer 和 Ingress)。

常用Ingress
===============

.. csv-table:: 常用Ingress对比
   :file: compare_k8s_ingress/compare_k8s_ingress.csv
   :widths: 20,20,30,30
   :header-rows: 1

参考
======

- `Comparing Kubernetes Ingress Solutions. Which one is right for you? <https://kubevious.io/blog/post/comparing-kubernetes-ingress-solutions-which-one-is-right-for-you>`_
- `Comparison Among Top Ingress Controllers For Kubernetes <https://kubevious.io/blog/post/comparing-top-ingress-controllers-for-kubernetes>`_
