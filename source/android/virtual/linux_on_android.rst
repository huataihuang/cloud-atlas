.. _linux_on_android:

======================
在Android中运行Linux
======================

Android是一个基于Linux开发的手机操作系统，既然Linux通过 :ref:`docker` 这样的容器化方式来运行不同的操作系统，Android当然也能采用相似的方式来部署Linux系统。实现的原理就是在Android中通过 :ref:`chroot` 来切换到一个独立的Linux文件系统，然后运行一个 jail 的Linux系统。

部署Linux
=============

* 安装 :ref:`android_busybox` 

Linux Deploy将完整的Linux操作系统放到Android中，这是因为这个应用使用了一些Linux兼容的工具，通常需要 :ref:`android_busybox` toolkit。这个busybox应用只需要简单从Google Play安装就可以。

* :ref:`root_pixel` - 手机需要rooted，这样可以授权busybox和deploy linux能够使用root权限
* 安装 :ref:`android_busybox` ，安装Linux之前需要做配置以适应发行版需求
* 安装 vnc，以便能够图形化访问Linux系统 - `VNC Viewer <https://play.google.com/store/apps/details?id=com.realvnc.viewer.android&hl=en>`_
* 从Google Play中安装 ``deploy Linux`` - 这个工具可以部署不同的Linux发行版

配置Deploy Linux
===================

在Deploy Linux之前，有以下选项可以配置(请点击右下角的配置按钮):

* 

Deploy Linux账号密码重置
==========================

我遇到一个问题是安装部署了 :ref:`alpine_linux` 之后，启动后ssh发现账号密码不正确(虽然我在config的时候指定了账号密码)，所以通过挂载 img 文件，进入该Linux系统重置密码::

   adb shell
   su
   cd /sccard
   mkdir /mnt/alpine
   mount -t ext4 -o loop alpine.img /mnt/alpine

   mount -t proc proc /mnt/alpine/proc
   mount --rebind /sys /mnt/alpine/sys
   mount --make-rslave /mnt/alpine/sys
   mount --rbind /dev /mnt/alpine/dev
   mount --make-rslave /mnt/alpine/dev

   chroot /mnt/alpine /bin/sh
   source /etc/profile
   export PS1="(chroot) $PS1"

   # alpine实际已经有一个GID为20的group：dialout
   addgroup -g 20 staff
   # adduser 提供了设置用户密码
   adduser -G staff -u 501 -h /home/huatai huatai

.. note::

   通过chroot方式进入系统目录切换操作系统方法，参考 :ref:`install_gentoo_on_mbp`

   我首次使用 ``mount -t ext4 -o loop alpine.img /mnt/alpine`` 成功，但是重启过Android再次执行有报错::

      mount: '/dev/block/loop0'->'/mnt/alpine': Block device required

   adduser`` 添加的用户shell是 ``/system/bin/sh`` 实际是android系统的shell，需要修改成alpine的 ``/bin/sh`` 。

不过，上述账号错误可能和执行安装时网络异常有关。我在较好的网络环境下再次验证安装，则非常顺利完成账号初始化。

参考
=======

- `How To Run Linux On Android With Linux Deploy <https://www.addictivetips.com/ubuntu-linux-tips/run-linux-in-android-with-linux-deploy/>`_ 
- `How to Install Ubuntu on Your Android Phone Using Linux Deploy <https://www.maketecheasier.com/install-ubuntu-on-android-linux-deploy/>`_
- 
