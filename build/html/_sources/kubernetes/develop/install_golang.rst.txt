.. _install_golang:

===============
安装 Go 语言包
===============

安装golang
============

从 `golang Getting Started <https://golang.org/doc/install>`_ 下载对应平台的Go语言软件包，然后通过以下命令解压缩安装::

   tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz

- macOS平台提供了pkg包，可以直接下载安装 - 通过pkg安装有一个便利之处是安装会自动清理掉旧版本并安装上新版本，安装目录位于 ``/usr/local/go`` 目录，所以请将路径 ``/usr/local/go/bin`` 加入到 ``PATH`` 环境变量，以便找到 ``go`` 命令。

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

   .. figure:: ../../_static/kubernetes/develop/go_create_dep_project.png
      :scale: 40

参考
========

- `golang Getting Started <https://golang.org/doc/install>`_
- `dep installation <https://golang.github.io/dep/docs/installation.html>`_
- `GoLand - Creating a project with dep integration <https://www.jetbrains.com/help/go/creating-a-project-with-dep-integration.html>`_
