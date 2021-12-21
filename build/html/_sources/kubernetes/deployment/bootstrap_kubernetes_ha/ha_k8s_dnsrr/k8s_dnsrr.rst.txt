.. _k8s_dnsrr:

========================================
基于DNS轮询和HAProxy构建高可用Kubernetes
========================================

在 :ref:`ha_k8s_lb` 部署中，负载均衡采用的是 :ref:`haproxy` 结合keeplived实现VIP自动漂移。不过，在测试环境中部署，由于环境限制，不能提供VIP独占，所以改为采用DNS轮询到两个HAProxy服务器上实现高可用Kubernetes的管控访问。

.. literalinclude:: ../../../../studio/hosts
   :language: bash
   :lines: 100-106
   :linenos:
   :caption: hosts

安装HAProxy
==============

    
