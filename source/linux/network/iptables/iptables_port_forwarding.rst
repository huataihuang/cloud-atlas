.. _iptables_port_forwarding:

====================================
iptables端口转发(port forwarding)
====================================

简单脚本端口转发案例
=======================

在 :ref:`z-k8s_gpu_prometheus_grafana` 实现一个简单的端口转发到后端服务器的 :ref:`prometheus` 和 :ref:`grafana` 端口:

.. literalinclude:: iptables_port_forwarding/iptables_port_forwarding_prometheus
   :language: bash
   :caption: 端口转发 ``prometheus-stack`` 服务端口

参考
=======

- `Linux Port Forwarding Using iptables <https://www.systutorials.com/port-forwarding-using-iptables/>`_
