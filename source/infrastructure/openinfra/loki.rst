.. _loki:

====================================================
LOKI(Linux OpenStack Kubernetes Infrastructure)
====================================================

和我在 :ref:`priv_cloud_infra` 设想并实践的架构想通， :ref:`openinfra` 将 结合 Linux, OpenStack, Kubernetes 的 IaaS 架构云计算称为 ``LOKI`` (Linux OpenStack Kubernetes Infrastructure)。

- :ref:`openstack` 通过 :ref:`kvm` 虚拟化充分发挥了硬件虚拟化的安全隔离、可平行扩展、大规模网络以及配套管理、计费
- :ref:`kubernetes` 给企业租户灵活的计算资源调度，充分发挥了 :ref:`linux` 容器技术的性能、恰当的安全性

:ref:`openstack` 作为开源IaaS底座，一直缺乏大型互联网公司的生产实现案例。虽然今天(2021年底)预计全球有 ``2千5百万`` (25 million)CPU核心用于OpenStack计算，但是大多数(66%)都是年复一年累计起来，绝大多数实践用例都是小型规模。为了能够有企业级核心应用，共计有7加公司进入了 ``一百万Core俱乐部`` ，包括 中国移动, Line, 沃尔玛实验室, Workday 和 雅虎。



参考
======

- `LOKI: An open-source enterprise cloud to call your own <https://www.zdnet.com/article/an-open-source-enterprise-cloud-to-call-your-own-loki/>`_
