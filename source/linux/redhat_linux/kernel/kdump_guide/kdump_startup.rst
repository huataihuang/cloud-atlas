.. _kdump_startup:

==================
kdump快速起步
==================

:ref:`kdump` 默认在Red Hat Enterprise Linux已经安装和激活，提供内核崩溃转储机制的服务。当Linux内核崩溃时， ``kdump`` 使用 :ref:`kexec` 系统调用在不重启情况下引导到第二内核( ``捕获内核`` 即 ``capture kernel`` )，然后捕获崩溃内核的内存(奔溃转储 ``crash dump`` 或 ``vmcore`` )，然后将期保存。注意，所谓 ``第二内核`` 位于系统内存保留的一部分。

快速安装和配置
===============

.. note::

   本文安装以 :ref:`fedora` 和 CentOS 8 为案例，所以使用 :ref:`dnf` 安装命令； CentOS 7或更低版本使用 ``yum`` 命令替代

- 安装 ``kexec-tools`` ::

   sudo dnf install kexec-tools

- 配置 ``/etc/kdump.conf`` ::

   path /var/crash
   core_collector makedumpfile -l --message-level 1 -d 31

- 激活 ``kdump`` ::

   sudo systemctl enable --now kdump

- 配置 ``/etc/default/grub`` ，在 ``GRUB_CMDLINE_LINUX`` 行添加 ``crashkernel=auto`` 类似如下::

   GRUB_CMDLINE_LINUX="crashkernel=auto ..."

- 生成grub2配置::

   grub2-mkconfig -o /boot/grub2/grub.cfg

.. note::

   如果需要排查的服务器极不稳定，需要在系统hung时立即crash掉系统成成kernel core dump，则可以采用NMI watchdog: 在内核参数上再加上 ``nmi_watchdog=1``

手工触发kernel core dump
=========================

方法一: ``SysRq``
--------------------

- 登陆服务器执行以下命令触发::

   echo 1 | sudo tee /proc/sys/kernel/sysrq
   echo c | sudo tee /proc/sysrq-trigger

方法二: ``unknown NMI panic``
--------------------------------

- 登陆服务器激活 ``unknown_nmi_panic`` ::

   echo 1 | sudo tee /proc/sys/kernel/unkown_nmi_panic

- 远程通过 :ref:`ipmi` 发送 ``unknown_nmi_panic`` 信号给服务器触发kernel core dump::

   ipmitool -I lanplus -U <username> -P <password> -H <oobip> chassis power diag

参考
======

- `Red Hat Enterprise Linux 8.0 管理监控和更新内核 <https://access.redhat.com/documentation/zh-cn/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/index>`_
- `How to use kdump to debug kernel crashes <https://fedoraproject.org/wiki/How_to_use_kdump_to_debug_kernel_crashes>`_
- `arch linux kdump <https://wiki.archlinux.org/title/Kdump>`_
- `获取内核core dump <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/kernel/tracing/get_kernel_core_dump.md>`_ 我在很久以前的一些kernel kdump经验
