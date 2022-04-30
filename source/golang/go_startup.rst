.. _go_startup:

================
Go快速起步
================

``go env``
============

通过 ``go env`` 可以看到 Go 的全部环境变量::

   go env

例如:

.. literalinclude:: go_startup/go_env
   :language: bash
   :caption: go env输出Go的环境变量

github
---------

``go env`` 中 ``GOPATH`` 变量设置了源代码存目录，这个目录和github对应::

   GOPATH="/home/huatai/go"

则执行 ``go get`` 命令会把 github 对应代码仓库取下来存放到这个目录的子目录 ``src`` 中

举例 《Go语言程序设计》 的代码仓库是 https://github.com/adonovan/gopl.io/

执行::

   go get gopl.io/ch1/helloworld

则会 ``git clone https://github.com/adonovan/gopl.io/`` 到 ``/home/huatai/go/src`` 目录下，然后编译 ``gopl.io/ch1/helloworld`` 输出到 ``/home/huatai/go/bin`` 目录下生成二进制可执行程序 ``helloworld``



参考
=======

- `Go 学习笔记（2）— 安装目录、工作区、源码文件和标准命令 <https://blog.csdn.net/wohu1104/article/details/97966685>`_
- 《Go语言程序设计》
