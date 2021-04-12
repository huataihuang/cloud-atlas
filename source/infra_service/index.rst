.. _infra_service:

=================================
Infra-Service Atlas
=================================

在构建复杂 :ref:`infrastructure` 以及构建 :ref:`web` :ref:`kubernetes` 等 IaaS 时，实际上有很多隐形的基础服务是非常关键的。就像 :ref:`real` ，基础的水，电，石油，构成了现代科技的基础，这些隐形的服务是如此重要，甚至出现一丝丝抖动，都会让坚如磐石的 :ref:`distributed_system` 出现极难处理的异常。

从互联网应用来看，我认为以下服务是数据中心极为关键的技术:

- NTP
- DNS
- DHCP
- TFTP

我将在部署各种应用服务器涉及到上述技术时，进行不断的实践和积累，以逐步形成数据中心基础服务的指南。

.. toctree::
   :maxdepth: 1

   ntp/index
   dns/index
   ssh/index
   asciinema/index

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
