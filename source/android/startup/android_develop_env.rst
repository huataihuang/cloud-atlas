.. _android_develop_env:

==================
Android开发环境
==================

.. note::

   开发环境在 :ref:`arch_linux` 下构建，其他Linux发行版安装方法可能不同，或者可以从Android官方下载Android Studio。

Android Studio
=================

- 通过 :ref:`archlinux_aur` 安装Android Studio::

   ysy -S android-studio

- 安装Java运行环境 - Android Studio是基于IntelliJ IDEA开发的，需要Java环境才能运行::
   sudo pacman -S jdk-openjdk

.. note::

   Arch Linux官方支持开源的OpenJDK，并且可以安装多个版本无缝切换，彼此不会冲突。

- 启动Android Studio，启动时需要连接Google的软件仓库以便安装插件和模拟器等，所以请参考 :ref:`ssh_tunnel_gfw_autoproxy` 搭好梯子，这样可以在Android Studio中通过代理下载必要组件。

由于Android Studio安装在 ``/opt/android-studio`` 目录，所以运行如果检测到有更新包，则提示需要使用具有权限的用户来运行一次Android Studio以便更新软件包。

配置向导会检测到Linux支持KVM加速虚拟机，建议 `Configure VM acceleration on Linux <https://developer.android.com/studio/run/emulator-acceleration?utm_source=android-studio#vm-linux>`_

   

参考
======

- `Arch Linux社区文档 - Android <https://wiki.archlinux.org/index.php/Android>`_
