.. _linux_jail_init:

==========================
Linux Jail初始化(Ubuntu)
==========================

和 :ref:`jail_init` 初始化类似，我想要一个能够方便环线的开发、测试环境，来模拟大规模集群的部署和开发。

和 :ref:`jail_init` 不同的是， :ref:`linux_jail` 多了一步 ``chroot`` ，并且进入 :ref:`debian` / :ref:`ubuntu_linux` 系统之后所有的操作相当于在一个Linux系统中完成:

.. literalinclude:: linux_jail/jexec_chroot
   :caption: 进入Linux Jail的Ubuntu环境

注意，在 :ref:`linux_jail` 中的Linux系统是没有 :ref:`systemd` 

补全apt
=========

.. note::

   这段可能是 ``debootstrap`` 的问题导致的， `Setting up a (Debian) Linux jail on FreeBSD <https://forums.freebsd.org/threads/setting-up-a-debian-linux-jail-on-freebsd.68434/>`_ 提示在初次进入Linux Jail中，需要执行安装包补全:

   .. literalinclude:: linux_jail_init/dpkg_install
      :caption: 补全系统安装

通过 ``debootstrap`` 部署在 ``/compat/ubuntu`` 目录的 :ref:`ubuntu_linux` 系统是一个非常精简的Ubuntu系统，只有 ``129M`` ，仅包含Linux核心系统

比较奇怪，虽然 ``debootstrap`` 显示安装了 ``apt 2.4.5`` ，但是我 ``chroot /comapt/ubuntu /bin/bash`` 之后却显示找不到 ``apt`` 命令。

.. warning::

   我最终采用 :ref:`linux_jail_ubuntu-base` ，使用Ubuntu官方提供的core系统，绕开了这个问题。

Jail层设置
============

.. note::

   我发现在Linux层(debian)无法激活sshd服务，但是可以在Jail层激活FreeBSD的sshd服务，所以还是和 :ref:`jail_init` 一样做ssh初始化

ssh初始化
-----------

jail中需要安装 ``sudo`` ，这里采用 :ref:`freebsd_init` 中步骤，安装 :ref:`devops` 相关工具

.. literalinclude:: ../../startup/freebsd_init/devops
   :caption: 为 ``d2l`` jail 安装sudo

.. literalinclude:: ../../startup/freebsd_init/user
   :caption: 在jail内部创建admin

Linux层设置
=============

- 进入 ``d2l`` Linux jail，并 ``chroot`` :

.. literalinclude:: linux_jail_archive/jexec_chroot
   :caption: ``jexec`` 结合 ``chroot`` 将访问 :ref:`debian` 系统Linux二进制兼容

需要确保检查当前确实是Linux环境:

.. literalinclude:: linux_jail_archive/uname
   :caption: 使用 ``uname`` 检查Linux环境

输出类似:

.. literalinclude:: linux_jail_archive/uname_output
   :caption: 使用 ``uname`` 检查Linux环境输出

安装必要软件包
------------------

类似 :ref:`debian_init` ，但针对 :ref:`linux_jail` 环境附加安装一些软件包

.. literalinclude:: linux_jail_init/devops
   :caption: 安装Linux Jail软件包

admin帐号
------------

- 在 Linux jail中创建用户组和用户admin:

.. literalinclude:: linux_jail_init/admin
   :caption: Linux jail中创建用户组和用户admin

ssh登录(可选)
================

完成上述 jail 层 和 linux 层设置之后，现在可以在host上通过 ssh 先登录到 jail 中，然后再 ``chroot`` 进入Linux:

.. literalinclude:: linux_jail_init/ssh_admin
   :caption: ssh 先登录到 jail 中，然后再 ``chroot`` 进入Linux

安装python virtualenv(可选)
============================

.. literalinclude:: linux_jail_init/install_python
   :caption: 安装python

.. literalinclude:: ../../../python/startup/virtualenv/venv
   :language: bash
   :caption: venv初始化

- 激活:

.. literalinclude:: ../../../python/startup/virtualenv/venv_active
   :language: bash
   :caption: 激活venv

安装Conda(可选)
===================

.. note::

   :ref:`install_conda` 包含了完整 :ref:`python` 运行环境，所以主机(jail)环境不需要安装Python

- `Anaconda Download <https://www.anaconda.com/download/success>`_ 提供了Anaconda和Miniconda安裝下載(腳本)

.. literalinclude:: ../../../machine_learning/startup/install_conda/install_miniconda
   :caption: 安裝miniconda

- 在同意了license之后，按照提示进行安装

.. literalinclude:: ../../../machine_learning/startup/install_conda/install_miniconda_interact
   :caption: 交互方式安装
   :emphasize-lines: 11,26

参考
===========

- `Setting up a (Debian) Linux jail on FreeBSD <https://forums.freebsd.org/threads/setting-up-a-debian-linux-jail-on-freebsd.68434/>`_
