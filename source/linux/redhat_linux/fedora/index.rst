.. _fedora:

=====================================
Fedora
=====================================

Fedora是面向Red Hat Enterprise Linux 和 CentOS 开发的理想平台，提供了相同体系并且前卫的技术堆栈。官方文档 `Fedora User Docs: Developers <https://docs.fedoraproject.org/en-US/fedora/f34/release-notes/developers/Developers/>`_ 提供了完整的开发环境构建指南，我在 :ref:`docker_studio` 开发环境采用Fedora 34，在 :ref:`priv_cloud_infra` 重新部署了 ``z-dev`` (Fedora :strike:`35` 37， :ref:`upgrade_fedora_lastest_version` )

`Fedora developer网站 <https://developer.fedoraproject.org/>`_ 提供了在Fedora环境中使用不同语言的开发环境设置以及发布部署的指导，对于开发起步非常有帮助

.. toctree::
   :maxdepth: 1

   fedora37_installation.rst
   upgrade_fedora_lastest_version.rst
   fedora_autoupdates.rst
   fedora_os_images.rst
   fedora_dev_init.rst
   fedora_dev_python.rst
   fedora_dev_c.rst
   fedora_dev_nodejs.rst
   fedora_dev_rust.rst
   fedora_proxy.rst
   fedora_docker.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
