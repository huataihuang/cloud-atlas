.. _systemctl:

=================
systemctl
=================

此外，我们使用 ``systemctl status service-name`` 常常会看到过长的日志被截断，所以我们需要一个 ``-l`` 参数来防止truncate::

   systemctl -l status service-name

列出units
==================

- 要检查有哪些服务已经安装，可以执行::

   systemctl list-unit-files --type service

输出类似::

   UNIT FILE                                  STATE           VENDOR PRESET
   alsa-restore.service                       static          -
   alsa-state.service                         static          -
   alsa-utils.service                         masked          enabled
   apache-htcacheclean.service                disabled        disabled
   ...

- 可以进一步列出状态是 ``running`` 的服务::

   systemctl list-units --type=service --state=running

- 由于服务之间有依赖，我们可以显示出这个关系::

   systemctl list-dependencies <service_unit_file>

例如::

   systemctl list-dependencies mysqld

显示输出类似::

   mysqld.service
   ● ├─system.slice
   ● └─sysinit.target
   ●   ├─dev-hugepages.mount
   ●   ├─dev-mqueue.mount
   ...

检查失败的单元
==================

- 有些服务从一开始操作系统启动就是失败的，我们通过以下命令检查::

   systemctl --failed

输出可能类似::

   UNIT               LOAD   ACTIVE SUB    DESCRIPTION
   ● lightdm.service    loaded failed failed Light Display Manager
   ● networking.service loaded failed failed Raise network interfaces
   
   LOAD   = Reflects whether the unit definition was properly loaded.
   ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
   SUB    = The low-level unit activation state, values depend on unit type.
   2 loaded units listed.

以上案例中2个没有正常启动的服务，我们可以排查

激活单元
===========

为了在操作系统启动时运行服务，我们要激活 ``enable`` 服务。

- 检查服务是否激活::

   systemctl is-enabled <service_unit_file>.service

举例::

   systemctl is-enabled rsyslog.service

输出可能是 ``enabled``

systemd-analyze
===================

- ``systemd-analyze`` 提供了启动过程的时间统计信息::

   systemd-analyze

输出显示类似::

   Startup finished in 1.801s (kernel) + 15.286s (userspace) = 17.088s
   graphical.target reached after 15.212s in userspace

- 可以检查启动过程每个服务单元花费时间::

   systemd-analyze blame

输出类似::

   5.954s NetworkManager-wait-online.service
   4.822s networking.service
   4.071s docker.service
   2.789s hciuart.service
   ...

参考
=======

- `Using systemctl <https://www.loggly.com/ultimate-guide/using-systemctl/>`_