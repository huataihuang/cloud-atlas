.. _edac:

=========================
EDAC 诊断系统硬件故障
=========================

当前Linux内核和故障检测框架已经转向 Error detection and correction (EDAC) 架构，替代了早期使用的MCE(mcelog)。

mcelog
===============

``mcelog`` 记录了在现代x86 Linxu系统上的硬件的 ``主机检查`` （主要是内存，IO和CPU的硬件错误）日志。当硬件报告了主机自检错误，内核会立即执行操作（例如杀死进程等）然后mcelog就会解码这些错误并且进行一些高级的错误响应，例如屏蔽故障的内存、CPU，或者触发事件。另外，mcelog也能够通过记录日志来处理修正后的错误。

mcelog服务记录 `内存 <http://www.mcelog.org/memory.html>`_ 和 `各种途径 <http://www.mcelog.org/error-flow.png>`_ 搜集的其它错误。

``mcelog --client`` 命令可以用来查询一个运行的 ``mcelog`` 服务。这个服务也可以在可配置的阀值到达时 `触发一些动作 <http://www.mcelog.org/triggers.html>`_ 。这对于一些自动化 `预测故障分析 <http://www.mcelog.org/glossary.html#pfa>`_ 算法：包括 `坏页下线 <http://www.mcelog.org/badpageofflining.html>`_ 和自动化的 `缓存错误处理 <http://www.mcelog.org/cache.html>`_ 。

用户也可以 `配置 <http://www.mcelog.org/config.html>`_ 自己定义的 `动作 <http://www.mcelog.org/triggers.html>`_ 。

所有的错误都被记录到 ``/var/log/mcelog`` 或 ``syslog`` 或 ``journal`` 中。

.. note::

   在线上的实践中，往往会采用日志采集方式，统一采集mcelog日志进行分析，并通过平台触发报警或自动服务器下线维修。上述mcelog自带的trigger机制也不失为一种硬件监控维护手段，可以不用以来统一日志平台，不过，各自服务和组件的独立维护方式可能在小规模或者比较单一简单的应用环境下合适。

rasdaemon
==============

以往发行版，如RHEL 5/6 和 arch linux早期版本都提供一个 ``mcelog`` 包包含了mcelog工具，但是这个方式已经不再使用，并且Arch Linux内核不再配置 ``CONFIG_X86_MCELOG_LEGACY`` 选项。现在发行版使用的是 `rasdaemon <https://pagure.io/rasdaemon>`_ ，例如, RHEL 7引入了新的硬件事件报告机制(hardware event report mechanism, HERM)。

- 安装rasdaemon::

   yay -S rasdaemon

rasdaemon可以之际命令启动，此时会在后台运行，并不断通过syslog输出。如果要在前台运行，将日志输出到控制台，则运行::

   rasdaemon -f

如果希望同时将错误记录到数据库(编译时使用了参数 ``--enable-sqlite3``)，则可以增加一个 ``-r`` 参数::

   rasdaemon -f -r

配置rasdaemon
~~~~~~~~~~~~~~~

- 需要启动两个systemd服务: ``ras-mc-ctl.service`` 和 ``rasdaemon.service`` ::

   sudo systemctl enable ras-mc-ctl.service
   sudo systemctl enable rasdaemon.service
   sudo systemctl start ras-mc-ctl.service
   sudo systemctl start rasdaemon.service

使用rasdaemon
~~~~~~~~~~~~~~~~

``ras-mc-ctl`` 是RAS内存控制器管理工具，用于执行一些针对EDAC(Error Detection and Correction)驱动的RAS管理任务。



参考
======

- `mcelog官方网站 <http://www.mcelog.org>`_
- `Linux x86_64: Detecting Hardware Errors <http://www.cyberciti.biz/tips/linux-server-predicting-hardware-failure.html>`_
- `mcelog: memory error handling in user space <http://www.halobates.de/lk10-mcelog.pdf>`_
- `Machine-check exception <https://wiki.archlinux.org/index.php/Machine-check_exception>`_
