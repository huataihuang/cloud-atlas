.. _jail_init:

=======================
Jail环境初始化
=======================

和 :ref:`freebsd_init` 类似，在 :ref:`thin_jail` 环境中按照自己的要求进行初始安装

.. note::

   这里安装命令假设Jail名字是 ``dev``

   所有需要安装的软件包名字或版本可以通过 ``pkg search XXX`` 关键字来找到

针对jail的安装命令是: ``pkg -j <jail_name> install <package_name_list>`` ，所以为了方便执行，可以先设置 ``alias`` :

.. literalinclude:: jail_init/alias
   :caption: 设置alias

这样本文后续执行的安装命令就可以直接借用 :ref:`freebsd_init` 以及 :ref:`freebsd_programming_tools` 中相对应的命令。

devops初始化
===============

安装必要运维工具:

.. literalinclude:: ../../startup/freebsd_init/devops
   :caption: 安装运维工具

ssh初始化
=============

- 在 ``mdev`` jail中创建用户组和用户 admin:

.. literalinclude:: ../../startup/freebsd_init/user
   :caption: 在jail内部创建admin

在 ``dev`` 主机的用户 ``admin`` 添加ssh key，现在就可以像普通虚拟机一样远程ssh登录到容器内部了

部署开发环境
===============

- 在 ``dev`` jail中安装所有使用的开发工具:

.. literalinclude:: ../../program/freebsd_programming_tools/install
   :caption: 安装开发工具

构建 :ref:`nvim_ide`
=======================

- 首先构建 :ref:`freebsd_programming_tools` 环境

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
