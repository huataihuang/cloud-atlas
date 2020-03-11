.. _atomic:

=================
Atomic
=================

.. note::

   Atomic Host已经被 :ref:`container_linux` (CoreOS) 替代，所以从 Fedora29/CentOS 7/RHEL 7之后，将不再有新版本释出。后续容器化操作系统，将重点围绕CoreOS实践。Atomic的架构仅做学习参考。

Atomic项目是围绕LDK(Linux, Docker, Kubernetes)技术栈的基础架构重新设计的操作系统，集成了众多开源项目。大多数Atomic项目的组件都是 :ref:`openshift` Origin v3的上游组件。

Atomic项目的主要构成是 Atomic Host，一种实现上述理念的轻量级容器操作系统。Atomic Host是不可改变的(immutable)，因为它是从一个上游仓库获得的镜像，支持mass deployment(组合部署?)。应用程序运行在容器中。Atomic Host的版本基于CentOS和Fedora，并且有一个下游企业版本，即Red Hat Enterprise Linux。

当前，Atomic Host出厂就安装了Kubernetes，不过，最终是迁移到一个容器化的Kubernetes安装，以便更容易在同一个主机支持不同版本，例如 :ref:`openshift` v3。Atomic Host也提供了一些kubernetes工具，例如 :ref:`etcd` 和 :ref:`flannel` 。

Atomic Host是通过一个 rpm-ostree 工具来管理启动，不可修改性，从上游RPM内容而来的版本化文件系统树。这些结合了一些其他组件构成了 ``atomic`` 命令，提供了一个统一的管理入口。

Atomic项目包含了基础的不可改变的基于容器的基础架构工具，包括：

- :ref:`cockpit` 提供了主机和容器集群的可视化
- 针对Docker的更好的SELinux和systemd集成的补丁和扩展
- 有助于开发容器化应用的 ``Atomic Developer Bundle``

参考
======

- `Introduction to Project Atomic <http://www.projectatomic.io/docs/introduction/>`_
