.. _studio:

=================================
Studio
=================================

:ref:`cloud_atlas` 是实践的指南，所以我希望能够在个人有限的硬件环境下，模拟出大规模云计算的部署和开发：

我 **主要** 使用:

- :ref:`mbp15_late_2013`
- :ref:`hpe_dl360_gen9`

安装Linux系统来运行KVM虚拟化，进一步部署OpenStack和Kubernetes，实现IaaS集群。然后，在云计算中运行PaaS和SaaS实现完整的云计算架构。

这样的模拟环境，用于实现 :ref:`cloud_atlas` 中所涉及的各种云计算技术:

.. toctree::
   :maxdepth: 1

   introduce_my_studio.rst
   hardware/index
   base_os.rst
   kvm_docker_in_studio.rst
   kubenetes_in_studio.rst
   studio_ip.rst
   ntp_in_studio.rst
   dnsmasq_in_studio.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
