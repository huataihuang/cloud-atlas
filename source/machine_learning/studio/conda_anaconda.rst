.. _conda_anaconda:

===========================
Conda和Anaconda
===========================

在机器学习领域，通常需要使用Python, R 以及各种依赖复杂的库程序，通过手工安装维护工作环境是非常困难的。通常我们会使用：

- Conda
- Anaconda

来管理和维护工作环境，部署软件包、依赖项和观景管理。

Conda
==========

.. figure:: ../../_static/machine_learning/studio/conda.png

Conda是适用于任何语言的软件包、依赖项和环境管理系统--包括Python，R，Ruby，Lua，Scala，Java，JavaScript，C / C ++，FORTRAN等。Conda可以快速安装、运行和更新软件包及其依赖项。Conda可以轻松地在本地计算机上的环境中创建，保存，加载和切换。它是为Python程序创建的，但可以打包和分发适用于任何语言的软件。

conda 和 pip 区别:

- pip仅面向python，允许你在任何环境中安装python包，而conda允许你在conda环境中安装任何语言包（包括c语言或者python）。
- Conda是一种包装工具和安装程序，其目标是比pip做更多的事情，处理Python包之外的库依赖关系以及Python包本身。Conda也像virtualenv一样创建虚拟环境。
- 如果需要许多依赖库一起很好地工作（比如数据分析中的Numpy，scipy，Matplotlib等等）那你就应该使用conda，conda很好地整合了包之间的互相依赖。
- 因为Conda引入了新的包装格式，所以pip与Conda不能互换使用； pip无法安装Conda软件包格式。可以使用并排的两个工具侧（通过 ``conda install pip`` 安装pip），但无论如何它们不具备互操作性。

Anaconda
===========

默认配置下，conda可以安装和管理来自repo.anaconda.com仓库的7,500多个软件包，该仓库由Anaconda生成，审查和维护。

Conda是一个辅助进行包管理和环境管理的工具。目前是Ananconda默认的Python包和环境管理工具，所以安装了Ananconda完整版，就默认安装了Conda。Conda既具有pip的包管理能力，同时也具有vitualenv的环境管理功能 ，因此在功能上Conda可以看作是pip 和 vitualenv 的组合。

在机器学习工作环境，通常会使用Anaconda来构建环境。因为Anaconda是一个完整的Python发行版，提供了提前编译和配置好的软件包集合， 装好了后就可以直接用。而 Conda是一个包管理器。

Anaconda发行版会预装很多pydata生态圈里的软件，而Miniconda是最小的conda安装环境， 一个干净的conda环境。不过，conda和Anaconda没有必然关系， 你可以不安装Anaconda的同时， 使用conda安装和管理软件。

.. note::

    虽然conda默认渠道没有完全开源，但是有一个社区牵头的conda-forge，它会推动conda的包和发行版完全开源。

参考
=======

- `Anaconda系列：conda是什么？conda与pip的区别是什么？ <https://blog.csdn.net/zhanghai4155/article/details/104215198>`_
- `关于conda和anaconda不可不知的事实和误解-conda必知必会 <http://nooverfit.com/wp/关于conda和anaconda不可不知的事实和误解-conda必知必会/>`_
