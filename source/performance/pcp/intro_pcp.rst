.. _intro_pcp:

=========================
Performance Co-Pilot简介
=========================

`Performance Co-Pilot <https://pcp.io/>`_ 是一种轻量级性能采集工具框架:

- 轻量级: 通过搜集性能 :ref:`metrics` 能够有效分析系统性能
- 分布式: 可以从不同主机以及不同操作系统搜集 ``metrics`` 数据
- 自包含: 在所有主要Linux发行版都提供，包括 :ref:`redhat_linux` :ref:`fedora` ``debian`` :ref:`ubuntu_linux` :ref:`suse_linux` :ref:`gentoo_linux`
- 可扩展: 提供插件框架(libraries, APIs, agents 和 daemon)可以从不同来源搜集性能数据，包括硬件，内核，服务，应用库以及应用

PCP采用插件框架可以适合中心化分析复杂的环境和系统，用户可以使用C, C++, Perl 和 Python 接口定制和添加性能metrics。

参考
======

- `Performance Co-Pilot Features <https://pcp.io/features.html>`_
- `PCP Quick Reference Guide: Introduction <https://pcp.readthedocs.io/en/latest/QG/QuickReferenceGuide.html#introduction>`_
