.. _android_studio_in_pi:

==================================
在树莓派4上运行android studio开发
==================================


我尝试在树莓派上实现Android开发:

- android studio对硬件要求较高，需要8G内存运行，所以需要采用最高规格的 :ref:`pi_4`
- 我手头没有8G规格的 :ref:`pi_4` ，符合这个硬件要求的设备被我用于组建 :ref:`k3s` ，所以我考虑尝试 :ref:`xpra` 方式远程运行桌面，可以降低本地硬件要求，同时实现移动开发

概述
======

Android Stdio官方并没有宣布支持 :ref:`pi_4` ，只提供Windows, Linux 和 macOS 版本。不过， :ref:`pi_4` 是ARM64架构，实际上可以运行64位Java程序，也就是具备了运行Jetbrains系列全家桶的能力。

为了能够方便安装 Android Studio，在Ubuntu系列上，可以通过 :ref:`snap` 来安装，这样可以确保所有运行依赖都包含在镜像中。

.. note::

   不过，很不巧，我在 :ref:`k3s` 底层的操作系统采用了 :ref:`alpine_linux` ，这是一种精简的Linux发行版，使用 :ref:`openrc` 替代了 :ref:`systemd` 。参考snapcraft官方论坛 `Future release to include Alpine Linux as snapd host? <https://forum.snapcraft.io/t/future-release-to-include-alpine-linux-as-snapd-host/13144>`_ 提示，snapd依赖systemd来构建服务，并且编译存在问题。所以我暂时没有这样尝试。

   目前我暂时没有空闲设备能够完成 :ref:`pi_4` 安装运行Android Studio，所以本文实践待后续完成

在 debian 及其衍生版本，例如 :ref:`kali_linux` 系统，可以通过安装 snapd 来实现基础环境，以便快速完成 Android Studio  安装运行

安装准备
==========

- 安装32位运行依赖::

   sudo dpkg --add-architecture i386
   sudo apt-get update
   sudo apt-get install lib32z1 lib32ncurses5 lib32bz2-1.0 libstdc++6:i386 libfontconfig1:i386 libxext6:i386 libxrender1:i386 libgstreamer-plugins-base0.10-0:i386

- 安装snapd::

   sudo apt install snapd

安装
=======

- 使用snap安装android studio::

   sudo snap install android-studio --classic

参考
======

- `Install android studio in Raspberry pi 4 <https://officialrajdeepsingh.dev/install-android-studio-in-raspberry-pi-4/>`_
