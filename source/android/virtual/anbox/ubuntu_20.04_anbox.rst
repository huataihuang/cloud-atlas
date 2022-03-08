.. _ubuntu_20.04_anbox:

=============================
Ubuntu 20.04 LTS运行Anbox
=============================

我在 :ref:`kubuntu` 20.04 LTS中安装Anbox来运行Android应用

安装Anbox
===========

- 更新软件仓库::

   sudo apt update

- 强烈建议采用 :ref:`snap` 安装Anbox以避免环境依赖问题::

   sudo snap install --devmode --beta anbox

安装adb
=========

在不使用Google Play Store时，可以通过 :ref:`adb` 安装应用。所以我们首先安装Android开发工具 ``adb`` ::

   sudo apt install android-tools-adb

使用adb安装应用
===============

- 点击 ``anbox`` 图标运行，如果一切正常，屏幕闪过以下黑屏，然后在任务栏会有一个最小化隐藏窗口title ``org.anbox.appmgr`` 由于虚拟机中内部没有任何应用，所以这是正常的

- 执行 ``adb`` 检查虚拟机::

   adb deivces

应该看到::

   List of devices attached
   emulator-5558   device

- 执行安装::

   adb install apk-file-name

安装Android应用

对于ARM应用，会提示错误::

   adb: failed to install alilang.apk: Failure [INSTALL_FAILED_NO_MATCHING_ABIS: Failed to extract native libraries, res=-113]

这是因为模拟默认只能运行X86的Android应用。解决方法是安装 ``Google PlayStore`` 来提供ARM模拟。见下文

排查
--------

- 启动 ``anbox`` ::

   anbox.appmgr

我这里遇到报错::

   [ 2022-03-07 15:45:55 ] [launch.cpp:214@operator()] Session manager failed to become ready

并立即返回到终端桌面，而桌面系统没有提供任何anbox相关的窗口

不过， ``ps -aux | grep anbox`` 显示有如下进程::

   root         788  0.0  0.0 379264 11296 ?        Ssl  07:25   0:01 /snap/anbox/186/usr/bin/anbox container-manager --data-path=/var/snap/anbox/common/ --android-image=/snap/anbox/186/android.img --daemon
   huatai      5425 41.2  4.6 3218936 757476 ?      Sl   08:24   0:42 /snap/anbox/186/usr/bin/anbox session-manager
   root        5462  0.0  0.0 385564  7992 ?        Ss   08:24   0:00 [lxc monitor] /var/snap/anbox/common/containers default
   100000      5498  0.0  0.0  16732  4464 pts/0    Sl   08:24   0:00 /system/bin/anboxd
   110000      6209  0.6  0.5 1074124 97096 pts/0   Sl   08:25   0:00 org.anbox.appmgr

似乎已经运行起来

- 重新登录一次桌面，首次登录检查 ``ps aux | grep anbox`` 显示有一个 ``container-manager`` ::

   /snap/anbox/186/usr/bin/anbox container-manager --data-path=/var/snap/anbox/common/ --android-image=/snap/anbox/186/android.img --daemon

参考 `Unable to launch anbox in Ubuntu 21.04 #1854 <https://github.com/anbox/anbox/issues/1854>`_ 似乎启动会话要添加一个环境变量 ``EGL_PLATFORM=x11``

果然，修订 ``/var/lib/snapd/desktop/applications/anbox_appmgr.desktop`` 将::

   Exec=env BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/anbox_appmgr.desktop /snap/bin/anbox.appmgr %U

修改成::

   Exec=env EGL_PLATFORM=x11 BAMF_DESKTOP_FILE_HINT=/var/lib/snapd/desktop/applications/anbox_appmgr.desktop /snap/bin/anbox.appmgr %U

然后点击运行anbox图标，则屏幕闪过之后，不再退出 ``org.anbox.appmgr`` ，此时在终端执行::

   adb devices

可以看到模拟设备::

   List of devices attached
   emulator-5558   device

安装Google Play Store
=======================

.. note::

   目前尚未解决anbox运行，所以本段落待实践

`geeks-r-us / anbox-playstore-installer <https://github.com/geeks-r-us/anbox-playstore-installer>`_ 提供了自动安装Google Playstore的脚本

- 安装依赖工具::

   sudo apt install wget curl lzip tar unzip squashfs-tools

- 下载安装脚本::

   wget https://raw.githubusercontent.com/geeks-r-us/anbox-playstore-installer/master/install-playstore.sh
   chmod +x install-playstore.sh

- 运行安装::

   ./install-playstore.sh

- 然后启动Anbox就会看到已经具备了 ``Google PlayStore`` ::

   anbox.appmgr

- 如果不能连接因特网，则运行以下命令修复::

   sudo /snap/anbox/current/bin/anbox-bridge.sh start

参考
======

- `How to install Anbox on Ubuntu 20.04 LTS focal fossa <https://www.how2shout.com/linux/how-to-install-anbox-on-ubuntu-20-04-lts-focal-fossa/>`_
