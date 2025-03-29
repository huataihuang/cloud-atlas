.. _python_env_tools:

=====================
Python环境工具
=====================

我在 :ref:`homebrew_python` 实践时注意到，官方文档 `Homebrew Documentation: Python <https://docs.brew.sh/Homebrew-and-Python>`_ 提到:

**Important: Python may be upgraded to a newer version at any time. Consider using a version manager such as pyenv if you require stability of minor or patch versions for virtual environments.**

也就是说， :ref:`homebrew` 并不会pin住Python版本，随时可能会进行版本升级。这对于生产环境来说，需要确保稳定的模块兼容性，是有特定版本要求的。正是因为这个需求，催生出类似 :ref:`ruby_version_manager` 一样的Python版本管理工具 ``pyenv`` 。

现在我们来理清一些Python环境工具的关系:

- ``venv`` : 从Python 3.3开始的最新版本，提供了内建的 ``venv`` 模块，默认安装，提供了类似 :ref:`virtualenv` 的隔离Python环境
- ``pyvenv`` : 从Python 3.3开始，提供了 ``pyvenv`` **脚本** 来帮助创建不同环境， ``pyvenv`` 实际上是 ``venv`` 模块的一个包装，提供了 ``venv`` 相同功能(也就是说，你直接使用 ``venv`` 模块就可以了)
- ``pyenv`` 是一个第三方工具，用于在统一个主机上安装管理多个Python版本以及创建虚拟环境。 ``pyenv`` 和 ``venv`` 或 ``pyvenv`` 没有关系，但是提供了相似的功能
- ``virtualenv`` 是一个第三方工具，用于创建隔离的虚拟环境。不过Python默认不安装 ``virtualenv`` ，你需要通过 ``pip`` 手工安装
- ``virtualenvwrapper`` 是一系列shell脚本用来在 ``virtualenv`` 上提供附加功能。 ``virtualenvwrapper`` 可以管理多个虚拟环境并且提供一些附加功能，如对于部分项目使用特定的虚拟环境
- ``pipenv`` 是结合了 ``virtualenv`` 和 ``pip`` 的工具，允许微怒项目创建虚拟环境和管理Python包，这个工具设计成比直接使用 ``virtualenv`` 和 ``pip`` 更方便

.. note::

   `GitHub: pyenv/pyenv <https://github.com/pyenv/pyenv>`_ 是从 ``rbenv`` 和 ``ruby-build`` fork出来的项目，并使用Python做了修改

总之，如果作为底层使用，你需要使用:

- ``pyenv`` 来安装和管理多个Python版本以适应开发、测试、生产环境: 

  - 为每个项目制定运行的Python版本
  - 为每个用户指定全局的Python版本
  - 只需要一个环境变量就可以覆盖默认Python版本(切换到指定Python版本)
  - 一次性从Python的多个版本搜索命令，这对于 ``tox`` 这样的Python自动化标准测试非常有用( `OpenStack使用tox完成单元测试 <https://wiki.openstack.org/wiki/Testing>`_ )

- ``venv`` 来构建Python的隔离虚拟环境(结合 ``pyenv`` 可以构建不同的版本环境)

使用 ``pyenv`` 管理Python版本
==============================

- 安装 ``pyenv`` :

.. literalinclude:: python_env_tools/pyenv
   :caption: 安装 ``pyenv``

- 使用 ``pyenv`` 安装指定版本:

.. literalinclude:: python_env_tools/pyenv_install_python
   :caption: ``pyenv`` 安装python

- 查看当前可用版本:

.. literalinclude:: python_env_tools/pyenv_versions
   :caption: 查看当前可用版本

- 注意通过 ``pyenv`` 安装python之后，需要调整环境变量 ``PATH`` :

.. literalinclude:: python_env_tools/pyenv_path
   :caption: 设置pyenv的PATH环境变量(这里以 zsh 为例，设置 ``~/.zshrc`` )

再次启动终端，使用 ``whic python`` 就可以看到:

.. literalinclude:: python_env_tools/pyenv_python
   :caption: ``pyenv`` 设置的路径中优先级python
   :emphasize-lines: 2,5

- 设置全局版本:

.. literalinclude:: python_env_tools/pyenv_global
   :caption: 使用 ``pyenv`` 设置全局优先版本

参考
======

- `What is the difference between venv, pyvenv, pyenv, virtualenv, virtualenvwrapper, pipenv, etc. <https://betterstack.com/community/questions/what-are-differences-between-python-virtual-environments/>`_
- `Pipenv & Virtual Environments <https://docs.python-guide.org/dev/virtualenvs/>`_
- `GitHub: pyenv/pyenv <https://github.com/pyenv/pyenv>`_
- `How to Install Python 3 on Mac – Brew Install Update Tutorial <https://www.freecodecamp.org/news/python-version-on-mac-update/>`_
