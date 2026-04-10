.. _intro_incus:

=================
Incus简介
=================

Incus 是一个系统容器、应用容器和虚拟机管理器，是 :ref:`lxd` 的社区fork版本。由于Incus不是Ubuntu管理的社区版本，所以相对LXD而言，更容易被其他发行版如 :ref:`redhat_linux` 和 :ref:`suse_linux` 接受。

Incus提供了类似公有云相似的用户体验: 可以混合使用容器和虚拟机，共享相同的底层存储和网络。

Incus也提供了大量的Linux发行版景象，方便不同的用户环境中使用，并且支持不同的存储后端和网络类型，实现了从笔记本到云实例的硬件兼容支持。

Incus提供了一个简洁的REST API为本地和远程访问实现管理。

.. note::

   目前我在 :ref:`ubuntu_linux` 上主要使用 :ref:`lxd` 来管理系统级容器和虚拟机。考虑到后续可能在其他发行版使用Incus来实现相似功能，所以会做一些技术储备和练习实践。

参考
======

- `INCUS/introduction <https://linuxcontainers.org/incus/introduction/>`_
