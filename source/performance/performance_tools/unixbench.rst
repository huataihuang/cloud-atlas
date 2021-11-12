.. _unixbench:

===================
UnixBench性能测试
===================

`UnixBench性能测试工具 <https://github.com/kdlucas/byte-unixbench>`_ 始于BYTE UNIX benchmark suite，多年以来由很多人更新和修改，提供了对Unix系统对基本性能度量，用于对比不同系统对性能。

UnixBench测试也包含了一些非常简单对图形测试，并且能够针对多处理器复制足够的副本进行多处理器性能压测。即首先运行一个单任务测试单个CPU性能，然后按照系统的处理器数量调用相应的多任务并发测试。

安装
=========

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

运行
===========

- 简单运行::

   ./Run

- 如果要测试限制指定cpu数量，例如2个cpu::

   ./Run -c 2

在ARM系统(128核心)上，执行 ``./Run -c 128`` 会出现报错::

   0 CPUs in system; running 128 parallel copies of tests


- 如果只测试部分测试案例，可以以参数传递测试用例::

   ./Run dhry2reg whetstone-double syscall pipe context1 spawn execl shell1 shell8 shell16

- 如果要不断循环测试(例如纯粹为了压测服务器稳定性)::

   nohup sh -c 'while true;do ./Run;done' &

排错
======

在CentOS 6.9上编译后执行会提示错误::

   Can't locate Time/HiRes.pm in @INC (@INC contains: /usr/local/lib64/perl5 /usr/local/share/perl5 /usr/lib64/perl5/vendor_perl /usr/share/perl5/vendor_perl /usr/lib64/perl5 /usr/share/perl5 .) at ./Run line 6.
   BEGIN failed--compilation aborted at ./Run line 6.

参考 `Can’t locate Time/HiRes.pm Perl <https://drewsymo.com/2016/05/09/cant-locate-timehires-pm-perl/>`_ 和 `Perl-Can't locate Time/HiRes.pm 错误 <http://blog.51cto.com/perlin/1192035>`_ 执行::

   yum install perl-Time-HiRes

参考
========

- `Install and Run UnixBench on CentOS or Debian VPS <https://my.vps6.net/knowledgebase/1/Install-and-Run-UnixBench-on-CentOS-or-Debian-VPS.html>`_
- `How to benchmark a linux server using UnixBench <https://www.copahost.com/blog/benchmark-linux-unixbench/>`_
