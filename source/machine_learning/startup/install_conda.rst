.. _install_conda:

===================
安装Conda
===================

Anaconda vs. Miniconda vs. Miniforge vs. Conda vs. pip
=========================================================

在 :ref:`install_anaconda` 之后提到本文的Conda，以及Miniconda，主要的区别有:

- Anaconda是一个软件发行版，预先建立和配置好软件包的集合，可以安装到操作系统并使用

  - Anaconda包含Python本身和数百个第三方开源二进制文件，如Conda, numpy, scipy, ipython等
  - Anaconda是Conda的超集，是一个大而全的发行版
  - Anaconda是Anaconda公司开发和维护的

- Miniconda 也是一个发行版，本质上是用来安装空的Conda环境的安装器

  - Miniconda仅包含Conda和Conda的依赖，所以并不像Anaconda那么全面和庞大
  - 可以自己定义安装需要的东西
  - Conda默认的channel不是完全开源的

- Miniforge 是 conda-forge 社区开发和维护的安装器，使用了社区自己的 conda-forge channel (以摆脱Anaconda公司不开源Channel的依赖) 

  - Miniforge使得conda的打包和分发完全开源

- Conda 是一个包和环境管理工具(非常类似pip，但仅针对conda及其依赖)

  - Conda可以自动安装、升级和删除包
  - Conda管理的是二进制包（任何语言的二进制），不需要编译器

- pip 是Python包的通用管理器，可以在任何环境中安装包，但是只能安装Python包

  - 如果需要安装依赖外部dependencies的Python包(例如NumPy, SciPy 和 Matplotlib)，或者要跟踪这些包的外部依赖，那么不能使用pip，因为pip只管理Python包

安装Conda
===========

安装Conda有 ``3种`` 方法:

- Miniconda
- Anaconda Distribution
- Miniforge

.. note::

   Miniconda和Anaconda Distribution默认配置使用Anaconda仓库，并且从该仓库安装和使用软件包受到Anaconda服务条款乐素，意味着可嫩需要商业费用许可证。

.. note::

   Conda只提供Linux/Windows/macOS的安装，所以 :ref:`install_conda_freebsd` 需要通过Linux兼容系统来运行

我在 :ref:`dl_env` 使用了 :ref:`freebsd` :ref:`linux_jail` 运行环境来安装Coda，也就是容器環境的 :ref:`debian` ，選擇 ``Miniconda``

系統要求
-----------

- Conda支持操作系統:

  - :ref:`windows`
  - :ref:`macos`
  - :ref:`linux`

- 磁盤空間需求:

  - Miniconda 或 Miniforge: 400MB
  - Anaconda: 3GB

- Python版本要求: Python 3.9或以上

.. note::

   实际上 Conda 是一个完整的运行环境，自己带了Python。从 `Anaconda Download <https://www.anaconda.com/download/success>`_ 官方下载的安装包解压缩以后在用户目录下形成了一个 ``~/conda`` (我指定该安装目录)，其中就包含了自带的 ``Python 3.12.8`` 。也就是官方下载安装上注明的Python版本。

   也就是说，实际上运行主机不需要安装Python， ``Conda`` 环境完整提供了运行所需的一切，只不过 ``Conda`` 是编译好的二进制执行环境，就类似于 :ref:`docker` 这样的自包含All的运行环境。

安裝
-------

`Anaconda Download <https://www.anaconda.com/download/success>`_ 提供了Anaconda和Miniconda安裝下載(腳本)

.. literalinclude:: install_conda/install_miniconda
   :caption: 安裝miniconda

在同意了license之后，按照提示进行安装

.. literalinclude:: install_conda/install_miniconda_interact
   :caption: 交互方式安装
   :emphasize-lines: 11,26

注意，我这里最后让conda安装程序自动修改用户shell profile，这样 ``/home/admin/.bashrc`` 会自动加入以下内容:

.. literalinclude:: install_conda/bashrc_conda
   :language: bash
   :caption: Miniconda自动修改 ``~/.bashrc``

.. note::

   如果安装最后步骤让conda安装程序自动修订 ``~/.bashrc`` ，那么下次登录系统是会自动进入 :ref:`virtualenv` 环境，此时就可以直接执行 ``conda`` 命令，例如 ``conda list`` 检查已经安装的conda组件。

参考
=======

- `Anaconda与conda、pip与conda的区别 <https://zhuanlan.zhihu.com/p/379321816>`_
- `Conda官网: User guide > Installing conda <https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html>`_
