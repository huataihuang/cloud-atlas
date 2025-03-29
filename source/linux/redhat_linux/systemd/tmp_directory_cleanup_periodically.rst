.. _tmp_directory_cleanup_periodically:

=========================
/tmp临时目录定期清理机制
=========================

.. note::

   众所周知，Linux系统会定时清理 ``/tmp`` 临时目录下的不使用(访问)文件。但是，可能不太关注清理周期和清理配置。

   很久以前，曾经有同事问过我这个问题，当时我特意去google并了解清理机制。最近，又遇到一个哭笑不得的线上异常，有程序在 ``/tmp`` 目录下存储几十G的临时日志(可能有十数万小文件)，导致 ``/tmp`` 目录撑爆了系统 ``/`` 根目录影响了系统服务运行。所以，我在原学习笔记基础上再次整理和解决上述问题。

.. note::

   如果系统根目录被打爆，则会影响很多系统服务运行。如果一时找不到那些文件占用了系统磁盘，则可以首先尝试 :ref:`journalctl` 快速缩小系统日志占用空间，然后尝试用 :ref:`ncdu` 定位占用磁盘空间的目录和文件再进行清理。本文就是使用这个流程找到 ``/tmp`` 大量占用空间，然后采用本文自动清理机制完成系统根目录清理和保持。

CentOS/RHEL 7/8 清理 ``/tmp`` 机制
=======================================

从 CentOS/RHEL 7开始，采用 ``systemd-tmpfile`` 服务来周期性清理 ``/tmp`` 目录。配置文件是 ``/usr/lib/tmpfiles.d/tmp.conf`` ，针对上文 ``/tmp`` 目录被临时文件堵塞问题，如果确实不需要保留长时间(10天)临时文件，可以采用将 ``/tmp`` 目录保留文件配置修订成 2 天:

.. literalinclude:: tmp_directory_cleanup_periodically/tmp.conf
   :language: bash
   :caption: systemd-tmpfile服务配置定时清理临时文件
   :emphasize-lines:  11-12

- 重启 ``systemd-tmpfiles-clean.service`` 服务::

   systemctl restart systemd-tmpfiles-clean.service

重启以后，可以看到 ``/tmp`` 目录占用空间大为缩小，从原先 25G 缩减到 5.9G ，而且能够确保持续清理

- 从 ``systemctl status systemd-tmpfiles-clean.service`` 可以看到，该服务实际上是一个命令行::

   /usr/bin/systemd-tmpfiles --clean

实际上手工执行该命令也能清理 ``/tmp`` 目录(根据配置)

- 周期性调用 ``systemd-tmpfiles-clean.service`` 是通过 ``systemd`` 的一个计时器配置 ``systemd-tmpfiles-clean.timer`` 完成的，这个计时器在系统启动时就会运行，定时会调用 ``systemd-tmpfiles-clean.service`` 完成临时文件清理

CentOS/RHEL 6 清理 ``/tmp`` 机制
===================================

CentOS/RHEL 6需要安装一个名为 ``tmpwatch`` 的工具来自动处理 ``/tmp`` 目录下的过期文件。这个工具包通常会安装，但是如果你的系统是最小化安装，则可能没有这个工具。

- 安装 ``tmpwatch`` ::

   sudo yum install tmpwatch

安装了这个 ``tmpwatch`` 工具包之后。cronjob的配置目录中会增加一个 ``/etc/cron.daily/tmpwatch`` 定时任务配置文件，内容如下:

.. literalinclude:: tmp_directory_cleanup_periodically/tmpwatch
   :language: bash
   :caption: tmpwatch工具脚本，可修订脚本缩短清理周期
   :emphasize-lines:  6-7

不同发行版的 ``/tmp`` 清理配置
=================================

根据不同发行版，提供了不同的清理 ``/tmp`` 配置方法:

- Ubuntu 14: 通过 ``/etc/cron.daily`` 定时调用 ``tmpreaper`` 清理 ``/tmp`` 谬，配置位于 ``/etc/default/rcS`` 和 ``/etc/tmpreaper.conf``
- Ubuntu 16:  使用 ``tmpfiles.d`` 
- 其他Debian系统: 启动时在 ``/etc/default/rcS`` 定义清理规则
- RedHat系列系统见上文
- Gentoo 通过 ``/etc/conf.d/bootmisc`` 配置

参考
======

- `CentOS / RHEL 6,7 : Why the files in /tmp directory gets deleted periodically <https://www.thegeekdiary.com/centos-rhel-67-why-the-files-in-tmp-directory-gets-deleted-periodically/>`_
- `When does /tmp get cleared? <https://serverfault.com/questions/377348/when-does-tmp-get-cleared>`_
