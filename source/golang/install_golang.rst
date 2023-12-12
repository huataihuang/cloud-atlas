.. _install_golang:

===============
安装 Go 语言包
===============

安装golang
============

从 `golang Getting Started <https://golang.org/doc/install>`_ 下载对应平台的Go语言软件包，然后通过以下命令解压缩安装::

   tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz

- macOS平台提供了pkg包，可以直接下载安装 - 通过pkg安装有一个便利之处是安装会自动清理掉旧版本并安装上新版本，安装目录位于 ``/usr/local/go`` 目录，所以请将路径 ``/usr/local/go/bin`` 加入到 ``PATH`` 环境变量，以便找到 ``go`` 命令。

- CentOS / RHEL ``8`` 安装golang::

   sudo yum upgrade
   sudo yum module list go-toolset
   sudo yum module -y install go-toolset

.. note::

   参考 `How To Install Go on CentOS 8 / RHEL 8 <https://computingforgeeks.com/how-to-install-go-on-rhel-8/>`_ RHEL8的软件仓库提供了 ``go-toolset`` 。 

- CentOS ``7`` 安装golang::

   sudo rpm --import https://mirror.go-repo.io/centos/RPM-GPG-KEY-GO-REPO
   curl -s https://mirror.go-repo.io/centos/go-repo.repo | sudo tee /etc/yum.repos.d/go-repo.repo
   sudo yum install golang

- Ubuntu 18.04 安装golang::

   sudo add-apt-repository ppa:longsleep/golang-backports 
   sudo apt-get update
   sudo apt-get install golang-go

.. note::

   参考 `Install Go (Golang) on Ubuntu 18.04/ CentOS 7 <https://computingforgeeks.com/how-to-install-latest-go-on-centos-7-ubuntu-18-04/>`_

安装软件包之后，还需要设置 ``$GOPATH`` ::

   mkdir -p ~/go/{bin<Plug>PeepOpenkg,src}
   echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
   echo 'export PATH="$PATH:${GOPATH//://bin:}/bin"' >> ~/.bashrc


- 以上CentOS和Ubuntu通过仓库安装，也下载Golang installer进行安装::

   wget https://storage.googleapis.com/golang/getgo/installer_linux
   chmod +x ./installer_linux
   ./installer_linux

- 或者官方下载手工安装::

   VER=1.11
   wget https://dl.google.com/go/go${VER}.linux-amd64.tar.gz
   sudo tar -C /usr/local -xzf go${VER}.linux-amd64.tar.gz
   rm go${VER}.linux-amd64.tar.gz

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
- `dep installation <https://golang.github.io/dep/docs/installation.html>`_
- `GoLand - Creating a project with dep integration <https://www.jetbrains.com/help/go/creating-a-project-with-dep-integration.html>`_
