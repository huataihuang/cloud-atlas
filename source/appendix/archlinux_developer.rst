.. _archlinux_developer:

=======================
Arch Linux开发环境
=======================

vim
=======

默认安装的vi软件非常简陋，所以安装标准版的vim::

   pacman -S vim

Vitual Studio Code
=======================

通过 :ref:`archlinux_aur` 可以非常方便 `通过AUR安装Vitual Studio Code <https://aur.archlinux.org/packages/visual-studio-code-bin>`_ 作为日常轻量级开发平台::

   yay -S visual-studio-code-bin

Python virtualenv
===================

.. note::

   Python virtualenv是开发Python的个人运行环境，并且基于virtualenv，可以安装Sphinx文档开发环境。

   参考 `Arch Linux文档 - Python/Virtual environment <https://wiki.archlinux.org/index.php/Python/Virtual_environment>`_

- 最新版本Python 3.3+已经包含了一个 ``venv`` 模块，所以不再需要像以前那样再安装一个 ``python-virtualenv`` 软件包了::

   pacman -S python

- 在个人目录下创建virtualenv::

   cd ~
   python -m venv venv


- 激活virtualenv::

   . ~/venv/bin/activate

现在位于virtualenv环境中，就可以直接使用 ``pip`` 命令安装python的模块了。

Sphinx-doc
===============

在上述激活的python virtualenv环境中安装sphinx-doc::

   pip install sphinx
   pip install sphinx_rtd_theme
