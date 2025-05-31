.. _install_golang:

===============
安装 Go 语言包
===============

安装golang
============

从 `golang Getting Started <https://golang.org/doc/install>`_ 下载对应平台的Go语言软件包，然后通过以下命令解压缩安装::

   tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz

以下是 :ref:`debian_tini_image` 的 :ref:`debian` 12环境安装实践:

.. literalinclude:: install_golang/local_install_golang
   :caption: 官方下载最新golang安装包安装

.. note::

   推荐采用golang官方提供的最新版本:

   - :ref:`nvim_ide` 安装 ``gopls`` (Go language server)需要最新版本支持，我在 :ref:`debian` 12上安装发行版提供的较低版本 1.19.8 则编译安装失败，使用官方最新 1.24.3 则成功
   - 已更新 :ref:`debian_tini_image`

不同平台安装发行版golang参考
==============================

- macOS平台提供了pkg包，可以直接下载安装 - 通过pkg安装有一个便利之处是安装会自动清理掉旧版本并安装上新版本，安装目录位于 ``/usr/local/go`` 目录，所以请将路径 ``/usr/local/go/bin`` 加入到 ``PATH`` 环境变量，以便找到 ``go`` 命令。

- CentOS / RHEL ``8`` 安装golang:

.. literalinclude:: install_golang/centos8_install_golang
   :language: bash
   :caption: CentOS / RHEL ``8`` 安装golang

.. note::

   参考 `How To Install Go on CentOS 8 / RHEL 8 <https://computingforgeeks.com/how-to-install-go-on-rhel-8/>`_ RHEL8的软件仓库提供了 ``go-toolset`` 。 

- CentOS ``7`` 安装golang:

.. literalinclude:: install_golang/centos7_install_golang
   :language: bash
   :caption: CentOS / RHEL ``7`` 安装golang

- Ubuntu 18.04 安装golang:

.. literalinclude:: install_golang/ubuntu18_install_golang
   :language: bash
   :caption: Ubuntu 18.04 安装golang

- Debian 12 可以通过发行版仓库直接安装golang(版本比官方下载版本低，目前为 go 1.19.8):

.. literalinclude:: install_golang/debian12_install_golang
   :language: bash
   :caption: Debian 12 安装golang

.. note::

   参考 `Install Go (Golang) on Ubuntu 18.04/ CentOS 7 <https://computingforgeeks.com/how-to-install-latest-go-on-centos-7-ubuntu-18-04/>`_

安装软件包之后，还需要设置 ``$GOPATH`` :

.. literalinclude:: install_golang/bashrc_gopath
   :language: bash
   :caption: 设置 ``$GOPATH`` 环境变量

- 以上CentOS和Ubuntu通过仓库安装，也下载Golang installer进行安装:

.. literalinclude:: install_golang/golang_installer
   :language: bash
   :caption: 下载Golang installer进行安装

- 或者官方下载手工安装:

.. literalinclude:: install_golang/golang_tgz
   :language: bash
   :caption: 使用官方tgz软件包安装

测试golang安装
================

- 创建一个 ``hello.go`` 简单代码::

   package main

   import "fmt"

   function main() {
       fmt.Printf("hello, world\n")
   }

- 编译::

   go build hello.go

- 然后执行测试::

   ./hello

输出显示::

   hello, world

则安装成功

安装dep
===========

dep是Go的依赖管理工具，建议安装。很多项目会使用到这个工具。

- 通过脚本可以直接针对平台进行安装::

   curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

.. note::

   dep安装在用户目录的 ``$HOME/go/bin`` 目录下

- 如果是macOS可以通过 :ref:`homebrew` 安装::

   brew install dep
   brew upgrade dep

.. note::

   Jetbrains GoLand开发平台提供了集成dep的方式，请参考 `GoLand - Creating a project with dep integration <https://www.jetbrains.com/help/go/creating-a-project-with-dep-integration.html>`_ 进行设置。

   .. figure:: ../_static/k8s_dev/go_create_dep_project.png
      :scale: 40

参考
========

- `golang Getting Started <https://golang.org/doc/install>`_
- `How to Install Go on Debian 12 <https://docs.vultr.com/how-to-install-go-on-debian-12>`_
- `dep installation <https://golang.github.io/dep/docs/installation.html>`_
- `GoLand - Creating a project with dep integration <https://www.jetbrains.com/help/go/creating-a-project-with-dep-integration.html>`_
