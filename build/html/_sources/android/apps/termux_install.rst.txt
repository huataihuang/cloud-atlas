.. _termux_install:

================
Termux安装
================

从 :ref:`f-droid` 可以下载到最新的 Termux : 注意，不要使用Google Play提供的旧版本Termux(无法正常更新仓库软件，也就无法安装应用)。系统要求:

- Android 7.0 - 12.0
- CPU: AArch64, ARM, i386, x86_64
- 至少 300MB 磁盘空间

需要注意Termux不支持没有NEON SIMD的ARM设备，例如基于Nvidia Tegra 2 CPU。

可以安装 :ref:`f-droid` 客户端来安装应用，也可以直接下载安装 `termux apk <https://f-droid.org/en/packages/com.termux/>`_ APK软件包直接运行安装 - 安装方法和其他APK没有什么两样，安装后运行 ``Termux`` 会出现一个终端界面，然后有一些提示信息指导我们下一步操作。

更新系统
==========

类似一个小型操作系统，我们首先来更新::

   pkg update

软件安装
==========

所有软件安装都使用 ``pkg`` 命令，非常类似 debian 系统。

为了方便使用，首先我们安装 openssh ::

   pkg install openssh iproute2

- 检查主机IP::

   ip addr

- 检查自己的账号::

   id

这个账号是 Termux 的用户账号，我们后面就是通过这个账号ssh到手机中运行的操作系统，例如， ``u0_a184``

- 设置自己的密码::

   passwd

这样后面通过ssh登陆就可以使用这个密码

这里，我通过上述3个步骤获得得了登陆信息，然后配置自己客户端 ``~/.ssh/config`` 添加如下简单配置:

.. literalinclude:: termux_install/ssh_config
   :caption: 配置ssh登陆Termux环境 ~/.ssh/config
   :emphasize-lines: 3

注意，Termux不是使用标准的22端口作为ssh访问端口，使用 ``8022``

- 然后就可以ssh访问主机::

   ssh pixel1

顺利登陆系统之后，立即配置 :ref:`ssh_key` 方便后续无需密码直接访问系统

然后，配置 :ref:`termux_dev`

参考
=====

- `Termux Wiki: Installation <https://wiki.termux.com/wiki/Main_Page#Installation>`_
