.. _real_prepare:

=======================
真实云计算的构建准备
=======================

从这里开始，我将一步步构建生存在真实世界的云计算环境...

.. note::

   对于个人或小型企业，推荐采用二手的机架服务器来构建私有云平台，虽然二手服务求肯定不如最新的原装服务器性能优异并且有维保，故障率也较高，但是通过开源系统的分布式部署，合理构建故障冗灾，还是能够保障系统稳定性的。

   当然，我没有资金购买服务器，即使二手，所以，我依然采用 :ref:`kvm_docker_in_studio` 中使用的 :ref:`nested_virtual` 来实现私有云的物理服务器。

真实云计算的解析地址:

.. literalinclude:: hosts
   :language: bash
   :linenos:
   :caption:

.. toctree::
   :maxdepth: 1

   phy_server_setup.rst   
