.. _go_on_arch_linux:

======================
arch linux环境Go语言
======================

安装
======

- 使用 :ref:`pacman` 安装::

   sudo pacman -S go

- 在 ``~/.bashrc`` 中配置::

   export PATH="$PATH:$(go env GOBIN):$(go env GOPATH)/bin"

参考
=====

- `arch linux: Go <https://wiki.archlinux.org/title/Go>`_
