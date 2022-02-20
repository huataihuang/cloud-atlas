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

使用pip安装Jupyter
--------------------

我个人使用的是Python 3的虚拟环境，所以先切换到Python virtualenv环境，然后直接通过pip安装::

   pip install --upgrade pip
   pip install jupyter

安装以后再执行命令运行::

   jupyter notebook

使用
=======

- 基本使用方法就是直接启动notebook server::

   jupyter notebook

此时会启动Jupyter Notebook Server，监听在 ``http://localhost:8888`` ，并打开浏览器提供交互界面，看到的是Notebook Dashbook。
