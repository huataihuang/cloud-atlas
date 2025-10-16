.. _macports_old_qemu:

=========================
MacPorts安装旧版本qemu
=========================

我在旧版本 macOS Big Sur 11.7.10 上执行 :ref:`macports` 安装 :ref:`qemu` 

.. literalinclude:: macports/ports_install_qemu
   :caption: 使用 ``ports`` 安装 ``qemu``

遇到安装错误:

.. literalinclude:: macports_old_qemu/install_error.log
   :caption: 安装 qemu 错误

具体的编译日志错误如下:

.. literalinclude:: macports_old_qemu/build_error.log
   :caption: 编译 qemu 错误

发现这里安装的是 ``qemu-10.1.1_0`` ，根据之前 :ref:`homebrew_old_qemu` ，需要回退到 ``qemu-9.0.2``

安装尚未安装的旧版本
=======================

:ref:`macports` 使用 :ref:`git` 来管理仓库文件，要安装旧版本，需要先使用 ``git`` 回滚旧版本配置，然后进行安装。具体如下:

- 找到正确的port commit:

首先访问 `MacPorts仓库 <https://github.com/macports/macports-ports>`_ ，点击 ``History`` 按钮找到旧版本

.. literalinclude::  macports_old_qemu/git_checkout_old_qemu
   :caption: 检索出旧版本qemu配置

- 编译下载port:

.. literalinclude::  macports_old_qemu/port_install
   :caption: 编译下载port

这里有一个报错:

.. literalinclude::  macports_old_qemu/port_install_error
   :caption: 编译下载port报错

奇怪，明明有这个 ``Portfile`` 文件，为何无法读取?

参考 `Specify which version to install with macports <https://stackoverflow.com/questions/5235215/specify-which-version-to-install-with-macports>`_ ，我发现以前在svn时代，这个port代码仓库是放到 ``/tmp`` 目录下来完成 ``sudo port install``

果然，我将 ``git`` 的这个仓库目录 ``macports-ports`` 移动到 ``/tmp`` 目录下(属主我改成了root，但可能不需要改)，就能够正常工作了

此时能够正常编译完成，并安装到 ``/usr/local/bin`` :

.. literalinclude:: macports_old_qemu/qemu_files
   :caption: 安装后的 qemu 执行文件

参考
========

- `How to install an older version of a port <https://trac.macports.org/wiki/howto/InstallingOlderPort>`_
