.. _install_waydroid:

====================
安装Waydroid
====================

.. note::

   本文实践在Raspberry Pi OS(Debian)上执行，但是目前我还没有解决运行应用问题。从资料来看，在 x86_64 硬件环境下运行 waydroid 可能解决成熟度更高，有资料显示采用 `Running Redroid on Raspberry Pi #67 <https://github.com/remote-android/redroid-doc/issues/67>`_ 是可行的，所以后续还可以继续尝试

准备工作
==========

- 系统需要curl::

   sudo apt install curl -y

Waydroid需要以下软件环境:

- python3
- lxc
- curl
- Wayland session manager (重要)

.. note::

   NVIDIA GPU当前不支持

安装
======

- 安装 ``ca-certificates`` ::

   sudo apt install ca-certificates

- 检查发行版的codename ::

   lsb_release -c

显示::

   Codename:       bullseye

- 添加WayDroid仓库:

.. literalinclude:: install_waydroid/add_waydroid_repo
   :language: bash
   :caption: 添加WayDroid仓库

- 安装Waydroid::

   sudo apt install waydroid -y

- 启动初始化::

   sudo waydroid init

- 启动waydroid容器服务::

   sudo systemctl start waydroid-container

然后检查状态::

   sudo systemctl status waydroid-container

正常的可以看到::

   ● waydroid-container.service - Waydroid Container
        Loaded: loaded (/lib/systemd/system/waydroid-container.service; enabled; vendor preset: enabled)
        Active: active (running) since Fri 2022-05-06 11:25:59 CST; 9s ago
      Main PID: 202235 (waydroid)
         Tasks: 1 (limit: 3954)
           CPU: 286ms
        CGroup: /system.slice/waydroid-container.service
                └─202235 /usr/bin/python3 /usr/bin/waydroid container start
   
   May 06 11:25:59 pi-dev systemd[1]: Started Waydroid Container.

如果不是用 :ref:`systemd` 则使用如下命令手工启动容器::

   sudo waydroid container start

- 然后启动waydroid session(不需要sudo)::

   waydroid session start

屏幕输出可能有如下信息::

   [19:51:31] XDG Session is not "wayland"
   [19:51:35] Failed to start Clipboard manager service, check logs
   [19:51:35] Failed to add service waydroidusermonitor: -1
   [gbinder] WARNING: Service manager /dev/binder has died

注意，这里的 ``WARNING`` 信息参考 `[gbinder] WARNING: Service manager /dev/binder has died #136 <https://github.com/waydroid/waydroid/issues/136>`_ ，需要在内核命令行参数添加 ``psi=1`` 来激活 `PSI <https://www.kernel.org/doc/html/latest/accounting/psi.html>`_ 。

不过我在Raspberry Pi OS，修订 ``/boot/cmdline.txt`` 在内核参数添加了 ``psi=1`` 并重启，然后检查 ``/proc/cmdline`` 可以看到 ``psi=1`` ，但是上述报错 ``[gbinder] WARNING: Service manager /dev/binder has died`` 依旧。

检查 ``dmesg -T`` 输出可以看到::

   [Fri May  6 20:39:49 2022] binder: 460:1487 transaction failed 29189/-22, size 0-0 line 2603
   [Fri May  6 20:39:50 2022] binder: 1284:1493 transaction failed 29189/-22, size 0-0 line 2603
   ...

参考 `Missing dependency when building images for Raspberry Pi 4 #225 <https://github.com/waydroid/waydroid/issues/225>`_ ，原来第一个提示 ``XDG Session is not "wayland"`` 是可以通过参数消除的::

   XDG_SESSION_TYPE=wayland waydroid session start

所以，在 ``/etc/environment`` 中添加环境变量::

   XDG_SESSION_TYPE=wayland

此时就只会提示错误::

   [20:55:32] Failed to start Clipboard manager service, check logs
   [20:55:32] Failed to add service waydroidusermonitor: -1
   [gbinder] WARNING: Service manager /dev/binder has died

不过，从 `[gbinder] WARNING: Service manager /dev/binder has died #136 <https://github.com/waydroid/waydroid/issues/136>`_ 看，使用 `XanMod Kernel <https://xanmod.org/>`_ 5.14.11-xanmod1-1 加上内核参数 ``psi=1`` 是可以解决这个问题的。不过， XanMod Kernel只支持 ``x86_64`` 处理器，无法用于ARM架构

有一个 `remote-android 文档 <https://github.com/remote-android/redroid-doc>`_ 提供了在不同架构上构建 Android 的思路，这个项目是为了在远程服务器上运行Android构建的，也是通过容器运行Android。后续再借鉴学习...

我参考 `arch linux Waydroid <https://wiki.archlinux.org/title/Waydroid>`_ 的 ``Failed to start Clipboard manager service`` 解决方案，安装 ``python3-pyclipper`` ::

   sudo apt install python3-pyclipper

意外发现，启动 ``waydroid session start`` 时候不再报 ``WARNING`` (好像也不是，首次启动还是提示 ``Service manager /dev/binder has died`` ，但再次启动则提示正常)::

   [22:39:41] Failed to start Clipboard manager service, check logs
   [gbinder] Service manager /dev/binder has appeared
   [22:39:41] Failed to add service waydroidusermonitor: -1

但是 ``Failed to start Clipboard manager service`` 依旧

从 ``dmesg -T`` 来看::

   [Fri May  6 23:57:28 2022] libprocessgroup: Failed to make and chown /acct/uid_1069: Read-only file system
   [Fri May  6 23:57:28 2022] init: createProcessGroup(1069, 405) failed for service 'lmkd': Read-only file system
   [Fri May  6 23:57:28 2022] init: Created socket '/dev/socket/lmkd', mode 660, user 1000, group 1000
   [Fri May  6 23:57:28 2022] init: Service 'lmkd' (pid 405) exited with status 0
   [Fri May  6 23:57:28 2022] init: Sending signal 9 to service 'lmkd' (pid 405) process group...
   [Fri May  6 23:57:28 2022] libprocessgroup: Successfully killed process cgroup uid 1069 pid 405 in 0ms
   [Fri May  6 23:57:33 2022] init: starting service 'lmkd'...
   [Fri May  6 23:57:33 2022] libprocessgroup: Failed to make and chown /acct/uid_1069: Read-only file system
   [Fri May  6 23:57:33 2022] init: createProcessGroup(1069, 408) failed for service 'lmkd': Read-only file system
   [Fri May  6 23:57:33 2022] init: Created socket '/dev/socket/lmkd', mode 660, user 1000, group 1000
   [Fri May  6 23:57:33 2022] init: Service 'lmkd' (pid 408) exited with status 0
   [Fri May  6 23:57:33 2022] init: Sending signal 9 to service 'lmkd' (pid 408) process group...
   [Fri May  6 23:57:33 2022] libprocessgroup: Successfully killed process cgroup uid 1069 pid 408 in 0ms
   [Fri May  6 23:57:33 2022] init: critical process 'lmkd' exited 4 times before boot completed
   [Fri May  6 23:57:33 2022] init: #00 pc 00000000000672c4  /system/bin/init (android::init::InitFatalReboot()+80)
   [Fri May  6 23:57:33 2022] init: #01 pc 000000000008e7a0  /system/bin/init (android::init::InitAborter(char const*)+44)
   [Fri May  6 23:57:33 2022] init: #02 pc 000000000000c5b4  /system/lib64/libbase.so (android::base::LogMessage::~LogMessage()+608)
   [Fri May  6 23:57:33 2022] init: #03 pc 000000000006cd60  /system/bin/init (android::init::Service::Reap(siginfo const&)+1188)
   [Fri May  6 23:57:33 2022] init: #04 pc 000000000007b744  /system/bin/init (android::init::ReapAnyOutstandingChildren()+640)
   [Fri May  6 23:57:33 2022] init: #05 pc 000000000004ba58  /system/bin/init (android::init::HandleSignalFd()+112)
   [Fri May  6 23:57:33 2022] init: #06 pc 000000000004d19c  /system/bin/init (_ZN7android4init5Epoll4WaitENSt3__18optionalINS2_6chrono8durationIxNS2_5ratioILl1ELl1000EEEEEEE+448)
   [Fri May  6 23:57:33 2022] init: #07 pc 000000000004a3ac  /system/bin/init (android::init::SecondStageMain(int, char**)+7952)
   [Fri May  6 23:57:33 2022] init: #08 pc 000000000002218c  /system/bin/init (main+304)
   [Fri May  6 23:57:33 2022] init: #09 pc 000000000007d780  /system/lib64/bootstrap/libc.so (__libc_init+108)
   [Fri May  6 23:57:33 2022] init: Reboot ending, jumping to kernel
   [Fri May  6 23:57:33 2022] binder: release 31592:31592 transaction 51905 out, still active
   [Fri May  6 23:57:33 2022] binder: undelivered TRANSACTION_COMPLETE
   [Fri May  6 23:57:33 2022] binder: release 31614:31614 transaction 51293 out, still active
   [Fri May  6 23:57:33 2022] binder: undelivered TRANSACTION_COMPLETE
   [Fri May  6 23:57:33 2022] waydroid0: port 1(vethoAgJWe) entered disabled state
   [Fri May  6 23:57:33 2022] device vethoAgJWe left promiscuous mode
   [Fri May  6 23:57:33 2022] waydroid0: port 1(vethoAgJWe) entered disabled state
   [Fri May  6 23:57:33 2022] binder: release 31390:31407 transaction 51293 in, still active
   [Fri May  6 23:57:33 2022] binder: send failed reply for transaction 51293, target dead
   [Fri May  6 23:57:33 2022] binder: release 31390:31408 transaction 51905 in, still active
   [Fri May  6 23:57:33 2022] binder: send failed reply for transaction 51905, target dead

参考 `ANDROID STUDIO: failed to make and chown /acct/uid_10057:Read-onnly file system <http://blerow.blogspot.com/2015/02/android-studio-failed-to-make-and-chown.html>`_ 等资料，看起来模拟器运行的虚拟设备问题，需要删除设备重新创建设备

参考 `Waydroid General Troubeshooting <https://docs.waydro.id/debugging/troubleshooting>`_ 重新初始化::

   sudo systemctl stop waydroid-container.service

   # 清理环境
   sudo rm -rf /var/lib/waydroid
   rm -rf ~/.waydroid
   rm -rf ~/waydroid
   rm -rf ~/.share/waydroid
   rm -rf ~/.local/share/applications/*aydroid*
   rm -rf ~/.local/share/waydroid

   # 初始化
   sudo waydroid init -f 

   # 再次启动服务
   sudo systemctl start waydroid-container.service

其他
=========

- 检查waydroid状态::

   waydroid status

显示输出::

   Session:        RUNNING
   Container:      RUNNING
   Vendor type:    MAINLINE
   Session user:   huatai(1000)
   Wayland display:        wayland-0

然后，就可以 :ref:`install_run_app_in_waydroid`

参考
======

- `Waydroid Install Instructions <https://docs.waydro.id/usage/install-on-desktops>`_
- `arch linux Waydroid <https://wiki.archlinux.org/title/Waydroid>`_
