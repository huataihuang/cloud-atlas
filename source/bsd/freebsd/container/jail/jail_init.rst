.. _jail_init:

=======================
Jail环境初始化
=======================

和 :ref:`freebsd_init` 类似，在 :ref:`thin_jail` 环境中按照自己的要求进行初始安装

.. note::

   这里安装命令假设Jail名字是 ``dev``

   所有需要安装的软件包名字或版本可以通过 ``pkg search XXX`` 关键字来找到

ssh初始化
=============

为方便进入容器，并且以 ``admin`` 普通用户进入，为后续开发环境构建提供通用平台

- 在 ``dev`` jail中创建用户组和用户 admin:

.. literalinclude:: jail_init/user
   :caption: 在jail内部创建admin

在 ``dev`` 主机的用户 ``admin`` 添加ssh key，现在就可以像普通虚拟机一样远程ssh登录到容器内部了

devops初始化
===============

安装必要运维工具:

.. literalinclude:: jail_init/devops
   :caption: 安装运维工具

python初始化
===============

- 安装python和pip:

.. literalinclude:: jail_init/python
   :caption: 安装python

- Python :ref:`virtualenv` :

.. literalinclude:: jail_init/virtualenv
   :caption: python :ref:`virtualenv`

.. note::

   ``d2l`` :ref:`virtualenv` 环境就绪后，开始部署 :ref:`dl_env` 以便进一步学习实践 :ref:`deep_learning`

参考
========

- `Setting up a Python Development Environment in FreeBSD - A Complete Guide <https://www.pythonhelp.org/learn/introduction/setting-up-development-environment-freebsd/>`_
