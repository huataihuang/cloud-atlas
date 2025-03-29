.. _container_os:

======================================
容器化操作系统(Container OS)
======================================

随着容器技术成为数据中心的主流运行平台，针对容器应用运行优化的轻量级Linux操作系统大量出现。需要综合评估生态、技术、发展等因素，选额适合自己基础架构的系统。

目前我考虑重点研究：

- :ref:`container_linux` - 著名的CoreOS继承者，在Red Hat生态中，成为Docker/Kubernetes/OpenShift运行基石，并且CoreOS公司同时结合自己研发的etcd，在Kubernetes体系中有举足轻重的影响，
- :ref:`chromium_os` - 虽然不是针对容器研发，但是作为 :ref:`container_linux` 的基础，有着独特的技术结构。并且，作为面向WEB的操作系统，未来可能会和 :ref:`android` 融合，也许和未来操作系统Fuchsia有关联。

.. toctree::
   :maxdepth: 1

   compare_container_os.rst
   atomic.rst
   container_linux.rst
   photon_os.rst

.. only::  subproject and html

   Indices
   =======

   * :ref:`genindex`
