.. _freebsd_jail_destroy:

==========================
FreeBSD Jail销毁
==========================

销毁一个jail并不是简单的停止jail和删除jiail目录以及对应配置那么简单:

- FreeBSD的一些文件标志的特定文件即使root用户也无法删除，需要通过 ``chflags`` 命令移除标志才能清理

销毁jail的步骤
===================

- 停止需要销毁的jail

.. literalinclude:: freebsd_jail_admin/jail_stop
   :caption: 停止jail

- 使用 ``chflags`` 命令移除文件标志:

.. literalinclude:: freebsd_jail_admin/chflags
   :caption: 使用 ``chflags`` 命令移除文件标志

- 然后删除jail所在目录，或者zfs销毁卷:

.. literalinclude:: freebsd_jail_admin/rm_dir
   :caption: 删除zfs卷

- 清除 ``/etc/jail.conf`` 或 ``/etc/jail.conf.d/`` 目录下配置
