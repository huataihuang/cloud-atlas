.. _go_vendor:

===================
Go Vendor包管理器
===================

在 :ref:`gopath` 中介绍了Go语言最新的Go Modules管理 ``$GOPATH`` 的方法。不过，在Go Modules出现之前，还有一个常用且现在依然在使用的 ``vendor`` 管理方式。

基于vendor机制下，在执行 ``go build`` 或 ``go run`` 命令时，会按照以下顺序去查找包：

- 当前包下的 ``vendor`` 目录
- 向上级目录查找，直到找到 ``src`` 下的 ``vendor`` 目录
- 在 ``GOROOT`` 目录下查找
- 在 ``GOPATH`` 下面查找依赖包

govendor 是一个基于 vendor 目录机制的包管理工具:

- 支持从项目源码中分析出依赖的包，并从 ``$GOPATH`` 复制到项目的 ``vendor`` 目录下
- 支持包的指定版本，并用 ``vendor/vendor.json`` 进行包和版本管理,在json文件可以清晰看到引入的依赖包目录
- 支持用 ``govendor add/update`` 命令从 ``$GOPATH`` 中复制依赖包
- 如果忽略了 ``vendor`` 文件，可用 ``govendor sync`` 恢复依赖包
- 可直接用 ``govendor fetch`` 添加或更新依赖包
- 可用 ``govendor migrate`` 从其他 ``vendor`` 包管理工具中一键迁移到 ``govendor``
- 支持 Linux，macOS，Windows所有操作系统

安装
=======

::

   go install github.com/kardianos/govendor@lastest

初始化
==========

- 进入Go项目目录下，然后执行 ``govendor init`` 初始化
- 项目根目录下即会自动生成 ``vendor`` 目录和 ``vendor.json`` 文件

常用命令
==========

- 将已被引用且在 $GOPATH 下的所有包复制到 vendor 目录::

   govendor add +external

- 从 ``$GOPATH`` 中复制指定包到 ``vendor`` 目录::

   govendor add github.com/golang/protobuf

- 列出代码中所有被引用到的包及其状态::

   govendor list

- 列出一个包被哪些包引用::

   govendor list -v fmt

- 从远程仓库添加或更新某个包(不会在 $GOPATH 也存一份)::

   govendor fetch golang.org/x/net/context

- 安装指定版本的包::

   govendor fetch golang.org/x/net/context@a4bbce9fcae005b22ae5443f6af064d80a6f5a55
   govendor fetch golang.org/x/net/context@v1   # Get latest v1.*.* tag or branch.
   govendor fetch golang.org/x/net/context@=v1  # Get the tag or branch named "v1".

- 只格式化项目自身代码(vendor 目录下的不变动)::

   govendor fmt +local

- 只构建编译项目内部的包::

   govendor install +local

- 只测试项目内部的测试案例::
  
   govendor test +local

- 拉取所有依赖的包到 vendor 目录(包括 $GOPATH 存在或不存在的包)::

   govendor fetch +out

- 包已在 vendor 目录，但想从 ``$GOPATH`` 更新::

   govendor update +vendor

- 已修改了 ``$GOPATH`` 里的某个包，现在想将已修改且未提交的包更新到 ``vendor`` ::

   govendor update -uncommitted <updated-package-import-path>

- ``vendor.json`` 中记录了依赖包信息，拉取更新::

   govendor sync

一般使用经验
===============

- 对于现有项目，通常已经具备了 ``vendor/vendor.json`` ，则直接使用::

   govendor sync

不过，可能会提示::

   Username for 'https://gitlab.xxx.com':

这是因为 ``git`` 走了https协议来拉取，则会提示认证。如果你使用ssh key，则需要调整

参考
=====

- `【Go语言】：依赖管理之vendor和Go Modules <https://joyohub.com/go/go-dependency/>`_
- `Go Dependencies via govendor <https://devcenter.heroku.com/articles/go-dependencies-via-govendor>`_
- `Manage Go dependencies with govendor <https://doc.scalingo.com/languages/go/govendor>`_
