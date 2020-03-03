.. _photon_os:

====================
Photon OS
====================

Photon (光子) OS，是VMware开发的一个开源极简化Linux操作系统，专用于云计算平台的优化，可以部署在VMare vSphere，以及在云上运行原生应用。例如，Photon OS作为Linux容器主机操作系统，为vSphere以及云计算平台，如AWS和GCE做了优化。Photon OS不仅是一个轻量级和可扩展的操作系统，而且支持大多数常用容器格式，包括Docker，Rocket和Garden。Photon
OS包含了一个yum兼容的，基于包生命周期管理系统，称为 ``tdnf`` 。

在开发环境，例如VMware Fusion，VMware Workstation，以及生产运行环境，例如vSphere、vCloud Air，Photon OS都可以无缝迁移基于容器都应用，从开发环境到生产环境。通过一个小巧的运行孔家以及快速启动和运行时，Photon OS针对云计算和云应用做了优化。

.. note::

   在 :ref:`install_docker_macos` 时， :ref:`docker` 采用了 :ref:`hyperkit` 来运行一个精简的 :ref:`alpine` 操作系统。与此类似，运行容器环境并不需要完整的Linux操作系统，采用定制精简的Linux系统，更能够节约系统资源，并且降低安全风险。

   此外，还有Red Hat推出的精简容器运行操作系统 :ref:`atomic`

参考
========

- `Introduction to Photon OS <https://vmware.github.io/photon/assets/files/html/3.0/Introduction.html>`_
