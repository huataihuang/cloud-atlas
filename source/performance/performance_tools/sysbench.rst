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

安装(旧方法归档)
=================

- 在Ubuntu上可以直接安装::

   sudo apt install sysbench

- 在CentOS或者Fedora，需要使用EPEL仓库安装:

.. literalinclude:: ../../linux/redhat_linux/admin/dnf/yum_install_epel
   :language: bash
   :caption: yum命令安装EPEL仓库

然后执行::

   sudo yum install sysbench

安装
==========

sysbench现在提供了二进制安装仓库方法，通过 packagecloud ，可以直接针对不同操作系统进行安装

- Debian/Ubuntu:

.. literalinclude:: sysbench/ubuntu_install_sysbench
   :caption: 在Debian/Ubuntu中安装sysbench

- RHEL/CentOS:

.. literalinclude:: sysbench/centos_install_sysbench
   :caption: 在RHEL/CentOS中安装sysbench

- Fedora:

.. literalinclude:: sysbench/fedora_install_sysbench
   :caption: 在Fedora中安装sysbench

- Arch Linux:

.. literalinclude:: sysbench/arch_install_sysbench
   :caption: 在Arch Linux中安装sysbench

- macOS:

.. literalinclude:: sysbench/macos_install_sysbench
   :caption: 在macOS中安装sysbench

- 对于没有在官方列表中列出的操作系统，但是实际上是兼容的，例如aliOS就是兼容CentOS，可以采用先检查 `packagecloud os distro version <https://packagecloud.io/docs#os_distro_version>`_ 然后通过环境变量指定系统:

.. literalinclude:: sysbench/alios_install_sysbench
   :caption: 在aliOS (兼容CentOS 7.2) 中安装

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

测试 ``cpu``
--------------

在 CPU 工作负载下运行时，sysbench 将通过将数字标准除以 2 和数字平方根之间的所有数字来验证素数。 如果任何数字的余数为 0，则计算下一个数字。 可以想象，这会给 CPU 带来一些压力，但仅限于一组非常有限的 CPU 功能。

测试命令::

   sysbench cpu --cpu-max-prime=20000 --threads=48 run

输出结果:

.. literalinclude:: ../../linux/server/hardware/hpe/dl360_bios_upgrade/before/sysbench_cpu
   :language: bash
   :emphasize-lines: 18-19
   :caption: sysbench cpu 

.. note::

   sysbench执行CPU测试是纯计算，也就是全部是 ``user space`` 运行，没有任何 ``system calls`` ，所以和真实的生产环境压力有很大不同。真实环境的CPU计算会涉及大量的 ``system calls`` 所以CPU资源很大部分被 ``sys`` 吃掉了。

测试线程工作负载
-----------------

对于线程工作负载，每个工作线程都将被分配一个互斥锁（一种锁），并且对于每次执行，将循环多次（记录为产量），其中获取锁，产量（意味着它 要求调度程序停止运行并将其放回运行队列的末尾），然后，当它再次被调度执行时，解锁。

通过调整各种参数，可以模拟具有相同锁的高并发线程，或具有多个不同锁的高并发线程等情况。

::

   sysbench threads --thread-locks=1 --time=20 run

输出结果:

.. literalinclude:: ../../linux/server/hardware/hpe/dl360_bios_upgrade/before/sysbench_threads
   :language: bash
   :emphasize-lines: 14-15
   :caption: sysbench threads

测试mutex工作负载
-------------------

使用互斥量工作负载时，sysbench 应用程序将为每个线程运行一个请求。 这个请求首先会给 CPU 带来一些压力（使用一个简单的增量循环，通过 ``--mutex-loops`` 参数），然后它需要一个随机互斥锁（锁），增加一个全局变量并再次释放锁。 这个过程会重复几次，由锁的数量（ ``--mutex-locks`` ）标识。 随机互斥锁取自 ``--mutex-num`` 参数确定大小的池。

::

   sysbench mutex --threads=1024 run

输出结果:

.. literalinclude:: ../../linux/server/hardware/hpe/dl360_bios_upgrade/before/sysbench_mutex
   :language: bash
   :emphasize-lines: 14
   :caption: sysbench mutex

这里输出结果中，运行时间长度最为关键，尽管必须考虑到线程将从可用池中随机获取一个互斥锁。 这个随机因素可能会影响结果。

测试内存工作负载
------------------

在 sysbench 中使用内存测试时，基准应用程序会分配一个内存缓冲区，然后从中读取或写入，每次为一个指针的大小（即 32 位或 64 位），每次执行直到读取了总缓冲区大小 从或写到。 然后重复此操作，直到达到提供的容量 ( ``--memory-total-size`` )。 用户可以提供多线程（ ``--threads`` ）、不同大小的缓冲区（ ``--memory-block-size`` ）和请求类型（读或写，顺序或随机）。

::

   sysbench memory --threads=1024 run

输出结果:

.. literalinclude:: ../../linux/server/hardware/hpe/dl360_bios_upgrade/before/sysbench_memory
   :language: bash
   :emphasize-lines: 18,20
   :caption: sysbench memory

MySQL数据库测试(待实践)
-------------------------

- 创建一个test表包含 1,000,000 行数据::

   sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword prepare

- 性能测试::

   sysbench --test=oltp --oltp-table-size=1000000 --db-driver=mysql --mysql-db=test --mysql-user=root --mysql-password=yourrootsqlpassword --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=8 run


参考
======

- `How to Use Sysbench for Linux Performance Testing? <https://linuxhint.com/use-sysbench-for-linux-performance-testing/>`_
- `gentoo linux: Sysbench <https://wiki.gentoo.org/wiki/Sysbench>`_
- `How to Benchmark Your System (CPU, File IO, MySQL) with Sysbench <https://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench>`_
- `sysbench(github) <https://github.com/akopytov/sysbench>`_
- `sysbench测试案例 <https://wiki.mikejung.biz/Sysbench>`_
