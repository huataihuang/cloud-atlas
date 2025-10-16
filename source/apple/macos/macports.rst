.. _macports:

==================
MacPorts
==================

一直以来，我都是在macOS上使用 :ref:`homebrew` ，直到我发现我的古老的 :ref:`mbp15_late_2013` 操作系统 Big Sur 已经不再支持，强制使用 ``brew`` 实际上困难重重。

这使得我不得不转向 ``MacPorts`` ，一个相对古老的macOS移植软件平台，依然保留了支持历史上多数macOS版本:

“pkg” installers for Tahoe, Sequoia, Sonoma, and Ventura, for use with the macOS Installer. This is the simplest installation procedure that most users should follow after meeting the requirements listed below. Installers for legacy platforms Monterey, ``Big Sur`` , Catalina, Mojave, High Sierra, Sierra, El Capitan, Yosemite, Mavericks, Mountain Lion, Lion, Snow Leopard, and Leopard are also available.

安装非常简单，从官方网站下载 ``.pkg`` 安装包进行安装。

使用
========

``MacPorts`` 的执行命令是 ``ports`` ，使用简便:

- 安装 :ref:`qemu` :

.. literalinclude:: macports/ports_install_qemu
   :caption: 使用 ``ports`` 安装 ``qemu``

.. note::

   实际上 ``qemu`` 是通过编译源代码完成安装的， ``ports`` 会自动下载所有需要依赖的编译工具和库，自动完成 ``qemu`` 的编译安装，非常方便。

参考
========

- `Installing MacPorts <https://www.macports.org/install.php#installing>`_
