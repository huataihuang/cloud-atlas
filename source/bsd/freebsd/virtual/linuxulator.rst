.. _linuxulator:

================================
Linuxulator: Linux执行程序兼容
================================

FreeBSD提供了Linux二进制程序兼容，也就是 ``Linuxulator`` ，可以在FreeBSD上直接运行无需修改的Linux二进制程序。

要激活 ``Linuxulator`` ，执行以下命令::

   kldload linux
   kldload linux64

要使配置持久化，则修改 ``/etc/rc.conf`` 添加:

.. literalinclude:: linuxulator/rc.conf
   :caption: 配置 ``/etc/rc.conf`` 持久化激活 ``Linuxulator``

执行以下命令在系统中安装CentOS 7软件包源的Linux子系统::

   pkg install linux_base-c7

根据安装提示，还需要在 ``/etc/fstab`` 中添加以下挂载配置::

   linprocfs   /compat/linux/proc      linprocfs   rw               0    0
   linsysfs    /compat/linux/sys       linsysfs    rw               0    0
   tmpfs       /compat/linux/dev/shm   tmpfs       rw, mode=1777    0    0

然后执行以下命令挂载上述兼容文件系统::

   mount /compat/linux/proc
   mount /compat/linux/sys
   mount /compat/linux/dev/shm

当然，也可以重启系统生效

.. note::

   目前我还没有实践，我可能会在兼容开发一些Linux软件时来实践本文

参考
======

- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_
