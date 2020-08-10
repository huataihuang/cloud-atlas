.. _haproxy:

=================================
HAProxy
=================================

HAProxy是开源、性能卓越并且可靠地提供高可用负载均衡的解决方案，提供了TCP和基于HTTP应用的代理功能。通常HAProxy用于非常高流量的web网站，并且也是很多世界级网站的基础服务。如果你能翻墙(我很奇怪为何这个页面被GFW了)，可以在HAProxy的 `They use it ! <http://www.haproxy.org/they-use-it.html>`_ 看到很多熟悉的网站。

.. note::

   随着技术的迭代，也有一些公司发展采用了自己的负载均衡技术。例如，Alibaba当前已经采用自研的基于Nginx的负载均衡替代了HAProxy(由于其业务紧密结合)，但是HAProxy作为通用的负载均衡开源技术，合理部署应用也能够实现世界级的解决方案。

.. toctree::
   :maxdepth: 1

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
