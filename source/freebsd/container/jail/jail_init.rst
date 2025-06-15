.. _jail_init:

=======================
Jail环境初始化
=======================

和 :ref:`freebsd_init` 类似，在 :ref:`thin_jail` 环境中按照自己的要求进行初始安装

.. note::

   这里安装命令假设Jail名字是 ``dev``

   所有需要安装的软件包名字或版本可以通过 ``pkg search XXX`` 关键字来找到

安装sudo
===========

为方便进入容器，并且以 ``admin`` 普通用户进入，为后续开发环境构建提供通用平台

- jail中需要安装 ``sudo``

.. literalinclude:: jail_init/sudo
   :caption: 为 ``dev`` jail 安装sudo

我在 :ref:`vnet_thin_jail`  部署NullFS的 ``dev`` Jail，但是执行上述jail安装软件包报错

.. literalinclude:: jail_init/install_error
   :capiton: 安装报错

我遇到过在jail内部尝试运行 ``pkg install sudo`` ，发现需要更新 ``pkg`` ，但是似乎 ``/usr/src`` 目录导致错误:

.. literalinclude:: jail_init/install_error_in_jail
   :caption: 在jail内部安装报错

我初步排查感觉上述报错的原因是 ``/var``` 目录损坏了( :ref:`vnet_thin_jail` )，但是我解决了这个问题之后发现还是同样都报错。

再排查发现，原来是 ``NullFS`` 的Thin Jail构建的移动 ``/etc`` 目录到 ``skeleton/etc`` 之后，所有在 ``/etc/ssl/certs`` 目录下原先的软连接到 ``../../../usr/share/certs/trusted/`` 目录下的证书的连接全部失效了。非常奇怪:

.. literalinclude:: jail_init/link_error
   :caption: ``/etc/ssl/certs`` 目录下软连接失效

原因找到了，是因为原先 ``/etc/ssl/certs/`` 目录下的软链接都是相对链接，当 ``/etc`` 目录被移动到 ``skeleton`` 目录下之后，这个相对软链接就失效了

我简单编写了一个fix脚本

.. literalinclude:: jail_init/fix_link.sh
   :caption: 修复软链接的脚本

修复以后 ``skeleton/etc/ssl/cets/`` 目录下的软链接应该类似如下:

.. literalinclude:: jail_init/link_ok
   :caption: 修复以后的软链接

ssh初始化
=============

- 在 ``dev`` jail中创建用户组和用户 admin:

.. literalinclude:: jail_init/user
   :caption: 在jail内部创建admin

在 ``dev`` 主机的用户 ``admin`` 添加ssh key，现在就可以像普通虚拟机一样远程ssh登录到容器内部了

devops初始化
===============

安装必要运维工具:

.. literalinclude:: jail_init/devops
   :caption: 安装运维工具

构建 :ref:`nvim_ide`
=======================

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
