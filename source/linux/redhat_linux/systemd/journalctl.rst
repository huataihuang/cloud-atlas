.. _journalctl:

=================
journalctl
=================

journalctl是一个从systemd日志服务journald查询和显示日志的工具。由于journald使用二进制格式存储日志取代了传统的文本格式，journalctl是标准的读取journald的日志消息的方法。

快速检查服务日志
==================

- 要检查某个服务相关日志，请使用参数 ``-u`` ( ``--unit`` ) ::

   journalctl -u service-name.service

不过，上述 ``-u`` 参数会显示这个服务相关的所有日志，但是我们往往关注最近一次操作系统启动以后的服务日志，所以我们往往还会加上 ``-b`` 参数 ( ``--boot`` ) ::

   journalctl -u service-name.service -b

- 其他类型的units ( sockets, targets, timers 等等 )，也是需要使用明确的单元类型，例如::

   journalctl -u socket-name.socket -b

- 默认情况情况下 ``journactl`` 展示日志是分页的，所以需要不停滚动来查看。但是有时候我们想一次打印出所有日志，就需要使用 ``--no-pager`` 参数::

   journalctl -u service-name.service -b --no-pager

- 需要持续观察日志，则使用 ``-f`` 参数，类似 ``tail -f`` ::

   journalctl -u service-name.service -f

参考
=====

- `How to see full log from systemctl status service? <https://unix.stackexchange.com/questions/225401/how-to-see-full-log-from-systemctl-status-service/225407>`_
- `Using journalctl <https://www.loggly.com/ultimate-guide/using-journalctl/>`_
- `Ultimate Guide to Logging <https://www.loggly.com/ultimate-guide/using-systemctl/>`_
