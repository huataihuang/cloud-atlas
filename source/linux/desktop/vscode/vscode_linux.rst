.. _vscode_linux:

=====================================
在Linux上运行Visual Studio Code
=====================================

随着Visual Studio Code功能越来越丰富，已经成为跨平台首选的轻量级开发编辑器。在Ubuntu Linux上安装VS Code也非常方便。

.. note::

   Visual Studio Code是微软开发的开源软件，集成了debug和git等高进功能。

Visual Studio Code跨平台提供了 Windows, Linux, macOS软件包，并且对于Windows和Linux还提供了ARM架构版本。(或许今后macOS也会支持ARM)。( `VS Code下载 <https://code.visualstudio.com/download#>`_ )

VS Code for Ubuntu(x86)
==========================

snap软件包安装
----------------

:ref:`snap` 是打包了应用程序所有依赖的二进制执行程序的子包含软件包，非常方便升级和安全加固。和标准的deb软件包不同，snaps的空间占用较大并且启动时间较长。snap软件包可以通过命令行安装::

   sudo snap install --classic code

通过apt安装
-------------

- 官方提供了debian/ubuntu的x86_64软件安装源，首先安装签名证书:

.. literalinclude:: vscode_linux/sign_key
   :caption: 在系统中添加微软仓库证书


- 添加VS Code软件仓库源:

.. literalinclude:: vscode_linux/repo
   :caption: 添加软件仓库

- 安装Visual Studio Code软件包:

.. literalinclude:: vscode_linux/install
   :caption: 安装code

RHEL/CentOS安装VS Code(x86)
==============================

VS Code官方也提供x86_64的yum仓库，所以可以直接安装::

   sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
   sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

   sudo dnf check-update
   sudo dnf install code

.. note::

   :ref:`priv_cloud_infra` 中使用KVM虚拟机 ``z-dev`` 来安装运行vscode，同时通过 :ref:`xpra_startup` 可以直接访问服务器上运行vscode，或者采用 :ref:`vscode_remote_dev_ssh` 。

ARM版本VS Code
=================

- 在 :ref:`jetson_nano` 上使用了 VS Code for ARM 64版本，直接下载deb软件包就可以安装::

   sudo dpkg -i code_1.50.1-1602600638_arm64.deb

- 在 :ref:`pi_400` 上安装 32位 ARM版本 VS Code::

   sudo dpkg -i code_1.54.1-1614897556_armhf.deb

社区构建VS Code
=================

`社区构建Visual Studio Code for Chromebooks, Raspberry Pi and other ARM and Intel systems <https://code.headmelted.com/>`_ 提供了不同架构和平台的软件包，如果需要可以直接通过社区提供的安装脚本进行安装。

此外，由于VS Code是开源软件，也有社区提供 `code-oss-aarch64 Visual Studio Code OSS for Ubuntu AArch64 and Others <https://futurejones.github.io/code-oss-aarch64/>`_ 并提供了在ARM环境如何编译 `code-oss-aarch64 <https://github.com/futurejones/code-oss-aarch64>`_ 指南。

参考
=========

- `How to Install Visual Studio Code on Ubuntu 20.04 <https://linuxize.com/post/how-to-install-visual-studio-code-on-ubuntu-20-04/>`_
- `Visual Studio Code on Linux <https://code.visualstudio.com/docs/setup/linux>`_
