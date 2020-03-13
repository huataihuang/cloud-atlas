.. _earlyoom:

=================
earlyoom OOM服务
=================

oom-killer对于Linux用户来说是"臭名昭著"的最坏情况，当Linux内存耗尽被迫调用oom-killer，将会导致系统存在潜在的不稳定。在调用oom-killer之前，Linux会尝试清理内存页缓存会清空所有buffer，但是这种危急情况下系统会进入呆滞状态，响应非常缓慢。

.. note::

   有关oom-killer的讨论:

   - `Why are low memory conditions handled so badly? <https://www.reddit.com/r/linux/comments/56r4xj/why_are_low_memory_conditions_handled_so_badly/>`_
   - `Is it possible to make the OOM killer intervent earlier? <https://superuser.com/questions/406101/is-it-possible-to-make-the-oom-killer-intervent-earlier>`_

earlyoom工作原理
==================

`earlyoom - The Early OOM Daemon <https://github.com/rfjakob/earlyoom>`_ 是帮助我们管理Linux OOM的服务。

当系统内存不足时，earlyoom会检查可用内存并清理swap，最高频度可以达到每秒10次。默认设置当内存和swap同时低于10%时候，earlyoom将杀掉占用内存最大当进程( ``oom_score`` 最大的 )。这个百分比值可以通过命令行参数调整。

安装
=========

- CentOS 8环境需要先 :ref:`init_centos` ，并且 :ref:`install_golang` (make test使用go)

.. note::

   如果要生成man，则还需要安装 pandoc 

- 编译::

   git clone https://github.com/rfjakob/earlyoom.git
   cd earlyoom
   make

- 集成测试::

   make test

- 安装::

   sudo make install

.. note::

   对于Debian 10+ 和 Ubuntu 18.04+ ，则可以通过发行版仓库直接安装，更为简便::

      sudo apt install earlyoom
      sudo systemctl enable earlyoom
      sudo systemctl start earlyoom

- 也可以通过EPEL安装::

   sudo dnf install epel-release
   sudo dnf install earlyoom
   sudo systemctl enable --now earlyoom

使用
=========

如果是通过源代码编译安装，则直接启动就可以::

   ./earlyoom

会提示使用的内存和swap状态。

如果是通过systemd服务安装，则使用::

   systemctl status earlyoom

可以看到当前输出的信息::

   Mar 13 17:27:44 centos8 systemd[1]: Started Early OOM Daemon.
   Mar 13 17:27:44 centos8 earlyoom[73837]: earlyoom 1.3
   Mar 13 17:27:44 centos8 earlyoom[73837]: mem total: 1806 MiB, swap total: 2047 MiB
   Mar 13 17:27:44 centos8 earlyoom[73837]: sending SIGTERM when mem <= 10 % and swap <= 10 %,
   Mar 13 17:27:44 centos8 earlyoom[73837]:         SIGKILL when mem <=  5 % and swap <=  5 %
   Mar 13 17:27:44 centos8 earlyoom[73837]: mem avail:  1237 of  1806 MiB (68 %), swap free: 2039 of 2047 MiB (99 %)
   Mar 13 17:28:44 centos8 earlyoom[73837]: mem avail:  1239 of  1806 MiB (68 %), swap free: 2039 of 2047 MiB (99 %)
   Mar 13 17:29:44 centos8 earlyoom[73837]: mem avail:  1239 of  1806 MiB (68 %), swap free: 2039 of 2047 MiB (99 %)
   Mar 13 17:30:44 centos8 earlyoom[73837]: mem avail:  1238 of  1806 MiB (68 %), swap free: 2039 of 2047 MiB (99 %)

最后10行信息是每分钟的系统当前内存使用情况。

通知
========

命令行参数 ``-n`` 可以通过 ``notify-send`` 发送

待实践...

优先进程
=========

命令行参数 ``--prefer`` 可以设置优先 ``杀掉`` 的进程；相反， ``--avoid`` 则指定避免杀掉的进程。而且，可以使用正则表达式::

   earlyoom --avoid '^(foo|bar)$'

配置文件
===========

对于通过系统服务运行的earlyoom，则可以通过修改 ``/etc/default/earlyoom`` 来配置，例如::

   EARLYOOM_ARGS="-m 5 -r 60 --avoid '(^|/)(init|Xorg|ssh)$' --prefer '(^|/)(java|chromium)$'"

修改配置之后，通过重启服务来修正::

   systemctl restart earlyoom

.. note::

   命令行参数可以通过 ``earlyoom -h`` 查看

参考
======

- `earlyoom - The Early OOM Daemon <https://github.com/rfjakob/earlyoom>`_
