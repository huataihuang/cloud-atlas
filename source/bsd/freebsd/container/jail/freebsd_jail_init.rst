.. _freebsd_jail_init:

=======================
FreeBSD Jail环境初始化
=======================

和 :ref:`freebsd_init` 类似，在 :ref:`freebsd_thin_jail` 环境中按照自己的要求进行初始安装

.. note::

   这里安装命令假设Jail名字是 ``dev``

   所有需要安装的软件包名字或版本可以通过 ``pkg search XXX`` 关键字来找到

ssh初始化
=============

为方便进入容器，并且以 ``admin`` 普通用户进入，为后续开发环境构建提供通用平台

devops初始化
===============

安装必要运维工具:

.. literalinclude:: freebsd_jail_init/devops
   :caption: 安装运维工具

python初始化
===============

- 安装python和pip:

.. literalinclude:: freebsd_jail_init/python
   :caption: 安装python

参考
========

- `Setting up a Python Development Environment in FreeBSD - A Complete Guide <https://www.pythonhelp.org/learn/introduction/setting-up-development-environment-freebsd/>`_
