.. _introduce_centos:

==================
CentOS简介
==================

自从CentOS诞生以来，一直开源社区基于Red Hat Enterprise Linux (RHEL)的再"制作发行"版，得到了广泛的使用。不过，随着Red Hat收购了CentOS，并且Red Hat又被IBM收购之后，商业运作也影响了社区发行。

2020年底，随着Red Hat宣布CentOS将结束作为RHEL的下游角色，转为CentOS Stream的滚动发行，并且作为Fedora和RHEL之间的"中游"角色，对CentOS的定位产生了极大的影响。

CentOS Storage Special Interest Group (SIG)
=============================================

 CentOS Storage Special Interest Group ( `SIG <https://wiki.centos.org/SpecialInterestGroup>`_ ) 是确保CentOS适合多种不同存储解决方案的存储兴趣组。这个社区确保所有开源存储选项能够使用CentOS作为交付平台，包括打包，调度部署等相关工作。

.. note::

   我将在 :ref:`ceph` 和 :ref:`gluster` 部署实践中采用SIG方案。

CentOS已死
============

从2021年底开始，由于CentOS8停止更新，在 :ref:`docker` 容器化运行环境中，就不得不 :ref:`centos_8_replacement_docker_image` 。这也迫使用户要么选择购买RedHat的企业级Linux，要么选择采用替代发行版。主要可选的RedHat兼容发行版:

- :ref:`almalinux` : 开源社区驱动的二进制兼容Red Hat Enterprise Linux发行版
- `Rocky Linux <https://rockylinux.org/>`_ : 目前最流行的Red Hat Enterprise Linux bug-for-bug 兼容的企业级发行版

:ref:`almalinux_vs_rockylinux` ，我选择尝试 :ref:`almalinux` 以磨练在RedHat系发行版的技能。
