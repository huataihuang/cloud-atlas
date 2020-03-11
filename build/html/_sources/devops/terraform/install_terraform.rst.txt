.. _install_terraform:

===============
安装Terraform
===============

安装

从 `Terraform官方下载 <https://www.terraform.io/downloads.html>`_ 对应系统的安装包，支持的操作系统包括了 macOS/FreeBSD/Linux/OpenBSD/Solaris/Windows。

对于很多发行版，可以直接通过对应发行版的的软件包管理工具进行安装升级。例如，我使用 :ref:`arch_linux` ::

   pacman -S terraform

安装完成后，请验证Terraform是否工作::

   terraform

并且可以检查帮助::

   terraform --help

   terraform --help plan

参考
========

- `Installing Terraform <https://learn.hashicorp.com/terraform/getting-started/install.html>`_
