.. _android_develop_env:

==================
Android开发环境
==================

.. note::

   开发环境在 :ref:`arch_linux` 下构建，其他Linux发行版安装方法可能不同，或者可以从Android官方下载Android Studio。

.. note::

   Google提供的Android Studio是基于Google从Jetbrains购买IntelliJ IDEA构建的，不仅提供了Android开发也提供了C++开发功能，如果专注于Android开发，选择Android Studio较好，可以得到Google社区的更好支持。如果你同时开进行J2EE开发，则可以在IntelliJ IDEA的基础上使用Android Plugin来实现Android Studio几乎完全一样功能，差异主要是IntelliJ IDEA的Android Plugin是移植Android studio的，更新稍慢。


Android Studio
=================

- 通过 :ref:`archlinux_aur` 安装Android Studio::

   yay -S android-studio

- 安装Java运行环境 - Android Studio是基于IntelliJ IDEA开发的，需要Java环境才能运行::

   sudo pacman -S jdk-openjdk

.. note::

   Arch Linux官方支持开源的OpenJDK，并且可以安装多个版本无缝切换，彼此不会冲突。

- 启动Android Studio，启动时需要连接Google的软件仓库以便安装插件和模拟器等，所以请参考 :ref:`ssh_tunnel_gfw_autoproxy` 搭好梯子，这样可以在Android Studio中通过代理下载必要组件。

由于Android Studio安装在 ``/opt/android-studio`` 目录，所以运行如果检测到有更新包，则提示需要使用具有权限的用户来运行一次Android Studio以便更新软件包。

配置向导会检测到Linux支持KVM加速虚拟机，建议 `Configure VM acceleration on Linux <https://developer.android.com/studio/run/emulator-acceleration?utm_source=android-studio#vm-linux>`_

IntelliJ IDEA
=================

IntelliJ IDEA在首次创建Android项目时会检车系统是否已经下载了Android Plugin(SDK)，并引导你进行下载和安装。安装以后和Android Studio使用没有太大差别。

Android SDK选择
=================

Android的版本分裂非常严重，从 `Android 开发者 > 平台 > 版本 <https://developer.android.com/about/dashboards>`_ 可以查到当前版本分布的统计信息，以便选择你需要支持的设备对应的SDK。

.. note::

   :strike:`我个人感觉Android版本选择至少应该延续5年，考虑到硬件设备的使用寿命，通常5年应该能够满足大多数用户的使用。`

参考
======

- `Arch Linux社区文档 - Android <https://wiki.archlinux.org/index.php/Android>`_
- `Android Studio与其IntelliJ IDEA相比, 其差异与利弊主要有哪些? <https://www.zhihu.com/question/27763224>`_
