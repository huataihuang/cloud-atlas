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

- 然后执行安装PCP(注意，我是在 :ref:`ubuntu_linux` 22.04 LTS上安装，所以根据 ``lsb_release -a`` 输出到版本信息，使用了 ``jammy`` 版本代号):

.. literalinclude:: install_pcp/dnf_install_pcp
   :caption: 使用 :ref:`dnf` 安装 PCP`

参考
====

- `Performance Co-Pilot Installation <https://pcp.readthedocs.io/en/latest/HowTos/installation/index.html>`_
