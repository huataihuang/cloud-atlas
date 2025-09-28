.. _linuxulator_startup:

================================
Linuxulator 快速起步
================================

FreeBSD提供了Linux二进制程序兼容，也就是 ``Linuxulator`` ，可以在FreeBSD上直接运行无需修改的Linux二进制程序。

要激活 ``Linuxulator`` ，执行以下命令::

   kldload linux
   kldload linux64

要使配置持久化，则修改 ``/etc/rc.conf`` 添加:

.. literalinclude:: linuxulator_startup/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 持久化激活 ``Linuxulator``

- 安装Rocky Linux 9 userland:

.. literalinclude:: linuxulator_startup/install_rl9
   :caption: 安装Rocky Linux 9 userland

.. note::

   根据handbook说明， ``Linux userlands`` 当前推荐采用 **Rocky Linux 9 userland** 

   以前的 CentOS 7 不建议采用 (废弃) :strike:`执行以下命令在系统中安装CentOS 7软件包源的Linux子系统` :

   .. literalinclude:: linuxulator_startup/install_c7
      :caption: 安装CentOS 7软件包源的Linux子系统

根据安装提示，还需要在 ``/etc/fstab`` 中添加以下挂载配置::

   linprocfs   /compat/linux/proc      linprocfs   rw               0    0
   linsysfs    /compat/linux/sys       linsysfs    rw               0    0
   tmpfs       /compat/linux/dev/shm   tmpfs       rw, mode=1777    0    0

然后执行以下命令挂载上述兼容文件系统::

   mount /compat/linux/proc
   mount /compat/linux/sys
   mount /compat/linux/dev/shm

当然，也可以重启系统生效

参考
======

- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_
- `Chapter 12. Linux Binary Compatibility <https://docs.freebsd.org/en/books/handbook/linuxemu/>`_
