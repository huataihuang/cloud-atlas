.. _pi_golang:

=================
树莓派Go语言环境
=================

我现在使用 :ref:`pi_400` 作为工作平台，在编译安装 :ref:`vim` 的插件 ``YouCompleteMe`` 时候发现，如果要支持GoLang，需要使用 1.13 版本golang。但是Raspberry Pi OS发行版提供的GoLang版本较为陈旧，无法完成安装。

Go语言发展迅速，很多bug在新版本得到修复，并且新版本往往提高了运行效率。所以，最好的安装方式是采用 `golang官方 <https://golang.org/>`_ 发布版本。

从管发可以下载到针对不同平台的预编译二进制执行程序，解压缩复制到执行路径中就可以完成安装。

- 也可以使用安装脚本 ``go_installer.sh`` :

.. literalinclude:: pi_golang/go_install_sh
      :language: bash
      :linenos:
      :caption:

执行 ``./go_installer.sh`` 完成安装。

- 然后配置 ``~/.proile`` 添加::

   PATH=$PATH:/usr/local/go/bin
   GOPATH=$HOME/go

如果你已经配置好 :ref:`vim` ，就可以开始开发GoLang程序了。   

参考
=====

- `A Better way to install Golang (Go) on Raspberry Pi <https://www.e-tinkers.com/2019/06/better-way-to-install-golang-go-on-raspberry-pi/>`_
