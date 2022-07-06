.. _k8s_dnsrr:

========================================
基于DNS轮询和HAProxy构建高可用Kubernetes
========================================

.. note::

   在 :ref:`ha_k8s_lb` 部署中，负载均衡采用的是 :ref:`haproxy` 结合keeplived实现VIP自动漂移。可以在部署基础上改造DNSRR到负载均衡模式

