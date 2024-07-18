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
   :caption: ``pyenv`` 安装指定Python版本(这里假设我安装当前最新的稳定release版本)


参考
======

- `Homebrew Documentation: Python <https://docs.brew.sh/Homebrew-and-Python>`_
- `Installing Python 3 on Mac OS X <https://docs.python-guide.org/starting/install3/osx/>`_
- `How to Install Python 3 on Mac – Brew Install Update Tutorial <https://www.freecodecamp.org/news/python-version-on-mac-update/>`_
