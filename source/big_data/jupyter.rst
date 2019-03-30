.. _jupyter:

================
Jupyter
================

`Jupyter Notebook <https://jupyter.org>`_ 是一个开源的web应用，用于创建和共享文档，支持交互编码，公式，可视化以及描述文本。Jupyter Notebook 已迅成为速数据分析，机器学习的必备工具。因为它可以让数据分析师集中精力向用户解释整个分析过程。

Jupyter这个名字是它要服务的三种语言的缩写：Julia，PYThon和R，这个名字与“木星（jupiter）”谐音。

.. image:: ../_static/big_data/jupyter.png
   :scale: 75

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

slideshow
============

`RISE <https://github.com/damianavila/RISE>`_ 可以将Jupyter Notebook转换成slideshow，并且能耦在浏览器中执行代码加护演示。以下是一个演示gif:

.. image:: ../_static/big_data/jupyter_slideshow.gif

安装
------

- 使用pip安装::

   pip install RISE

- 在文档目录安装JS和CSS::

   jupyter-nbextension install rise --py --sys-prefix

- 切换到根目录再次执行启动jupyter notebook::

   jupyter notebook

.. note::

   PegasussWang有一个 `案例notebook <https://github.com/PegasusWang/notebooks>`_ 可以参考。

参考
=========

- `Jupyter Notebook 有哪些奇技淫巧？ <https://www.zhihu.com/question/266988943>`_
- `jupyter notebook 可以做哪些事情？ <https://www.zhihu.com/question/46309360>`_
- `Jupyter Notebook介绍、安装及使用教程 <https://www.jianshu.com/p/91365f343585>`_
- `Jupyter Notebook 快速入门 <https://www.cnblogs.com/nxld/p/6566380.html>`_
