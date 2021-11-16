.. _anbox_kali_arm:

=============================
Kali Linux ARM环境运行Anbox
=============================

我在 :ref:`pi_400` 上将 :ref:`kali_fulltime` 。考虑到很多商业软件都有Andorid版本，并且ARM架构硬件可以直接运行原生Android程序，所以考虑采用Anbox来弥补Linux应用程序不足的缺憾。

.. warning::

   尚未成功!!!

准备工作
=============

在安装Anbox之前，需要common软件支持::

  sudo apt install software-properties-common

设置环境
------------

- 需要加载2个内核模块来运行Anbox::

   sudo modprobe ashmem_linux
   sudo modprobe binder_linux

- 加载完成后检查::

   ls -1 /dev/{ashmem,binder}

.. note::

   这段在kali linux ARM上可能不需要

安装snap
-----------

- snap是ubuntu平台打包平台，提供了独立隔离的运行环境，anbox是通过snap发行的，所以安装snapd::

   sudo apt install snapd

- 激活运行::

   sudo systemctl enable --now snapd apparmor

.. note::

   `What is apparmor? <https://askubuntu.com/questions/236381/what-is-apparmor>`_ :

   Apparmor 是一个强制访问控制(Mandatory Access Control, MAC)系统。它使用LSM内核增强来限制程序访问一些资源。AppArmor是通过系统启动时内核加载profile来实现这个限制。有2中profile，enforcement和complain。在enforcement模式，profile规则会报告犯规行为记录到syslog或者auditd。而complain模式只记录违规行为。Ubuntu默认安装了Apparmor，可以通过 ``apparmor-profiles`` 如案件包找到一些应用程序的属性。

   注意 AppArmor 是一个安全加强，我还没有实践。详细请参考原文链接。

安装Anbox
===========

- 通过snapd安装anbox

通常文档都建议使用beta通道::

   sudo snap install --devmode --beta anbox

失败::

   error: snap "anbox" is not available on beta for this architecture (arm64) but exists on other
          architectures (amd64).

看来只有 ``x86_64`` 提供了对应的beta通道anbox

我又尝试::

   sudo snap install anbox

失败::

   error: snap "anbox" is not available on this architecture (arm64) but exists on other architectures
          (amd64, armhf).

也就是说，snap只提供了32位ARM架构的Anbox和64位X86的Anbox，但是没有提供 ``aarch64`` 的64位ARM软件包

.. warning::

   暂时没有找到方法在64为ARM架构Linux上运行 Anbox
   
.. note::

   还有一个在容器中运行Android镜像的项目： `waydroid <https://github.com/waydroid/waydroid>`_ 使用 ``Wayland session manager``

参考
========

- `How to Run Android Apps in Kali Linux <https://linuxlia.com/2021/04/29/how-to-run-android-apps-in-kali-linux/>`_
- `Installing Anbox on Linux to Run Android Apps <https://linuxhint.com/anbox_linux_android/>`_
