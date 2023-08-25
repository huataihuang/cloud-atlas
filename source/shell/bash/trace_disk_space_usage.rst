.. _trace_disk_space_usage:

======================
排查磁盘空间消耗
======================

在生产环境中，经常会遇到磁盘被耗尽的问题需要排查，通常我们会使用2个工具:

- ``df`` 检查文件系统总体使用情况

  - ``-i`` 参数查看 ``inode`` 占用情况，这个参数非常常用，因为很多时候会忽视掉 ``inode`` 被耗尽导致即使有空间内也无法存储数据问题

- ``du`` 检查目录占用磁盘情况

  - ``-sh *`` 可帮助我们检查当前目录下子目录占用空间

ncdu
=========

不过，我们经常会需要找出磁盘中占用最多的目录进行排查和清理，这时候，有一个基于 ``ncurse`` 终端交互命令 ``ncdu`` 非常有用，提供了默认从大到小排序功能，并且启动时完成扫描，然后就可以交互找到最占用磁盘空间的目录:

.. figure:: ../../_static/shell/bash/ncdu.png

直接找出占用空间最大的目录(剔除子目录)
========================================

那么我们在脚本中该如何找到占用最大的目录呢？

虽然我们可以使用 ``du -sh *`` 一级级查找，但是在脚本中需要使用一条命令来找到最多消耗的目录:

.. literalinclude:: trace_disk_space_usage/du_large_dir
   :caption: 查找消耗磁盘空间最大的目录

输出类似:

.. literalinclude:: trace_disk_space_usage/du_large_dir_output
   :caption: 查找消耗磁盘空间最大的目录输出案例(占用最大空间的的是容器镜像)
   :emphasize-lines: 1

为何要使用 ``-S`` 参数而不是常用的 ``-s`` (小写)参数呢？

::

   -S, --separate-dirs   for directories do not include size of subdirectories
   -s, --summarize       display only a total for each argument

这是因为我们希望能够直接找出是哪个目录包含了最多空间占用的文件，而不是一个目录包含了所有子目录的空间统计。这样会非常方便真正找到可以清理空间的最大占用目录。

排除(不包括)指定目录
-----------------------

此外，如果在根目录上执行上述命令，往往会把多个磁盘挂载都统计在内。而有时候我们已经知道某些磁盘挂载目录不必统计，该如何剔除呢？

``du`` 提供了一个 ``--exclude=`` 参数，并且可以多次使用，可以将多个挂载目录排除在统计范围之外，举例::

   du -Sh --exclude=./var/lib/docker | sort -rh | head -5

这里 ``/var/lib/docker`` 是我单独挂载的 :ref:`btrfs` 磁盘目录，无需统计。另外需要注意，一定要在在前面加一个 ``.`` 表示当前目录(这点虽然有点奇怪)，即使用 ``--exclude=./var/lib/docker`` 而不是 ``--exclude=/var/lib/docker`` ，否则还会统计进去。

只检查当前文件系统
---------------------

在Linux系统中，能够挂载多个文件系统(磁盘分区)到各个挂载点( ``mount`` )，这就带来一个问题，如果在 ``/`` 根目录下执行 ``du -Sh`` 会将整个系统所有挂载目录(文件系统)全部扫描一遍。对于生产环境的海量文件系统，几乎是 `不可能完成的任务 <https://movie.douban.com/subject/1292484/>`_ 。

当然，我们可以使用上面所说的 ``--exclude`` 参数来一一指定排除的目录，但是一来繁琐，二来很多情况下就是一个简单的统计根磁盘空间使用，不包含其他数据存储磁盘。这时，有一个非常有用的参数:

- ``--one-file-system`` ( ``-x`` ): 跳过其他文件系统目录。这样，如果 ``/var/log`` 目录单独挂载，则不会被统计 ``/`` 目录时计入，确保只统计一个目录下的磁盘空间，而不会跨物理磁盘

上述检查磁盘消耗目录的命令可以改进为:

.. literalinclude:: trace_disk_space_usage/du_current_dir
   :language: bash
   :caption: 只统计当前目录挂载磁盘的使用空间(不跨物理磁盘)

通过这个方式，检查生产环境的一个案例，就可以发现非常奇怪的磁盘消耗:

.. literalinclude:: trace_disk_space_usage/du_current_dir_output
   :language: bash
   :caption: 只统计当前/目录挂载磁盘的使用空间，发现异常的空间消耗
   :emphasize-lines: 1,2,6

删除文件不释放空间
===================

在线上环境，我们经常会发现有些(大)文件被删除后却没有释放空间: 这通产是因为运行的进程打开文件进行读写，但是文件被强行删除，此时文件句柄没有释放，则对操作系统来说删除的文件占用空间不会释放。

- 首先我们要找出这些被强行杀出但是没有释放空间的文件，以及对应的还没有释放句柄的进程::

   lsof | egrep "deleted|COMMAND"

例如输出::

   COMMAND      PID    TID TASKCMD              USER   FD      TYPE             DEVICE SIZE/OFF       NODE NAME
   networkd-   1645                             root  txt       REG                8,2  5490448    1835478 /usr/bin/python3.8 (deleted)
   unattende   1748                             root  txt       REG                8,2  5490448    1835478 /usr/bin/python3.8 (deleted)
   unattende   1748   1794 gmain                root  txt       REG                8,2  5490448    1835478 /usr/bin/python3.8 (deleted)
   none        2167                             root  txt       REG                0,1    17032      23779 / (deleted)
   squid     327045                             root    4u      REG                8,2    49320     527495 /var/log/squid/cache.log.1 (deleted)
   squid     357059                            proxy    4u      REG                8,2    49320     527495 /var/log/squid/cache.log.1 (deleted)

- 对于已经被强制删除的文件，空间不释放的解决方法通常是把依然打开文件句柄的进程重启掉，例如，上文中，我们可以通过重启 ``327045`` 和 ``357059`` (squid) 来真正释放空间

- 但是，有时候我们不能停止进程，又该如何释放之前被错误删除文件对应的空间呢？解决方法是从 ``/proc/<pid>/fd/<fd_number>`` 入手来 ``truncate`` 文件::

   echo > /proc/<pid>/fd/<fd_number>

举例上文 ``327045`` 和 ``357059`` (squid) 进程::

   file /proc/327045/fd/4

可以看到::

   /proc/327045/fd/4: symbolic link to /var/log/squid/cache.log.1 (deleted)

详细情况::

   ls -lh /proc/327045/fd/4

显示::

   lrwx------ 1 root proxy 64 Aug 26 15:44 /proc/327045/fd/4 -> '/var/log/squid/cache.log.1 (deleted)'

我们来清理掉这个占用空间::

   echo > /proc/327045/fd/4

此时，虽然文件句柄还不释放，但是已经把该文件句柄对应文件系统空间完全清零了，也就是释放出了空间

参考
======

- `Tracking down where disk space has gone on Linux? <https://unix.stackexchange.com/questions/125429/tracking-down-where-disk-space-has-gone-on-linux>`_
- `Why is space not being freed from disk after deleting a file in Red Hat Enterprise Linux? <https://access.redhat.com/solutions/2316>`_
- `Using --exclude with the du command <https://unix.stackexchange.com/questions/23692/using-exclude-with-the-du-command>`_
- `Showing Disk Usage Only for the Top Level Partition <https://unix.stackexchange.com/questions/646039/showing-disk-usage-only-for-the-top-level-partition>`_
- `Make du's output more useful with this neat trick <https://www.redhat.com/sysadmin/sort-du-output>`_
