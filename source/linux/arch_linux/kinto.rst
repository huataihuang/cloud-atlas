.. _kinto:

=================================================
Kinto.sh - 为Linux/Windows提供 ``Mac风格快捷键``
=================================================

对于在 :ref:`macos` / :ref:`linux` / :ref:`windows` 不断切换平台的技术工作者，非常头疼的是这3个平台的快捷键是不一样的，这导致长期的肌肉记忆很难适应。 `github: rbreaves/kinto <https://github.com/rbreaves/kinto>`_ 是一个为Linux/Windows提供 ``Mac风格快捷键`` 的开源软件，特别适合在 MacBook 上安装运行Linux/Windows的用户。

由于我在我不同的Mac设备上安装运行Linux:

- :ref:`archlinux_on_mba`
- :ref:`archlinux_on_mbp`
- :ref:`install_gentoo_on_mbp`

所以适配Mac键盘的操作方式特别适合我这样主要在 :ref:`macos_studio` 完成工作，同时有时会使用Linux平台的人。

.. warning::

   ``Kinto.sh`` 运行环境是 :ref:`x_window` ，由于我现在转为使用 :ref:`sway` 基于 :ref:`wayland` 实现，所以已经无法工作，例如运行脚本会提示缺少 ``/usr/bi/xhost`` 执行失败，不断重启 ``xkeysnail.service``

   不过，本文实践中在 :ref:`arch_linux` 中部署解决 :ref:`python` 环境运行 ``PyGObject`` 等GUI环境还是有借鉴意义，后续可以参考作为Python GUI运行环境设置。

准备工作
===========

``kinto`` (Linux版本) 依赖 `github: mooz/xkeysnail <https://github.com/mooz/xkeysnail>`_ (一种使用Python编写的X环境键盘映射) ，需要有Python运行环境，最好的方法是使用 :ref:`virtualenv` 部署好环境，并且安装好 ``xkeysnail`` 模块在继续安装 ``kinto`` :

.. literalinclude:: ../../python/startup/virtualenv/arch_pip_venv
   :caption: arch linux环境设置virtualenv

另外，在后续运行 ``~/.config/kinto/gui/kinto-gui.py`` 会提示缺少 ``gi`` 模块::

   File "/home/admin/.config/kinto/gui/kinto-gui.py", line 3, in <module>
     import gi,os,time,fcntl,argparse,re
   ModuleNotFoundError: No module named 'gi'

如果是是 :ref:`ubuntu_linux` 可以直接安装 ``sudo apt install python3-gi`` ，但是对于 :ref:`arch_linux` 的则比较麻烦:

.. literalinclude:: kinto/arch_pip_venv_pygobject
   :caption: 通过 :ref:`virtualenv` 的 ``pip`` 安装 ``PyGObject`` 模块

但是，这里会报错: 提示 依赖 ``gobject-introspection`` 错误

参考 `pygobject-2.28.6 won't configure: No package 'gobject-introspection-1.0' found, how do I resolve? <https://stackoverflow.com/questions/18025730/pygobject-2-28-6-wont-configure-no-package-gobject-introspection-1-0-found>`_ ，这个 ``gobject-introspection`` 开发包在不同平台有不同名字:

- Fedora, CentOS, RHEL, etc.: gobject-introspection-devel
- Debian, Ubuntu, Mint, etc.: libgirepository1.0-dev
- Arch: gobject-introspection
- FreeBSD: gobject-introspection
- Cygwin: libgirepository1.0-devel
- msys2: mingw-w64-x86_64-gobject-introspection and/or mingw-w64-i686-gobject-introspection

对于我的 :ref:`arch_linux` 平台，执行如下命令:

.. literalinclude:: kinto/arch_install_gobject-introspection
   :caption: :ref:`arch_linux` 安装 ``gobject-introspection``

然后就可以正常执行 ``pip install PyGObject``

接下来报错是:

.. literalinclude:: kinto/arch_venv_namespace_vte
   :caption: 运行 ``kinto-gui.py`` 提示缺少 Vte Namespace

参考 `kinto: Namespace Vte not available #302 <https://github.com/rbreaves/kinto/issues/302>`_ 需要在系统中安装 ``vte`` 包，对于 :ref:`ubuntu_linux` 是安装 ``sudo apt install vte-2.91`` ，不过，在 :ref:`arch_linux` 则安装 `` vte3`` :

.. literalinclude:: kinto/arch_vte3
   :caption: :ref:`arch_linux` 安装 ``vte3``

接下来报错是:

.. literalinclude:: kinto/arch_venv_distutils
   :caption: 运行 ``kinto-gui.py`` 提示缺少 ``distutils`` 模块

参考 `No module named 'distutils' on Python 3.12 #732 <https://github.com/Uberi/speech_recognition/issues/732>`_ 安装 ``setuptools`` 模块即可:

.. literalinclude:: kinto/arch_pip_venv_setuptools
   :caption: 通过 ``pip install setuptools`` 来获得 ``disutils`` 模块

原因在 `distutils — Building and installing Python modules <https://docs.python.org/3.10/library/distutils.html>`_ 已经做了说明，现在Python用户不需要直接使用 ``distutils`` 莫阿奎，而是采用替代的 ``setuptolls`` 模块

安装
========

安装kinto依赖需要 ``pip3`` (安装python模块)，所以提前在系统中完成pip3安装。例如:

- :ref:`arch_linux` 安装 ``python-pip`` 包:

- 执行以下命令安装Kinto

.. literalinclude:: kinto/install
   :language: bash
   :caption: 安装kinto

.. note::

   上述安装所使用的域名 ``raw.githubusercontent.com`` 需要 :ref:`across_the_great_wall` :

   - :ref:`wget_proxy`
   - :ref:`curl_proxy`

安装完成后会运行 ``~/.config/kinto/gui/kinto-gui.py`` 进行设置以及启动服务

.. warning::

   因为我的工作平台为 :ref:`sway` ，所以放弃采用本文方案

参考
=======

- `github: rbreaves/kinto <https://github.com/rbreaves/kinto>`_
