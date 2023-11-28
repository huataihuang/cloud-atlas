.. _edac:

=========================
EDAC 诊断系统硬件故障
=========================

当前Linux内核和故障检测框架已经转向 Error detection and correction (EDAC) 架构，替代了早期使用的MCE(mcelog)。

.. note::

   EDAC和服务器硬件架构相关，只支持x86架构系统。

mcelog
===============

``mcelog`` 记录了在现代x86 Linxu系统上的硬件的 ``主机检查`` （主要是内存，IO和CPU的硬件错误）日志。当硬件报告了主机自检错误，内核会立即执行操作（例如杀死进程等）然后mcelog就会解码这些错误并且进行一些高级的错误响应，例如屏蔽故障的内存、CPU，或者触发事件。另外，mcelog也能够通过记录日志来处理修正后的错误。

mcelog服务记录 `内存 <http://www.mcelog.org/memory.html>`_ 和 `各种途径 <http://www.mcelog.org/error-flow.png>`_ 搜集的其它错误。

``mcelog --client`` 命令可以用来查询一个运行的 ``mcelog`` 服务。这个服务也可以在可配置的阀值到达时 `触发一些动作 <http://www.mcelog.org/triggers.html>`_ 。这对于一些自动化 `预测故障分析 <http://www.mcelog.org/glossary.html#pfa>`_ 算法：包括 `坏页下线 <http://www.mcelog.org/badpageofflining.html>`_ 和自动化的 `缓存错误处理 <http://www.mcelog.org/cache.html>`_ 。

用户也可以 `配置 <http://www.mcelog.org/config.html>`_ 自己定义的 `动作 <http://www.mcelog.org/triggers.html>`_ 。

所有的错误都被记录到 ``/var/log/mcelog`` 或 ``syslog`` 或 ``journal`` 中。

.. note::

   在线上的实践中，往往会采用日志采集方式，统一采集mcelog日志进行分析，并通过平台触发报警或自动服务器下线维修。上述mcelog自带的trigger机制也不失为一种硬件监控维护手段，可以不用以来统一日志平台，不过，各自服务和组件的独立维护方式可能在小规模或者比较单一简单的应用环境下合适。

``mcelog: warning: 16 bytes ignored in each record``
------------------------------------------------------

在早期的RHEL7/CentOS 7上，有时候执行 ``mcelog`` 会出现如下报错:

.. literalinclude:: edac/mcelog_err
   :caption: 执行 ``mcelog`` 提示需要升级的报错信息
   :emphasize-lines: 1

这个问题在 `Bug 1435338 - mcelog: warning: 16 bytes ignored in each record <https://bugzilla.redhat.com/show_bug.cgi?id=1435338>`_ 有解释，问题出在 mcelog 版本 137 上，上游已经解决，需要升级到 153 版本。

rasdaemon
==============

.. note::

   RAS Daemon( ``rasdaemon`` )是使用EDAC内核驱动实现的HERM(Hardware Events Report Method)，用于替代 ``edac-tools`` 。这个服务作为用户空间工具，可以搜集所有由Linux内核从服务器硬件源头(EDAC, MCE, PCI...)采集到的硬件错误。

   强烈推荐在服务器上部署和运行

以往发行版，如RHEL 5/6 和 arch linux早期版本都提供一个 ``mcelog`` 包包含了mcelog工具，但是这个方式已经不再使用，并且Arch Linux内核不再配置 ``CONFIG_X86_MCELOG_LEGACY`` 选项。现在发行版使用的是 `rasdaemon <https://pagure.io/rasdaemon>`_ ，例如, RHEL 7引入了新的硬件事件报告机制(hardware event report mechanism, HERM)。

arch linux
-----------------

- 安装rasdaemon::

   yay -S rasdaemon

RHEL/CentOS
--------------

- 在CentOS 7上安装 ``rasdaemon`` :

.. literalinclude:: edac/centos_install_rasdaemon
   :caption: 在CentOS 7上安装 ``rasdaemon``

使用
---------

rasdaemon可以之际命令启动，此时会在后台运行，并不断通过syslog输出。如果要在前台运行，将日志输出到控制台，则运行:

.. literalinclude:: edac/rasdaemon_run_front
   :caption: 前台运行 ``rasdaemon``

此时输出显示 ``rasdaemon`` 初始化并监听事件，此时就可以等待出现的硬件异常

.. literalinclude:: edac/rasdaemon_run_front_output
   :caption: 前台运行 ``rasdaemon``

如果希望同时将错误记录到数据库(编译时使用了参数 ``--enable-sqlite3``)，则可以增加一个 ``-r`` 参数::

   rasdaemon -f -r

配置rasdaemon
~~~~~~~~~~~~~~~

- 需要启动两个systemd服务: ``ras-mc-ctl.service`` 和 ``rasdaemon.service`` :

.. literalinclude:: edac/centos_enable_rasdaemon
   :caption: 在CentOS 7上激活和启动 ``rasdaemon``

- 检查服务状态:

.. literalinclude:: edac/systemctl_status_rasdaemon
   :caption: 检查 ``rasdaemon`` 状态
   :emphasize-lines: 32

这里有一个错误提示: ``ras-mc-ctl: Error: No dimm labels for XXXX`` ，实际上在各种服务器上初始时都能看到，需要进一步配置

配置 DIMM labels
------------------


使用rasdaemon
~~~~~~~~~~~~~~~~

``ras-mc-ctl`` 是RAS内存控制器管理工具，用于执行一些针对EDAC(Error Detection and Correction)驱动的RAS管理任务。



参考
======

- `mcelog官方网站 <http://www.mcelog.org>`_
- `Linux x86_64: Detecting Hardware Errors <http://www.cyberciti.biz/tips/linux-server-predicting-hardware-failure.html>`_
- `mcelog: memory error handling in user space <http://www.halobates.de/lk10-mcelog.pdf>`_
- `Machine-check exception <https://wiki.archlinux.org/index.php/Machine-check_exception>`_
- `GitHub: RAS Daemon <https://github.com/mchehab/rasdaemon>`_
- `Monitoring ECC memory on Linux with rasdaemon <https://www.setphaserstostun.org/posts/monitoring-ecc-memory-on-linux-with-rasdaemon/>`_
