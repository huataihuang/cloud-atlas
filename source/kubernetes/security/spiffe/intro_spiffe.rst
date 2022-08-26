.. _intro_spiffe:

======================
spiffe简介
======================

SPIFFE ( ``Secure Production Identity Framework for Everyone`` 安全产品的身份框架) ，是一组开源标准，用于在动态和异构的环境中安全地识别软件系统。采用spiffe的系统可以轻松可靠地互相验证，无论它们在何处运行。

.. note::

   在 :ref:`cilium_service_mesh` 构成图中可以看到，现代的网络堆栈已经需要集成 spiffe 来实现双向验证，原因无他，因为网络越来越复杂而不安全，即使是内部网络也是零信任网络。网络通讯双方必须互相认证，并通过加密通讯进行交互。

   我将在后续 :ref:`cilium` 学习实践中关注 spiffe 的安装部署以及配置等实践，力求对安全认证有比较深刻的理解。

参考
======

- `spiffe overview`
