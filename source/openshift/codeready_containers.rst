.. _codeready_containers:

=======================
CodeReady Containers
=======================

CodeReady Containers是一个快速构建OpenShift集群的方法，用于在本地计算机上设置和测试以及模拟云开发环境来开发基于容器的应用程序。也就是类似 :ref:`openstack` 的本地开发环境 :ref:`devstack` ， ``CodeReady Containers`` 就是 OpenShift的本地mini开发环境。

CodeReady Containers提供了一个mini的预先配置的OpenShift 4.x集群，可以在本地单机运行而无需复杂的服务器架构。使用CodeReady Containers(CRC)，可以创建微服务，然后构建成镜像，再在 :ref:`kubernetes` 托管的容器中运行。整个过程都完全在你本地的笔记本或电脑上完成，而本地主机只需要运行Linux, macOS 或 Windows 10。

CodeReady Containers(CRC)提供了:

- OpenShift Container Platform(OCP)的本地版本
- 增强型启动进程和集成服务mesh，serverless以及通过OpenShift Connector连接 :ref:`vscode`
- 在一个单节点集群提供大量模板有以及一个本地 :ref:`docker_registry`

参考
======

- `CodeReady Containers Overview <https://developers.redhat.com/products/codeready-containers/overview>`_
- `Red Hat OpenShift 4 on your laptop: Introducing Red Hat CodeReady Containers <https://developers.redhat.com/blog/2019/09/05/red-hat-openshift-4-on-your-laptop-introducing-red-hat-codeready-containers>`_
