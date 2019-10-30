.. _openstack_installation:

=================================
OpenStack安装 
=================================

OpenStack是一个面向所有云计算类型的开源云计算平台，目标是简化实施、超大规模可伸缩以及丰富的功能。

OpenStack实现了基础架构即服务(Infrastructure-as-a-Service, IaaS)解决方案，系统包含了多个关键服务，可以独立安装，也可以根据云计算需要组合部署 计算、认证服务、网络服务、镜像服务、块存储服务、对象存储服务、计量服务、编排服务和数据库服务。每个OpenStack服务都提供了应用程序编程接口(application programming interface, API)，可以按需组合部署。

.. note::

   OpenStack偏向于框架，是各种开源项目的集成者。由于部署复杂，通常都会基于各大发行版的不同部署工具和方法来完成：

   - OpenSUSE 和 SUSE Linux Enterprise Server 使用Open Build Service Cloud repository
   - Red Hat Enterprise Linux 和 CentOS 使用 RDO repository
   - Ubuntu 使用Ubuntu Cloud archive repository for Ubuntu (Pike和Queens版本支持Ubuntu 16.04 LTS，而Queens则直接使用Ubuntu 18.04 LTS)

.. toctree::
   :maxdepth: 1


.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
