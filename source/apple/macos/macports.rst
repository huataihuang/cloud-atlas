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

卸载
========

.. note::

   由于我现在切换到 :ref:`rancher_desktop` 来使用虚拟机和容器环境，所以我目前不再需要MacPorts提供的独立 :ref:`lima` 环境，故实践卸载操作。

要卸载MacPorts，则首先需要将已经安装的所有ports卸载，然后手工移除安装目录，最后再移除 ``macports`` 用户和组:

- 卸载所有安装的ports以及依赖:

.. literalinclude:: macports/uninstall
   :caption: 卸载ports

- 移除 ``macports`` 用户和组:

.. literalinclude:: macports/dscl
   :caption: ``dscl`` 工具移除 ``macports`` 用户和组

- 移除剩余的MacPorts文件(需要根据实际情况删除目录，例如你安装在不同目录下更改过 ``applications_dir`` 或 ``frameworks_dir`` 默认值):

.. literalinclude:: macports/rm
   :caption: 删除残留的MacPorts文件

参考
========

- `Installing MacPorts <https://www.macports.org/install.php#installing>`_
- `Uninstall MacPorts <https://guide.macports.org/chunked/installing.macports.uninstalling.html>`_
