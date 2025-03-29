.. _migrate_go_modules:

==========================
迁移Go Modules管理包依赖
==========================

早期Go项目使用了不同的依赖管理方式，例如流行的 :ref:`go_vendor` ，以及 `dep <https://github.com/golang/dep>`_ 或 `glide <https://github.com/Masterminds/glide>`_ 。到那时这些工具工作原理不同，也很难协同工作。一些项目将整个 :ref:`gopath` 目录存放到单一Git仓库，另一些则简单依赖 ``go get`` 并希望获取正确的最新版本依赖安装到 :ref:`gopath` 。

从Go 1.11 引入的 :ref:`go_modules` 提供了官方的依赖管理解决方案，而且嵌入在 ``go`` 命令中。

.. warning::

   根据 `kardianos/govendor <https://github.com/kardianos/govendor>`_ 官方说明，从go1.14开始 Go modules已经达到产品级别(可以以用于1.13和1.12)，除非你的go版本低，否则应该使用 :ref:`go_modules` 。Go Vendor官方已经不建议使用自身这个工具(官方2016年9月以后不在发布新版)
   
转换Go Modules
==================

在现有项目上，例如使用 :ref:`go_vendor` 管理依赖，可以使用以下方法轻松转换( **在项目目录下执行** ):

.. literalinclude:: migrate_go_modules/go_mod
   :caption: 执行 ``go mod`` 命令转换项目依赖管理方式

``go mod tidy`` 找出所有模块中的包进行导入

完成之后就可以进行buid和测试了::

   go build
   go test

问题排查
==========

我这里遇到一个问题， ``go mod tidy`` 提示报错::

   go: k8s.io/kubernetes@v1.18.20 requires
    k8s.io/api@v0.0.0: reading k8s.io/api/go.mod at revision v0.0.0: unknown revision v0.0.0

参考 `go get fails with "unknown revision v0.0.0" #1197 <https://github.com/GoogleCloudPlatform/spark-on-k8s-operator/issues/1197>`_ 在 ``go.mod`` 中指定 ``k8s.io/api`` 版本::

   k8s.io/api v0.18.20

.. note::

   ``client-go`` 版本: 对于Kubernetes >= ``v1.17.0`` ，需要使用对应的 ``v0.x.y`` 。例如， ``k8s.io/client-go@v0.20.4`` 对应 Kubernetes ``v1.20.4`` 。由于我这里使用Kubernetes v1.18.20 ，所以我在 ``go.mod`` 中对应版本就是 ``v0.18.20``

参考
========

- `Migrating to Go Modules <https://go.dev/blog/migrating-to-go-modules>`_
