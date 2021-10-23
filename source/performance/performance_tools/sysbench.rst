.. _sysbench:

=================
Sysbench性能测试
=================

`sysbench(github) <https://github.com/akopytov/sysbench>`_ 是基于LuaJIT的一个脚本化多线程性能测试工具。通常用于测试数据库性能，但是也可以创建抽象的负载用于测试多种场景:

- ``oltp_*.lua`` 一系列OLTP类的数据库压测
- ``fileio`` 文件系统层对压测
- ``cpu`` 简单的CPU压测
- ``memory`` 内存访问压测
- ``threads`` 基于线程的调度器压测
- ``mutex`` 一个POSIX mutex压测

.. note::

   我在 :ref:`dl360_bios_upgrade` 前后采用sysbench进行性能测试，以观察BIOS升级对性能的影戏

安装
========

- 在Ubuntu上可以直接安装::

   sudo apt install sysbench

- 在CentOS或者Fedora，需要使用EPEL仓库安装

使用
=======

测试 ``fileio``
------------------

当使用 ``fileio`` ，需要创建一个测试文件，建议文件大小大于可用内存，这样缓存不会过多影响测试负载::

   sysbench fileio --file-total-size=8G prepare
   sysbench fileio --file-total-size=8G --file-test-mode=rndrw --time=300 --max-requests=0 run
   sysbench fileio --file-total-size=8G cleanup

这里可以指定不同的读写模式，例如上面采用了 ``rndrw`` 表示随机读写， ``--max-time`` 指定测试时间

输出结果如下

.. literalinclude:: ../../linux/server/hardware/hpe/dl360_bios_upgrade/before/sysbench_fileio
   :language: bash
   :emphasize-lines: 22-24,27-28
   :caption: sysbench fileio

参考
======

- `How to Use Sysbench for Linux Performance Testing? <https://linuxhint.com/use-sysbench-for-linux-performance-testing/>`_
- `gentoo linux: Sysbench <https://wiki.gentoo.org/wiki/Sysbench>`_
- `How to Benchmark Your System (CPU, File IO, MySQL) with Sysbench <https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench>`_
- `sysbench(github) <https://github.com/akopytov/sysbench>`_
- `sysbench测试案例 <https://wiki.mikejung.biz/Sysbench>`_
