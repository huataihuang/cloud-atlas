.. _go_on_macos:

=====================
macOS 环境Go
=====================

.. _multi_golang_with_homebrew:

:ref:`homebrew` 安装多个Go版本
=================================

我在项目中遇到管理第三方包的依赖问题，由于是老项目，公司同事告知我使用 :ref:`go_vendor` 管理，但是我尝试自动安装第三方模块并没有成功。

我怀疑可能和 :ref:`using_modules_and_packages_in_go` 中提到的从 Go 1.16 开始，使用了 ``go mod`` 管理依赖，所以采用 :ref:`go_vendor` 配置没有生效。不过，既然可以使用 :ref:`homebrew` 安装Golang，那么尝试回滚到旧版本试试。

- 搜索可用的Go版本::

   brew search go

可以看到提供了多个版本::

   ==> Formulae
   go ✔
   go@1.13
   go@1.14
   go@1.15
   go@1.16
   go@1.17
   go@1.18
   go@1.19

- 安装指定版本:

.. literalinclude:: ../apple/macos/install_disabled_homebrew_package/brew_install_go_1.15
   :caption: 安装低版本GoLang 1.15

可能会提示错误:

.. literalinclude:: ../apple/macos/install_disabled_homebrew_package/brew_install_go_1.15_error
   :caption: 安装低版本GoLang 1.15报错

解决方法采用 :ref:`install_disabled_homebrew_package`

- 对于多版本，需要取消最新版本的链接::

   brew unlink go

- 然后链接到指定版本::

   brew link go@1.15

必要时可以采用 ``--force`` 或 ``--overwrite`` 参数::

   brew link --force --overwrite go@1.15

参考
========

- `Manage multiple versins of Go on MacOS with Homebrew <https://gist.github.com/BigOokie/d5817e88f01e0d452ed585a1590f5aeb>`_
