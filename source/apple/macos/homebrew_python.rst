.. _homebrew_python:

===================
Homebrew环境Python
===================

.. note::

   有关Python环境工具之间关系，见 :ref:`python_env_tools`

pyenv
========

``pyenv`` 可以管理主机上的多个Python版本，方便构建不同的开发、测试、生产环境。管理多版本最好使用它来完成:

.. literalinclude:: homebrew_python/install_pyenv
   :caption: 安装 ``pyenv``

- 使用 ``pyenv`` 安装指定Python版本:

.. literalinclude:: homebrew_python/pyenv_install_python
   :caption: ``pyenv`` 安装指定Python版本(这里假设我安装当前最新的稳定release版本3.12.4)

我这里遇到一个WARNING信息:

.. literalinclude:: homebrew_python/pyenv_install_python_output
   :caption: ``pyenv`` 安装指定Python版本输出信息
   :emphasize-lines: 11-13

- 可以使用 ``pyenv`` 安装多个Python版本，例如安装一个旧版本:

.. literalinclude:: homebrew_python/pyenv_install_python_2
   :caption: ``pyenv`` 安装指定Python 2版本

- 此时检查系统中安装的Python版本:

.. literalinclude:: homebrew_python/pyenv_versions
   :caption: 检查系统中通过 ``pyenv`` 安装的 Python 版本

注意，此时输出信息中显示 ``system`` 是一个 ``version`` 文件，但是实际上这个文件还不存在，也就是还没有全局设置指定版本

.. literalinclude:: homebrew_python/pyenv_versions_output
   :caption: 检查系统中通过 ``pyenv`` 安装的 Python 版本
   :emphasize-lines: 1

::

   % cat /Users/huatai/.pyenv/version
   cat: /Users/huatai/.pyenv/version: No such file or directory

- 然后使用如下命令为自己指定一个全局默认版本:

.. literalinclude:: homebrew_python/pyenv_global_python
   :caption: ``pyenv`` 指定默认Python版本

此时就会看到 ``pyenv versions`` 输出变化了:

.. literalinclude:: homebrew_python/pyenv_versions_output_3
   :caption: 版本切换到 ``3.12.4``
   :emphasize-lines: 3

此时 ``~/.pyenv/version`` 内容就是 ``3.12.4``

参考
======

- `Homebrew Documentation: Python <https://docs.brew.sh/Homebrew-and-Python>`_
- `Installing Python 3 on Mac OS X <https://docs.python-guide.org/starting/install3/osx/>`_
- `How to Install Python 3 on Mac – Brew Install Update Tutorial <https://www.freecodecamp.org/news/python-version-on-mac-update/>`_
