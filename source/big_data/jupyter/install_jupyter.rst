.. _install_jupyter:

================
Jupyter安装
================

安装
=======

.. note::

   参考 `Installing the Jupyter Notebook <https://jupyter.org/install.html>`_

官方推荐使用 `Anaconda Distribution <https://www.anaconda.com/downloads>`_ (Python/R数据科学平台)安装，因为这个安装方式包含了Python, Jupyter Notebook以及常用的科学计算和数据科学的软件包。这样安装以后只需要直接运行就可以::

   jupyter notebook

使用pip安装
============

建议使用Python 3的 :ref:`virtualenv` ，以下实践在 :ref:`priv_cloud_infra` 的 ``z-dev`` ( :ref:`fedora` )完成

- Fedora作为开发环境，默认已经安装了 ``python3`` ``python3-pip`` 可以直接使用模块::

   python3 -m pip
   python3 -m venv

- :ref:`ubuntu_linux` 平台通过以下命令安装 pip 和 venv 模块::

   sudo apt install python3-pip python3-venv

- 创建Python3虚拟环境 ``virtualenv`` ::

   cd ~
   python3 -m venv venv3

- 切换到Python virtualenv环境::

   source venv3/bin/active

- 升级pip::

   pip install --upgrade pip

安装JupyterLab
-------------------

- 使用pip安装 JupyterLab::

   pip install jupyterlab

- 安装以后命令运行::

   jupyter-lab

此时会提示访问服务器的URL，注意访问是通过 ``localhost`` 本地回环地址访问，所以建议采用 :ref:`priv_ssh` 中 :ref:`ssh_proxycommand` 方法访问:

.. literalinclude:: ../../real/priv_cloud/priv_ssh/config
   :language: bash
   :caption: 用户目录配置SSH ~/.ssh/config

安装Jupyter Notebook
-------------------------

- 使用pip安装 Jupyter Notebook::

   pip install notebook

- 然后运行::

   jupyter notebook

安装Voilà
------------

- 使用pip安装 Voilà::

   pip install voila

使用
=======

JupyterLab 和 Jupyter Notebook的功能相同，运行启动都是监听在 ``http://localhost:8888`` ，并打开浏览器提供交互界面，可以选择其一运行，并开始下一阶段开发学习。
