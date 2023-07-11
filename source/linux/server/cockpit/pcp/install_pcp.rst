.. _install_pcp:

=========================
安装Performance Co-Pilot
=========================

在大多数主流发行版中都提供了 ``Performance Co-Pilot`` ，安装非常简便:

Fedora / RHEL / CentOS
========================

- 创建 ``/etc/yum.repos.d/performancecopilot.repo`` :

.. literalinclude:: install_pcp/performancecopilot.repo
   :caption: ``/etc/yum.repos.d/performancecopilot.repo``

- 然后执行安装PCP:

.. literalinclude:: install_pcp/dnf_install_pcp
   :caption: 使用 :ref:`dnf` 安装 PCP

Debian / Ubuntu
===============

:ref:`ubuntu_linux` 22.04 LTS上安装，所以根据 ``lsb_release -a`` 输出到版本信息，使用了 ``jammy`` 版本代号):

.. literalinclude:: install_pcp/apt_install_pcp
   :caption: 使用 :ref:`apt` 安装 PCP

``pmcd`` / ``pmda`` / ``pmlogger``
===========================================

在上述安装 ``pcp-zeroconf`` 简化了安装方式，实际上同时安装激活了 ``Performance Metrics Collector Daemon (PMCD)`` (用于采集不同的 ``Performance Metrics Domain Agents (PMDAs)`` 性能数据) 以及本地PCP归档日志服务 ``pmlogger`` 。也可以通过单独命令安装激活:

.. literalinclude:: install_pcp/install_pcp_and_enable_pmcd_pmlogger
   :caption: 独立安装pcp并激活pmcd(Performanc)和pmlogger

``Performance Metrics Domain Agents (PMDAs)`` 提供了从不同组件(domains)的数据，例如 Linux Kernel PMDA, NFS Client PMDA。默认会搜集超过1000个metrics，本地PCP归档日志会通过 ``pmlogger`` 处理。

要激活默认没有激活的PMDAs，例如，要采集 :ref:`pgsql` :

.. literalinclude:: install_pcp/enable_postgresql_pmda
   :caption: 激活 :ref:`pgsql` 的``Performance Metrics Domain Agents (PMDAs)``



参考
====

- `Performance Co-Pilot Installation <https://pcp.readthedocs.io/en/latest/HowTos/installation/index.html>`_
