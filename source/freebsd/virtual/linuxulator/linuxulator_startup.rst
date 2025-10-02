.. _linuxulator_startup:

================================
Linuxulator 快速起步
================================

FreeBSD提供了Linux二进制程序兼容，也就是 ``Linuxulator`` ，可以在FreeBSD上直接运行无需修改的Linux二进制程序。

要激活 ``Linuxulator`` ，执行以下命令:

.. literalinclude:: linuxulator_startup/kldload
   :caption: 加载linux模块激活 ``Linuxulator``

- 要使配置持久化，则修改 ``/etc/rc.conf`` 添加:

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

   如果已经安装过旧版本 ``linux_base-c7`` 可以先移除，然后再安装 ``linux_base-rl9`` ( **Rocky Linux 9 userland** ):

   .. literalinclude:: linuxulator_startup/remove_c7
      :caption: 移除CentOS 7 Linux系统

根据安装提示，还需要在 ``/etc/fstab`` 中添加以下挂载配置::

   linprocfs   /compat/linux/proc      linprocfs   rw               0    0
   linsysfs    /compat/linux/sys       linsysfs    rw               0    0
   tmpfs       /compat/linux/dev/shm   tmpfs       rw, mode=1777    0    0

然后执行以下命令挂载上述兼容文件系统::

   mount /compat/linux/proc
   mount /compat/linux/sys
   mount /compat/linux/dev/shm

当然，也可以重启系统生效

- 升级 **Rocky Linux 9 userland** :

.. literalinclude:: linuxulator_startup/update
   :caption: 升级 **Rocky Linux 9 userland**

.. warning::

   默认 ``linux_base-rl9`` 是 **minimal** 版本，没有提供 :ref:`dnf` 。所以需要通过 :ref:`linuxulator_rocky-base` 来构建一个更完整系统才能执行本段更新

.. note::

   这里有一个问题，我在FreeBSD 15上实践 ``linuxulator`` ，发现 ``linux_base-rl9`` 没有包含 :ref:`dnf` ，似乎是一个不完整的环境。难道需要像 :ref:`linux_jail_ubuntu-base` 一样用官方的 ``core.txz`` 包来构建基础环境？

   `Rocky Linux download > 9 > images > x86_64 <https://download.rockylinux.org/pub/rocky/9/images/x86_64/>`_ 提供了 `Rocky-9-Container-Minimal.latest.x86_64.tar.xz <https://download.rockylinux.org/pub/rocky/9/images/x86_64/Rocky-9-Container-Minimal.latest.x86_64.tar.xz>`_ ，虽然是针对 :ref:`container` 的镜像压缩包，但是jail非常类似container，实际上都剥离了 :ref:`systemd` ，应该可以共用

   另外 `Rocky Linux 9 minimal jail working, need to figure out the next steps <https://forums.freebsd.org/threads/rocky-linux-9-minimal-jail-working-need-to-figure-out-the-next-steps.94933/page-2>`_ 提到了通过 :ref:`podman` 保存镜像 ``tar.gz`` 文件也是一个思路，实际上和 :ref:`transfer_docker_image_without_registry` 中 ``docker save`` 是异曲同工。

- (可选)安装Python 3

.. literalinclude:: linuxulator_startup/install_python3
   :caption: 安装 python 3

- (可选)安装开发工具(对于很多python包需要)

.. literalinclude:: linuxulator_startup/install_develop
   :caption: 安装开发工具

- (可选)安装pip for Python 3

.. literalinclude:: linuxulator_startup/install_pip
   :caption: 安装pip for Python 3

参考
======

- `Install FreeBSD with XFCE and NVIDIA Drivers [2021] <https://nudesystems.com/install-freebsd-with-xfce-and-nvidia-drivers/>`_
- `Chapter 12. Linux Binary Compatibility <https://docs.freebsd.org/en/books/handbook/linuxemu/>`_
