.. _virtualenv:

==================
Python virtualenv
==================

pip是Python包管理器，用于安装和更新软件包，需要确保系统已经安装了最新版本的pip。

使用pip可以安装Python虚拟环境管理器：对于Python 3使用venv，对于Python 2使用virtualenv。

pip
=========

Ubuntu/Debian安装pip和venv
----------------------------

在 :ref:`pi_400` 作为日常开发环境，ARM架构的Ubuntu/Debian安装pip3::

   apt install python3-pip
   apt install python3-venv

在 :ref:`ubuntu_linux` 22.04 LTS则安装 ``python3-virtualenv`` :

.. literalinclude:: virtualenv/ubuntu_virtualenv
   :language: bash
   :caption: 在 :ref:`ubuntu_linux` 22.04 LTS 安装 ``python3-virtualenv``

如果安装pip2则执行::

   apt install python-pip

.. note::

   在 :ref:`django_env` 同样也使用virtualenv来构建Django开发环境

arch安装pip和venv
--------------------

- 默认python即是python3，安装 ``python-pip`` 软件包::

   pacman -S python-pip

Python 2 virtualenv
====================

CentOS 7通过Yum安装（EPEL源）
------------------------------

- 安装::

   yum -y update
   yum -y install python-pip

   pip2 install virtualenv
   virtualenv venv2

古老CentOS 7安装使用virtualenv
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

在非常古老的CentOS 7版本上安装virtualenv会遇到更多麻烦:

- CentOS 7.2上执行 ``virtualenv venv2`` 会出现一下报错::

   Traceback (most recent call last):
     File "/bin/virtualenv", line 7, in <module>
       from virtualenv.__main__ import run_with_catch
     File "/usr/lib/python2.7/site-packages/virtualenv/__init__.py", line 3, in <module>
       from .run import cli_run, session_via_cli
     File "/usr/lib/python2.7/site-packages/virtualenv/run/__init__.py", line 7, in <module>
       from ..app_data import make_app_data
     File "/usr/lib/python2.7/site-packages/virtualenv/app_data/__init__.py", line 9, in <module>
       from platformdirs import user_data_dir
   ImportError: No module named platformdirs   

这是因为操作系统自带的 ``pip2`` 版本过于陈旧，甚至直接执行 ``pip2.7 install --upgrade pip`` 都会报错::

   You are using pip version 7.1.0, however version 21.3.1 is available.
   You should consider upgrading via the 'pip install --upgrade pip' command.
   Collecting pip
     Using cached https://files.pythonhosted.org/packages/da/f6/c83229dcc3635cdeb51874184241a9508ada15d8baa3
   37a41093fab58011/pip-21.3.1.tar.gz
       Complete output from command python setup.py egg_info:
       Traceback (most recent call last):
         File "<string>", line 20, in <module>
         File "/tmp/pip-build-wfciDf/pip/setup.py", line 7
           def read(rel_path: str) -> str:
                            ^
       SyntaxError: invalid syntax
       
       ----------------------------------------
   Command "python setup.py egg_info" failed with error code 1 in /tmp/pip-build-wfciDf/pip 

- 解决的方法是手工下载安装pip的脚本::

   curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
   sudo python get-pip.py

- 通过手工升级 ``pip`` 之后，再次安装virtuualenv环境就可以成功::

   sudo pip2.7 install virtualenv
   virtualenv venv2

CentOS 8通过dnf安装python 2virtualenv
----------------------------------------

.. note::

   CentOS/RHEL 8默认使用Python 3，请参考 :ref:`python_in_rhel8`

- 安装python 2 (默认CentOS 8只安装python 3)::

   sudo dnf install python2

- 安装python2的virtualenv::

   cd ~
   python2 -m virtualenv venv2 

- 激活virtualenv::

   source venv2/bin/active
   # 检查版本
   python --version
   # 离开virtualenv沙箱
   deactive

Python 3 venv
====================

- :ref:`python_in_rhel8` 默认安装Python 3，或者在Ubuntu/Debian系统中按照上文方法完成 ``pip3`` 和 ``venv`` 安装，或者 :ref:`arch_linux` 系统中已经完成 ``pip`` 安装，所以构建虚拟沙箱环境非常简单:

.. literalinclude:: virtualenv/venv
   :language: bash
   :caption: venv初始化

- 激活:

.. literalinclude:: virtualenv/venv_active
   :language: bash
   :caption: 激活venv

.. note::

   我使用 :ref:`kali_linux` 作为开发环境，采用上述方式完成环境设置。


- 一段时间之后，可能需要升级pip以及安装的所有软件包:

.. literalinclude:: virtualenv/pip_upgrade
   :language: bash
   :caption: 升级pip以及所有已安装软件包

参考
=====

- `How to Install Pip on CentOS 7 <https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/>`_
- `Installing packages using pip and virtual environments <https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/>`_
