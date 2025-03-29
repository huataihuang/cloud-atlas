.. _unixbench:

===================
UnixBench性能测试
===================

`UnixBench性能测试工具 <https://github.com/kdlucas/byte-unixbench>`_ 始于BYTE UNIX benchmark suite，多年以来由很多人更新和修改，提供了对Unix系统对基本性能度量，用于对比不同系统对性能。测试结果会和一个基线系统进行对比生成一个index值，也就是有一个打分。一系列index值最后被综合起来形成整个系统的观测值(overall index)。

UnixBench测试也包含了一些非常简单对图形测试(2D和3D)，并且能够针对多处理器复制足够的副本进行多处理器性能压测。即首先运行一个单任务测试单个CPU性能，然后按照系统的处理器数量调用相应的多任务并发测试:

- 运行一个单一任务测试系统性能
- 运行多个任务测试系统性能
- 从并行性能获得系统实现性能

.. note::

   UnixBench测试不仅关系到系统硬件，也和操作系统，库甚至编译器相关，所以测试对比不同硬件到性能应该确保操作系统、库和编译器一致，而测试操作系统( :ref:`kernel` )性能，则应该保持其他变量(硬件、库和编译器等)一致。

编译安装(release旧版编译)
==========================

- 编译环境准备

CentOS::

   yum install gcc gcc-c++ make libXext-devel

对于Debian/Ubuntu，则使用如下命令安装依赖编译库软件包::

   sudo apt install libx11-dev libgl1-mesa-dev libxext-dev perl perl-modules make git

- 下载源代码::

   wget https://github.com/kdlucas/byte-unixbench/archive/v5.1.3.tar.gz
   tar xf v5.1.3.tar.gz

- 编译::

   cd byte-unixbench-5.1.3/UnixBench
   make

编译安装(git版本安装)
======================

.. note::

   在 :ref:`ubuntu_linux` 22.04 这样的主流新版本中编译 UnixBench 非常流畅，不过对于 :ref:`centos` 7 这样古老的系统，我实践发现操作系统自带的 gcc 4.85 无法正常编译，所以需要先完成 :ref:`upgrade_gcc_on_centos7`

- 首先确保gcc使用较新版本，在 :ref:`centos` 7 我执行: :ref:`upgrade_gcc_on_centos7` ，升级到 gcc 10.5 版本才能正确编译UnixBench git版本

- 下载编译UnixBench:

.. literalinclude:: unixbench/compile_unixbench_git_version
   :caption: 编译UnixBench的git版本


运行
===========

- 简单运行::

   ./Run

- 如果要测试限制指定cpu数量，例如2个cpu::

   ./Run -c 2

在ARM系统(128核心)上，执行 ``./Run -c 128`` 会出现报错::

   0 CPUs in system; running 128 parallel copies of tests

此外，我发现现在运行中如果使用 ``-c XX`` 则直接结束，目前只有不使用参数可以运行。

- 如果只测试部分测试案例，可以以参数传递测试用例::

   ./Run dhry2reg whetstone-double syscall pipe context1 spawn execl shell1 shell8 shell16

- 如果要不断循环测试(例如纯粹为了压测服务器稳定性)::

   nohup sh -c 'while true;do ./Run;done' &

排错
======

CentOS 6编译错误
-------------------

在CentOS 6.9上编译后执行会提示错误::

   Can't locate Time/HiRes.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at ./Run line 6.
   BEGIN failed--compilation aborted at ./Run line 6.

参考 `Can’t locate Time/HiRes.pm Perl <https://drewsymo.com/2016/05/09/cant-locate-timehires-pm-perl/>`_ 和 `Perl-Can't locate Time/HiRes.pm 错误 <http://blog.51cto.com/perlin/1192035>`_ 执行::

   yum install perl-Time-HiRes

缺少 3dinfo
-------------

在CentOS 7.2上运行报错::

   sh: 3dinfo: command not found

参考 `byte-unixbench - issue #7 <https://code.google.com/archive/p/byte-unixbench/issues/7>`_ 注释掉 ``3dinfo`` 行

运行结果
===========

- 海光 

.. literalinclude:: unixbench/unixbench_haiguang
   :caption: 在一台海光服务器上的运行结果

- Intel

参考
========

- `Install and Run UnixBench on CentOS or Debian VPS <https://my.vps6.net/knowledgebase/1/Install-and-Run-UnixBench-on-CentOS-or-Debian-VPS.html>`_
- `How to benchmark a linux server using UnixBench <https://www.copahost.com/blog/benchmark-linux-unixbench/>`_
