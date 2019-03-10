.. _openstack:

=================================
OpenStack Atlas
=================================

OpenStack是开源的AWS系统的clone，目前在小规模云计算场景下应用较多，是开源云计算的事实标准。

.. note::

   OpenStack是各种开源技术的综合实现，属于框架性平台，应用到实际生产仍然需要大量的定制和开发，特别是规模化运行，需要大量的性能优化，是非常考验团队的部署和开发能力的。

   华为的公有云基于 OpenStack 开发，一方面证实了OpenStack具有海量系统的运行能力，另一方面也证明了OpenStack生产实现的成本依然只有少数大型公司能够承担。（ 参考 `国内的云计算平台有没有不是依靠 OpenStack 搭建的？ <https://www.zhihu.com/question/34511860>`_ )

.. toctree::
   :maxdepth: 1

   openstack_architecture.rst
   devstack.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
