.. _python_in_rhel8:

===========================
在RHEL/CentOS 8中使用Python
===========================

当前Python 2已经中止支持，主流发行版已经转向默认使用Python 3。在Red Hat Enterprise Linux 8中，默认使用 Python 3.6，但是依然提供Python 2以便兼容。

Python 3
==========

- 安装Python::

   dnf install python3

- 运行python::

   python3

在RHEL 8中，默认使用Python 3.6，并且系统完全支持这个版本，但是有可能没有默认安装，所以需要使用上述命令安装。注意，所有相关Python 3的软件包都使用 ``python3-xxx`` 方式提供。

Python 2
===========

为了兼容旧版本软件，在安装了Python 3同时也可以安装Python 2，并且运行时使用命令 ``python2`` ::

   dnf install python2
   python2

"python"命令
==============

系统默认没有提供 ``python`` 命令，需要明确指定使用的python版本，例如 ``python3`` 或者 ``python2`` 。要使用 ``python`` 命令来指代特定版本的python，可以使用 ``alternative`` 机制，激活系统全局的统一版本::

   alternative --set python /usr/bin/python3

此时就可以使用 ``python`` 命令来使用 ``python3`` 。

但是建议使用明确的 ``python3`` 或者 ``python2`` 避免脚本或者命令无法兼容运行。

virtualenv 和 venv
====================

请注意，即使使用了 ``alternative`` 来设置 ``python`` 的引用，但是却不能使用 ``dnf install python-XXX`` 或者 ``pip`` 命令，这是因为必须在这种情况下显式说明版本。所以，安装pip或者virtualenv/venv，请使用以下方法::

   python3 -m pip
   python3 -m venv
   python2 -m virtualenv

参考
=====

- `Python in RHEL 8 <https://developers.redhat.com/blog/2018/11/14/python-in-rhel-8/>`_
- `Install Python 3 / Python 2.7 on CentOS 8 / RHEL 8 <https://computingforgeeks.com/how-to-install-python-3-python-2-7-on-rhel-8/>`_
