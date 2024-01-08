.. _gentoo_udev:

=================
Gentoo udev
=================

:ref:`udev` (user /dev)是一个面向Linux :ref:`kernel` 的 :ref:`systemd` 设备管理器。 ``udev`` 管理 ``/dev`` 目录中的设备节点并处理添加或移除设备时所有用户空间动作。

对于使用 :ref:`openrc` 的Gentoo系统， ``udev`` 通过 ``sys-apps/systemd-utils`` 软件包安装，并不依赖 :ref:`systemd`

使用
============

- 完成 ``/etc/udev/rules.d/`` 目录下规则配置修改后，可以重启操作系统或或者通过以下命令使得 ``udev`` 重新加载规则:

.. literalinclude:: ../redhat_linux/udev/udev_startup/udev_reload-rules
   :caption: ``udevadm`` 控制重新加载 ``udev`` 规则

参考
=======

- `gentoo linux wiki: udev <https://wiki.gentoo.org/wiki/Udev>`_
