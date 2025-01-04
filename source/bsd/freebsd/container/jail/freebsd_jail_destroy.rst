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

.. literalinclude:: freebsd_jail_admin/zfs_destroy
   :caption: 删除zfs卷

- 清除 ``/etc/jail.conf`` 或 ``/etc/jail.conf.d/`` 目录下配置

无法销毁zfs问题排查
======================

我遇到一个问题，销毁 ``dev-1`` 和 ``dev-2`` 的两个zfs卷正常，但是尝试删除 ``dev`` 卷:

.. literalinclude:: freebsd_jail_admin/zfs_destroy
   :caption: 删除zfs卷

.. literalinclude:: freebsd_jail_admin/zfs_destroy_error
   :caption: 删除zfs卷报错

我确定已经停止了jail( ``jls`` 已经无输出)，甚至重启了操作系统，但是报错依旧。

执行 ``lsof | grep containers`` 看到如下输出:

.. literalinclude:: freebsd_jail_admin/lsof_output
   :caption: ``lsof`` 输出确实显示有访问存在
   :emphasize-lines: 3,4

可以看到十一个 ``1766`` 进程在使用中，这个 ``1766`` 进程如下:

.. literalinclude:: freebsd_jail_admin/process_1766
   :caption: 仍然在使用zroot中容器目录的进程

这个问题在 `Bug 254024 - devel/gvfs: gvfsd-trash latches to zfs volumes  <https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=254024>`_ 已经有报告bug，看起来是Trash服务监控zfs卷存在问题(glibc问题?)，例如xfce的垃圾箱回收就使用 ``gvfsd-trash`` 。

可以先临时杀掉 ``gvfsd-trash`` 进程来解决 ``zfs destroy`` 卡住问
