.. _using_modules_and_packages_in_go:

===========================================
在Go语言中使用模块(Modules)和包(Packages)
===========================================

``GO111Module``
================

在 Go 1.15 以及早期版本， ``GO111Module`` 默认设置为 ``auto`` 。这意味着，如果项目目录(或任何父目录)包含一个 ``go.mod`` 文件，则被视为一个模块(module)。甚至在使用传统的 ``GOPATH`` 模式。

在 Go 1.16 ，这个模块感知模式被切换成 ``GO111MODULE=on`` ，对使用第三方模块以及自己编写的模块有如下影响:

参考
=======

- `Using Modules and Packages in Go - Learn what has changed in Go 1.16 <https://levelup.gitconnected.com/using-modules-and-packages-in-go-36a418960556>`_
