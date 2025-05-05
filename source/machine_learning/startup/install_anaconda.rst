.. _install_anaconda:

====================
安装Anaconda
====================

Linux
=========

.. note::

   安装运行环境是 :ref:`fedora` 和 :ref:`ubuntu_linux` 

   我在本文实践基础上，构建 :ref:`fedora_tini_image` 和 :ref:`ubuntu_tini_image` 部署Anaconda

- 下载Anaconda Installer并执行安装:

.. literalinclude:: install_anaconda/anaconda.sh
   :language: bash
   :caption: 下载和运行Anaconda Installer

按照提示接受license并且按照默认执行 ``init`` 即可。默认安装在 ``$HOME/anaconda3`` 目录下:

.. literalinclude:: install_anaconda/anaconda_init
   :caption: Anaconda安装最后的init步骤，自动更新shell profile以便自动初始化conda
   :emphasize-lines: 12

- 再次登陆系统，或者直接执行::

   source ~/.bashrc

此时就进入了Anaconda的 :ref:`virtualenv` 就可以使用 ``conda`` 命令，例如 ``conda list`` 可以查看安装好的Anaconda包:

.. literalinclude:: install_anaconda/conda_list
   :caption: 再次登陆到anaconda环境中可以看到 :ref:`virtualenv` 环境下可以使用 ``conda list`` 这样的命令
   :emphasize-lines: 1

安装错误处理
--------------

我在 :ref:`ubuntu_tini_image` 环境部署 anaconda 时遇到报错:

.. literalinclude:: install_anaconda/ubuntu_install_anaconda_err
   :caption: :ref:`ubuntu_tini_image` 环境部署 Anaconda 报错
   :emphasize-lines: 24

这个问题在 `Error related to ncurses-6.2 when installing conda on an Ubuntu server (16.04.7 LTS) #12089 <https://github.com/ContinuumIO/anaconda-issues/issues/12089>`_ 有人已经指出了: 当在Docker中运行时，需要确保底层文件系统是和Linux一致的 ``区分大小写`` 文件系统。

我在 :ref:`docker_desktop` for :ref:`macos` 上部署 :ref:`ubuntu_tini_image` ，恰好就是将共享卷建立在 ``case insensitive``  的 :ref:`apfs` 上导致上述问题。解决方法是 :ref:`apfs_case-sensitive` (通过新增APFS Container可以实现无需重装系统就隔离出一个区分大小写的卷)

GUI包
------

Anaconda的GUI软件包依赖Qt，在各大Linux发行版需要安装以下软件包:

- Debian:

.. literalinclude:: install_anaconda/debian_anaconda_gui_prerequisites
   :caption: Debian发行版安装Anaconda的GUI依赖软件包

- RedHat:

.. literalinclude:: install_anaconda/redhat_anaconda_gui_prerequisites
   :caption: RedHat发行版安装Anaconda的GUI依赖软件包

- ArchLinux:

.. literalinclude:: install_anaconda/arch_anaconda_gui_prerequisites
   :caption: ArchLinux发行版安装Anaconda的GUI依赖软件包

- OpenSuse/SLES:

.. literalinclude:: install_anaconda/suse_anaconda_gui_prerequisites
   :caption: OpenSuse/SLES发行版安装Anaconda的GUI依赖软件包

- Gentoo:

.. literalinclude:: install_anaconda/gentoo_anaconda_gui_prerequisites
   :caption: Gentoo发行版安装Anaconda的GUI依赖软件包

macOS
========

Anaconda官方提供了 :ref:`macos` 的 Intel 和 M1/M2 安装包( ``.pkg`` ) ，安装提供了 ``仅在当前用户下安装`` 和 ``系统级别安装`` 两种方式。

更新
=======

- 在Anaconda环境中，可以对整个Anaconda系统更新:

.. literalinclude:: install_anaconda/conda_update
   :caption: 更新Anaconda

参考
=======

- `Anaconda Documentation: Installing on Linux <https://docs.anaconda.com/anaconda/install/linux/>`_ 官方文档
- `How To Install Anaconda on Fedora 37/36/35 <https://tecadmin.net/how-to-install-anaconda-on-fedora/>`_
