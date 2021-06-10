.. _go_on_fedora:

==================
Fedora环境Go语言
==================

由于 :ref:`docker` 和 :ref:`kubernetes` 在现代容器技术中影响巨大，已经成为分布式调度的集群核心技术，也带来了Go开发语言蓬勃发展。作为迭代最新Linux技术的发行版，Fedora适合作为CentOS/ :ref:`redhat_linux` 开发环境。我在 :ref:`docker_studio` 就采用Fedora来部署不同开发语言环境，也包括Go。

Go安装
========

- 安装Go非常容易::

   sudo dnf install golang

- 设置 ``GOPATH`` 环境变量::

   mkdir -p $HOME/go
   echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
   source $HOME/.bashrc

参考
=======

- `Go on Fedora <https://developer.fedoraproject.org/tech/languages/go/go-installation.html>`_
