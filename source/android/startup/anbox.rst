.. _anbox:

=======================
Anbox运行Andorid程序
=======================

Anbox是开源兼容层，通过LXC容器构建Android运行环境，使得移动应用程序能偶运行在Linux环境。由于使用容器，采用原生Linux内核执行应用程序，所以非常轻量级并且保障了运行速度。

安装Anbox
===========

- 首先确保系统安装了Linux内核头文件::

   sudo pacman -S linux-headers

- 安装Anbox，如果镜像中不想包含Google apps和houdini，则用 anbox-image 替代 anbox-image-gapps::

   yay -S anbox-git anbox-image-gapps anbox-modules-dkms-git anbox-bridge

.. note::

   参考 `如何在 Anbox 上安装 Google Play 商店及启用 ARM 支持 <https://zhuanlan.zhihu.com/p/50994213>`_

   默认情况下，Anbox没有Google Play商店或者ARM应用支持。要安装应用，你必须下载每个应用的 APK 并使用 adb 手动安装。此外，默认情况下不能使用 Anbox 安装 ARM 应用或游戏 —— 尝试安装 ARM 应用会显示以下错误::

      Failed to install PACKAGE.NAME.apk: Failure [INSTALL_FAILED_NO_MATCHING_ABIS: Failed to extract native libraries, res=-113]

   通过 libhoudini 可以支持ARM应用。所以，建议上述安装Anbox时使用 ``anbox-image-gapps``

- 启动和激活服务::

   sudo systemctl start anbox-container-manager.service
   sudo systemctl enable anbox-container-manager.service

- 如果没有重启主机，则使用以下命令激活DKMS模块::

   sudo modprobe ashmem_linux
   sudo modprobe binder_linux

此时检查设备::

   ls -1 /dev/{ashmem,binder}

应该看到如下::

   /dev/ashmem
   /dev/binder

使用Anbox准备
==============

- 在执行 ``anbox`` 之前，需要先执行 ``anbox-bridge`` 来激活网络，此时使用 ``brctl show`` 可以看到::

   bridge name  bridge id               STP enabled     interfaces
   anbox0               8000.1edb3f6031c8       no

- 安装 ``adb`` 工具(用于给虚拟机内部安装应用程序)::

   pacman -S android-tools

编译报错处理
=================

- 编译报错::

   /home/huatai/.cache/yay/anbox-git/src/anbox/src/anbox/logger.cpp:20: error: "BOOST_LOG_DYN_LINK" redefined [-Werror]
      20 | #define BOOST_LOG_DYN_LINK

 这个报错解决方法见 https://bbs.archlinux.org/viewtopic.php?id=249747 ，其中有关patch的方法参考 :ref:`archlinux_aur` 中补丁方法。

运行报错处理
================

- 先在菜单点击 ``anbox-bridge`` 启动网桥

- 然后在菜单启动 ``anbox``

但是我遇到界面停留在 ``starting...`` ，并且执行 ``adb devices`` 显示并没有启动模拟设备。

使用命令行调试::

   export ANBOX_LOG_LEVEL=debug
   anbox session-manager --gles-driver=translator

显示::

   [ 2019-10-08 14:25:21] [Renderer.cpp:168@initialize] Using a surfaceless EGL context
   [ 2019-10-08 14:25:21] [Renderer.cpp:251@initialize] Successfully initialized EGL
   [ 2019-10-08 14:25:21] [service.cpp:41@Service] Successfully acquired DBus service name
   [ 2019-10-08 14:25:21] [client.cpp:49@start] Failed to start container: Failed to start container: Failed to start container
   [ 2019-10-08 14:25:21] [session_manager.cpp:148@operator()] Lost connection to container manager, terminating.
   [ 2019-10-08 14:25:21] [daemon.cpp:61@Run] Container is not running
   Stack trace (most recent call last) in thread 9740:

anbox的container日志位于 ``/var/lib/anbox/logs/container.log`` 可以看到以下报错::

   ...
   lxc 20191009031012.389 TRACE    cgfsng - cgroups/cgfsng.c:cg_hybrid_init:2562 - No controllers are enabled for delegation in the unified hierarchy
   lxc 20191009031012.415 TRACE    cgfsng - cgroups/cgfsng.c:cg_hybrid_init:2589 - Writable cgroup hierarchies:
   ...
   lxc 20191009031012.458 TRACE    cgroup - cgroups/cgroup.c:cgroup_init:61 - Initialized cgroup driver cgfsng
   lxc 20191009031012.459 TRACE    cgroup - cgroups/cgroup.c:cgroup_init:66 - Running with hybrid cgroup layout
   lxc 20191009031012.459 TRACE    start - start.c:lxc_init:923 - Initialized cgroup driver
   lxc 20191009031012.460 TRACE    start - start.c:lxc_init:930 - Initialized LSM
   lxc 20191009031012.461 INFO     start - start.c:lxc_init:932 - Container "default" is initialized
   lxc 20191009031012.516 DEBUG    cgfsng - cgroups/cgfsng.c:cg_legacy_filter_and_set_cpus:499 - No isolated or offline cpus present in cpuset
   lxc 20191009031012.568 INFO     cgfsng - cgroups/cgfsng.c:cgfsng_monitor_create:1405 - The monitor process uses "lxc.monitor/default" as cgroup
   lxc 20191009031012.587 ERROR    cgfsng - cgroups/cgfsng.c:__do_cgroup_enter:1500 - No space left on device - Failed to enter cgroup "/sys/fs/cgroup/cpuset//lxc.monitor/default/cgroup.procs"
   lxc 20191009031012.589 ERROR    start - start.c:__lxc_start:2009 - Failed to enter monitor cgroup
   lxc 20191009031012.596 TRACE    start - start.c:lxc_serve_state_socket_pair:543 - Sent container state "STOPPING" to 13
   lxc 20191009031012.598 TRACE    start - start.c:lxc_serve_state_clients:474 - Set container state to STOPPING
   lxc 20191009031012.600 TRACE    start - start.c:lxc_serve_state_clients:477 - No state clients registered
   lxc 20191009031012.600 DEBUG    lxccontainer - lxccontainer.c:wait_on_daemonized_start:861 - First child 1862 exited
   lxc 20191009031012.604 ERROR    lxccontainer - lxccontainer.c:wait_on_daemonized_start:872 - Received container state "STOPPING" instead of "RUNNING"
   lxc 20191009031012.694 DEBUG    cgfsng - cgroups/cgfsng.c:cg_legacy_filter_and_set_cpus:499 - No isolated or offline cpus present in cpuset
   lxc 20191009031012.706 WARN     cgfsng - cgroups/cgfsng.c:cgfsng_monitor_destroy:1180 - No space left on device - Failed to move monitor 1863 to "/sys/fs/cgroup/cpuset//lxc.pivot/cgroup.procs"
   lxc 20191009031012.868 TRACE    start - start.c:lxc_fini:1043 - Closed command socket
   lxc 20191009031012.873 TRACE    start - start.c:lxc_fini:1054 - Set container state to "STOPPED"
   lxc 20191009031012.567 TRACE    commands - commands.c:lxc_cmd:302 - Connection refused - Command "get_state" failed to connect command socket

检查启动以后建立的 ``/sys/fs/cgroup/cpuset/lxc.monitor/`` 和子目录 ``lxc.monitor`` 的所有proc文件内容都是空的，例如 ``/sys/fs/cgroup/cpuset/lxc.monitor/cpuset.cpus`` 和 ``/sys/fs/cgroup/cpuset/lxc.monitor/default/cpuset.cpus`` ，发现目录下所有的设置值都是空的。参考 `Cgroup - no space left on device <https://serverfault.com/questions/579555/cgroup-no-space-left-on-device>`_ ，实际上这些proc文件需要有初始值，否则就会出现 ``no space left on device`` 。

为何创建的cgroup配置没有默认继承上一级cgroup配置？

参考 `cgfsng - cgroups/cgfsng.c:__do_cgroup_enter:1500 - No space left on device - Failed to enter cgroup "/sys/fs/cgroup/cpuset//lxc.monitor/test/cgroup.procs" #6257 <https://github.com/lxc/lxd/issues/6257>`_ ，child cgroup继承parent的开关参数在 ``/sys/fs/cgroup/cpuset/cgroup.clone_children`` ，检查arch linux的默认配置，这个参数值是 ``0`` ，也就是没有继承::

   $ cat /sys/fs/cgroup/cpuset/cgroup.clone_children
   0

解决方法是在启动anbox之前，先执行::

   echo 1 | sudo tee /sys/fs/cgroup/cpuset/cgroup.clone_children

这样所有创建的cgroup子项默认继承上一级配置，就不会出现空值，也就不会出现 ``No space left on device`` ，再检查 ``/var/lib/anbox/logs/container.log`` 就可以看到日志不再出现ERROR。

启动anbox之后，在控制台使用 ``adb devices`` 检查可以看到系统运行了一个模拟器::

   List of devices attached
   emulator-5558        device
   
但是现在的anbox也只是显示 ``starting...`` 然后退出。不过，此时可以看到，原先始终没有输出的 ``/var/lib/anbox/logs/console.log`` 现在有大量内容输出，可以看到报错信息了::

   10-09 04:03:03.996     9     9 W         : debuggerd: resuming target 8694
   10-09 04:03:04.325    26    26 I lowmemorykiller: ActivityManager disconnected
   10-09 04:03:04.325    26    26 I lowmemorykiller: Closing Activity Manager data connection
   10-09 04:03:04.337    34    34 E         : eof
   10-09 04:03:04.338    34    34 E         : failed to read size
   10-09 04:03:04.338    34    34 I         : closing connection
   10-09 04:03:04.338    27    27 I ServiceManager: service 'batterystats' died
   10-09 04:03:04.338    27    27 I ServiceManager: service 'appops' died
   ...

看来是分配内存过小了。

.. note::

   参考 `Android和Linux关系 <https://blog.csdn.net/caohang103215/article/details/79493430>`_ :

   低内存管理(Low Memory Killer) -

      Android中低内存管理和Linux标准OOM(Out of Memory)相比，机制更加灵活，可以根据需要杀死进程类释放需要的内存。Low Memory Killer代码非常简单，里面关键函数lowmem_shrinker()，作为一个模块初始化调用register_shrinke注册一个low_shrinker()，会被vm在内存紧张时候调用。lowmem_shrinker完成具体操作，简单寻找一个最合适进程杀死，从而释放它的占用内存。drivers/staging/android/lowmemorykiller.c

由于后台不断重启模拟器android系统，所以console.log会不断输出日志。所以采用如下命令停止::

   systemctl --user stop anbox-session-manager.service
   systemctl stop anbox-container-manager.service

此时 ``adb devices`` 显示模拟器停止了。

`anbox splash screen disappears #814 <https://github.com/anbox/anbox/issues/814>`_ 提示修改 ``/usr/lib/systemd/user/anbox-session-manager.service`` ::

   ExecStart=/usr/bin/anbox session-manager --gles-driver=host

启动方式::

   sudo systemctl start systemd-resolved.service
   sudo systemctl start systemd-networkd.service
   sudo systemctl start anbox-container-manager.service

   systemctl --user start anbox-session-manager.service

最后再启动Anbox应用。果然，这个方法是正确的，现在可以完整的Android模拟器了：

.. figure:: ../../_static/android/startup/anbox.png
   :scale: 75

不过，此时无法接受鼠标操作。

关闭窗口，尝试命令行运行::

   anbox launch --package=org.anbox.appmgr --component=org.anbox.appmgr.AppViewActivity

参考
=======

- `Arch Linux社区文档 - Anbox <https://wiki.archlinux.org/index.php/Anbox>`_
