.. _fedora_dev_python:

==========================
Fedora环境开发Python应用
==========================

Fedora发行版默认预装了Python 3，所以开发环境主要集中在如何设置 :ref:`virtualenv` 以及结合 :ref:`vscode_virtualenv`

使用pip
========

对于Fedora发行版没有打包的Python包，或者你需要在一个隔离环境中使用Python，就可以使用 ``pip`` 从 `Python Package Index (PyPI) <https://pypi.python.org/>`_ 安装Python包。

.. warning::

   从 ``PyPI`` 安装的软件包不属于Fedora发行版维护，软件质量不同，安全性和licensing也不同，任何人都能够向 ``PyPI`` 上传Python包，所以一定要安装自己信任的软件包。 ``并且在安装前反复确认软件包名`` ，避免误安装恶意软件。

可以通过在虚拟环境中安装模块，或者在自己的home目录中使用 ``--user`` 命令切换用户。

在虚拟环境使用pip
-------------------

- 建议按照项目来构建 :ref:`virtualenv` (假设这里项目名称 ``pia`` )::

   python -m venv pia_venv

目录建议以 ``project_env`` 

- 激活 ``virtualenv`` ::

   source pia_venv/bin/activate

- 然后安装需要的模块 ``pip install`` 案例为 :ref:`redis_dev` ::

   python -m pip install redis

- 完成开发结束工作，可以退出 :ref:`virtualenv` ::

   deactivate

指定用户安装
---------------

如果不使用虚拟环境，但是也没有系统级别权限(需要 ``roo`` 权限)，可以使用 ``pip`` 来安装到个人目录::

   sudo dnf install python3-pip

- 使用 ``--user`` 选项来安装需要的Python包，则会安装到个人目录下::

   python -m pip install --user redis

更新Python包
---------------

由于 ``pip`` 安装的Python包不是由Fedora维护，所以需要使用 ``pip`` 的 ``install`` 命令的 ``--update`` 选项来更新::

   python -m pip install --upgrade redis

开发框架
==========

- :ref:`django`

参考
====

- `Fedora developer Python <https://developer.fedoraproject.org/tech/languages/python/python-installation.html>`_
