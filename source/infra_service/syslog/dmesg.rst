.. _dmesg:

================
dmesg
================

dmesg的数据
============

``dmesg`` 并不是从 ``/var/log/dmesg`` 文件中读取数据，而是直接从内核的 ``ring buffer`` 中直接读取，并输出最近的N个消息。当主机启动过程最后， ``dmesg`` 发起一个将启动信息写入 ``/var/log/dmesg`` 。一旦在系统中运行了 ``syslogd`` ``rsyslogd`` ( :ref:`rsyslog` ) 或者 :ref:`syslog-ng` ，这些syslog服务就会从内核缓存(kernel buffer)中读取数据并写入 ``/var/log/kern.log``
这样的文件(基于发行版不同，可能会有其他文件)。只要系统能够写入磁盘，在系统crash之前，日志服务会不断将buffer中信息刷入磁盘日志文件，也就是能够从这些日志中获取系统信息。

常用dmesg命令
===============

- 默认没有任何参数时， ``dmesg`` 将输出所有在 kernel ring buffer 中的消息::

   dmesg

- 为了方便查看，可以结合 ``less`` 命令::

   dmesg | less

- 为了显示有关内存，硬盘，usb以及唇口信息，可以分别使用如下命令::

   dmesg | grep -i memory
   dmesg | grep -i dma
   dmesg | grep -i usb
   dmesg | grep -i tty

或者合并上述命令::

   dmesg | grep -E "memory|dma|ubs|tty"

- 如果要在读取之后清理掉dmesg日志，可以使用 ``-C`` 参数::

   dmesg -C

不过，一般没有必要

- ``有用的技巧`` : 显示彩色输出信息 ``-L`` 参数::

   dmesg -L

这个命令参数对于查看错误信息非常有用，特别会看到错误信息或者关键信息使用红色标记出来，非常醒目

- 只查看 daemon 相关信息::

   dmesg --facility=daemon

就能够看到很多和 :ref:`systemd` 相关服务信息，便于集中排查服务问题

上述 ``--facility`` 支持的参数有:

  - kern
  - user
  - mail
  - daemon
  - auth
  - syslog
  - lpr
  - news

- 查看指定级别的信息也是排查问题非常有用的参数，例如 ``--level=err,warn`` ::

   dmesg --level=err,warn

- 时间戳参数 ``-T`` 可以显示易于阅读的消息::

   dmesg -T

此外，有一个 ``x`` 参数结合起来更为方便::

   dmesg -Tx

可以看到不同级别信息，例如::

   kern  :notice: [Wed Mar 23 15:32:02 2022] RPC: fragment too large: 1949507633
   kern  :notice: [Wed Mar 23 15:32:02 2022] RPC: fragment too large: 1949507633
   kern  :warn  : [Wed Mar 23 15:32:08 2022] net_ratelimit: 15 callbacks suppressed
   kern  :info  : [Wed Mar 23 15:32:08 2022] TCP: tcp_parse_options: Illegal window scaling value 123 > 14 received
   kern  :notice: [Wed Mar 23 15:32:32 2022] RPC: fragment too large: 50331667
   kern  :notice: [Wed Mar 23 15:32:32 2022] RPC: fragment too large: 50331691
   kern  :info  : [Wed Mar 23 15:32:40 2022] TCP: tcp_parse_options: Illegal window scaling value 123 > 14 received
   kern  :info  : [Wed Mar 23 15:33:33 2022] TCP: tcp_parse_options: Illegal window scaling value 123 > 14 received
   kern  :err   : [Fri Mar 25 11:57:55 2022] ata1.00: exception Emask 0x0 SAct 0x10000000 SErr 0x0 action 0x6 frozen
   kern  :err   : [Fri Mar 25 11:57:55 2022] ata1.00: failed command: READ FPDMA QUEUED
   kern  :err   : [Fri Mar 25 11:57:55 2022] ata1.00: cmd 60/08:e0:c8:70:11/00:00:20:00:00/40 tag 28 ncq dma 4096 in
                                                      res 40/00:00:00:4f:c2/00:00:00:00:00/00 Emask 0x4 (timeout)
   kern  :err   : [Fri Mar 25 11:57:55 2022] ata1.00: status: { DRDY }
   kern  :info  : [Fri Mar 25 11:57:55 2022] ata1: hard resetting link
   kern  :info  : [Fri Mar 25 11:57:55 2022] ata1: SATA link up 6.0 Gbps (SStatus 133 SControl 300)
   kern  :info  : [Fri Mar 25 11:57:55 2022] ata1.00: configured for UDMA/133
   kern  :info  : [Fri Mar 25 11:57:55 2022] ata1: EH complete
   kern  :info  : [Fri Mar 25 11:57:55 2022] ata1.00: Enabling discard_zeroes_data
   kern  :err   : [Fri Mar 25 11:59:30 2022] ata1.00: exception Emask 0x0 SAct 0x1000000 SErr 0x0 action 0x6 frozen
   kern  :err   : [Fri Mar 25 11:59:30 2022] ata1.00: failed command: READ FPDMA QUEUED
   kern  :err   : [Fri Mar 25 11:59:30 2022] ata1.00: cmd 60/08:c0:40:65:5a/00:00:00:00:00/40 tag 24 ncq dma 4096 in
                                                      res 40/00:01:00:00:00/00:00:00:00:00/00 Emask 0x4 (timeout)
   kern  :err   : [Fri Mar 25 11:59:30 2022] ata1.00: status: { DRDY }

- 实时系统信息输出，可以使用参数 ``--follow`` ，结合上面的 ``-Tx`` 参数，对于观察不断输出的系统日志非常方便::

   dmesg -Tx --follow

参考
======

- `10 tips about ‘dmesg’ command for Linux Geeks <https://www.linuxtechi.com/10-tips-dmesg-command-linux-geeks/>`_

