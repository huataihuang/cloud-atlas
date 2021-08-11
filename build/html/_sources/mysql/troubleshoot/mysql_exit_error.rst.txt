.. _mysql_exit_error:

=======================
MySQL服务退出错误排查
=======================

mysql exited with error code
=============================

个人搭建的基于 :ref:`ghost_cms` 使用了 MySQL 作为数据存储，在VPS虚拟机重启后，Ghost CMS无法使用后端MySQL。检查数据库状态::

   systemctl start mysql

提示错误::

   Job for mysql.service failed because the control process exited with error code.
   See "systemctl status mysql.service" and "journalctl -xe" for details.

mysql服务状态
----------------

- 检查服务状态输出::

   systemctl status mysql.service

显示::

   ● mysql.service - MySQL Community Server
      Loaded: loaded (/lib/systemd/system/mysql.service; enabled; vendor preset: enabled)
      Active: failed (Result: exit-code) since Tue 2021-08-10 15:43:35 CST; 23min ago
     Process: 16817 ExecStart=/usr/sbin/mysqld --daemonize --pid-file=/run/mysqld/mysqld.pid (code=exited, status=1/FAILURE)
     Process: 16796 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, status=0/SUCCESS)
    Main PID: 612 (code=killed, signal=KILL)
   
   Aug 10 15:43:35 freedom systemd[1]: mysql.service: Failed with result 'exit-code'.
   Aug 10 15:43:35 freedom systemd[1]: Failed to start MySQL Community Server.
   Aug 10 15:43:35 freedom systemd[1]: mysql.service: Service hold-off time over, scheduling restart.
   Aug 10 15:43:35 freedom systemd[1]: mysql.service: Scheduled restart job, restart counter is at 5.
   Aug 10 15:43:35 freedom systemd[1]: Stopped MySQL Community Server.
   Aug 10 15:43:35 freedom systemd[1]: mysql.service: Start request repeated too quickly.
   Aug 10 15:43:35 freedom systemd[1]: mysql.service: Failed with result 'exit-code'.
   Aug 10 15:43:35 freedom systemd[1]: Failed to start MySQL Community Server.

- 通过 ``journalctl -xe`` 检查可以看到::

   Aug 11 20:51:59 freedom systemd[1]: Starting MySQL Community Server...
   -- Subject: Unit mysql.service has begun start-up
   -- Defined-By: systemd
   -- Support: http://www.ubuntu.com/support
   --
   -- Unit mysql.service has begun starting up.
   Aug 11 20:52:00 freedom mysqld[26240]: Initialization of mysqld failed: 0
   Aug 11 20:52:00 freedom systemd[1]: mysql.service: Control process exited, code=exited status=1
   Aug 11 20:52:00 freedom systemd[1]: mysql.service: Failed with result 'exit-code'.
   Aug 11 20:52:00 freedom systemd[1]: Failed to start MySQL Community Server.

- 检查 ``/var/log/mysql/error.log`` 日志可以看到::

   2021-08-11T12:52:00.377011Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).
   2021-08-11T12:52:00.392173Z 0 [Note] /usr/sbin/mysqld (mysqld 5.7.34-0ubuntu0.18.04.1) starting as process 26242 ...
   2021-08-11T12:52:00.438647Z 0 [Note] InnoDB: PUNCH HOLE support available
   2021-08-11T12:52:00.438697Z 0 [Note] InnoDB: Mutexes and rw_locks use GCC atomic builtins
   2021-08-11T12:52:00.438703Z 0 [Note] InnoDB: Uses event mutexes
   2021-08-11T12:52:00.438707Z 0 [Note] InnoDB: GCC builtin __atomic_thread_fence() is used for memory barrier
   2021-08-11T12:52:00.438711Z 0 [Note] InnoDB: Compressed tables use zlib 1.2.11
   2021-08-11T12:52:00.438723Z 0 [Note] InnoDB: Using Linux native AIO
   2021-08-11T12:52:00.440910Z 0 [Note] InnoDB: Number of pools: 1
   2021-08-11T12:52:00.445361Z 0 [Note] InnoDB: Using CPU crc32 instructions
   2021-08-11T12:52:00.454508Z 0 [Note] InnoDB: Initializing buffer pool, total size = 128M, instances = 1, chunk size = 128M
   2021-08-11T12:52:00.456527Z 0 [ERROR] InnoDB: mmap(137428992 bytes) failed; errno 12
   2021-08-11T12:52:00.456550Z 0 [ERROR] InnoDB: Cannot allocate memory for the buffer pool
   2021-08-11T12:52:00.456560Z 0 [ERROR] InnoDB: Plugin initialization aborted with error Generic error
   2021-08-11T12:52:00.456570Z 0 [ERROR] Plugin 'InnoDB' init function returned error.
   2021-08-11T12:52:00.456577Z 0 [ERROR] Plugin 'InnoDB' registration as a STORAGE ENGINE failed.
   2021-08-11T12:52:00.456584Z 0 [ERROR] Failed to initialize builtin plugins.
   2021-08-11T12:52:00.456832Z 0 [ERROR] Aborting

   2021-08-11T12:52:00.457348Z 0 [Note] Binlog end
   2021-08-11T12:52:00.468226Z 0 [Note] Shutting down plugin 'CSV'
   2021-08-11T12:52:00.468937Z 0 [Note] /usr/sbin/mysqld: Shutdown complete

   2021-08-11T12:52:01.095959Z 0 [Warning] TIMESTAMP with implicit DEFAULT value is deprecated. Please use --explicit_defaults_for_timestamp server option (see documentation for more details).

从mysql日志来看，启动时 InnoDB初始化失败，原因是不能为缓冲池分配内存( ``InnoDB: Cannot allocate memory for the buffer pool`` )

- 观察内存使用::

   # free
                 total        used        free      shared  buff/cache   available
   Mem:         492560      290200       24268         764      178092      189576
   Swap:             0           0           0

- 之前内存应该是足够使用的，部署初始时资源足够，所以我考虑重启一次系统，观察情况

重启系统之后，果然能够正常启动mysql和ghost cms，初始内存使用状况如下::

   top - 21:23:56 up 8 min,  1 user,  load average: 0.00, 0.03, 0.03
   Tasks:  91 total,   1 running,  53 sleeping,   0 stopped,   0 zombie
   %Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
   KiB Mem :   492560 total,     9136 free,   400224 used,    83200 buff/cache
   KiB Swap:        0 total,        0 free,        0 used.    79584 avail Mem
   
     PID USER      PR  NI    VIRT    RES    SHR S %CPU %MEM     TIME+ COMMAND
     611 mysql     20   0 1164088 188936   7160 S  0.0 38.4   0:00.59 mysqld
     864 ghost     20   0  893936 104132  18964 S  0.0 21.1   0:07.43 node
     519 ghost     20   0  632608  25616   7584 S  0.0  5.2   0:01.32 ghost run
     748 proxy     20   0  155540  18752   2672 S  0.0  3.8   0:00.08 squid
     575 root      20   0  187548  10464   2564 S  0.0  2.1   0:00.13 unattended-upgr
     532 root      20   0  170736  10084   2324 S  0.0  2.0   0:00.16 networkd-dispat
     608 www-data  20   0  158748   6796   4712 S  0.0  1.4   0:00.04 nginx
     402 root      19  -1   78328   5760   5152 S  0.0  1.2   0:00.14 systemd-journal
    1040 huatai    20   0   24692   5104   3516 S  0.0  1.0   0:00.02 bash
       1 root      20   0  225020   4560   2512 S  0.0  0.9   0:02.29 systemd
     923 root      20   0  112160   4520   3488 S  0.0  0.9   0:00.01 sshd
    1054 huatai    20   0   46104   3892   3296 R  0.0  0.8   0:00.39 top

内存不足
===========

虽然重启一次后暂时满足了暂时需求，但是发现无法对系统做进一步维护，例如无法执行 ``apt upgrade`` (出现OOM)，所以最终还是采用升级VPS，将原先512M内存升级成1G，每月多支付 1.5 $。
