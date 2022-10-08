.. _simulate_load_startup:

====================
模拟负载的方法起步
====================

在验证一些系统稳定性的时候，我们可能并不是关注 :ref:`unixbench` 或 :ref:`sysbench` 对系统的性能评估，而是希望通过持续的压力来模拟一些生产环境问题，借此测试稳定性。这时，我们需要一些简单的脚本或者命令来实现。这里汇总一些我使用过、验证过有效且方便的方法。

:ref:`stress`
================

``stress`` 是非常常用的压力工具，安装和使用都非常简便，发行版一般都提供了这个工具 - 请参考 :ref:`stress`

脚本死循环
==============

如果单纯对CPU进行压力，可以不用任何工具，直接执行脚本死循环就可以达到目的::

   for i in {1..4};do while : ; do : ; done & done

上述命令启动了4个 ``while`` 循环，由于是永远true，所以会死循环执行空指令，直接把4个CPU全部耗尽。

此时提示进程pid::

   [1] 41730
   [2] 41731
   [3] 41732
   [4] 41733

如果没有进入后台，可以通过以下命令停止::

   for i in {1..4}; do kill %$i;done

此时提示::

   [1]   Terminated              while :; do
       :;
   done
   [2]   Terminated              while :; do
       :;
   done
   [3]-  Terminated              while :; do
       :;
   done
   [4]+  Terminated              while :; do
       :;
   done

则进程终止

对 ``/dev/null`` 设备操作生成压力
===================================

对于 ``/dev/null`` 设备进行IO会产生巨大CPU压力，以下是一些案例::

   yes > /dev/null &

   dd if=/dev/zero of=/dev/null

   # 对3个CPU核心压测5秒钟
   seq 3 | xargs -P0 -n1 timeout 5 yes > /dev/null

   # 如果仅仅是持续压力直到crtl-c
   seq 3 | xargs -P0 -n1 md5sum /dev/zero

通过openssl计算
==================

``openssl`` 提供了一个 ``speed`` 命令测试算法速度(可以通过这种方式对比不同CPU的加密速度)::

   openssl speed -multi $(nproc --all)

上述 ``nproc`` 命令会打印出系统可用的处理器数量，这样 ``openssl`` 就会对所有cpu进行 ``speed`` 计算，也就是全力压测所有CPU

sha1sum计算
==============

- ``sha1sum`` 命令会对CPU进行压力，可以启动一定数量进程使得对应数量的CPU产生压力::

   sha1sum /dev/zero &

重复上述命令，也就是对任意数量CPU产生压力

结束时候执行::

   killall sha1sum

md5sum计算
=============

- ``md5sum`` 命令也同样对cpu产生压力，以下脚本命令 ``-P4`` 表示启动4个并发，这个数值可调，且脚本命令非常巧妙::

   nproc | xargs seq | xargs -n1 -P4 md5sum /dev/zero

使用随机生成器
==================

- ``urandom`` 设备可以用来作为输入源，当压缩程序对随机数进行压缩并投入到null设备就会对系统产生持续压力::

   cat /dev/urandom | gzip -9 > /dev/null

如果需要对多个CPU进行压力，只需要重复 "套娃" 就可以::

   cat /dev/urandom | gzip -9 | gzip -d | gzip -9 | gzip -d > /dev/null

- 使用 ``sha512sum`` 工具也可以::

   sha512sum /dev/urandom

命令行内存压力
===============

前面使用 ``stress`` 来模拟内存压力，实际上也可以使用操作系统 ``ramfs`` 来实现::

   mkdir z
   mount -t ramfs ramfs z/
   dd if=/dev/zero of=z/file bs=1M count=128

磁盘压力
===========

可以通过循环复制文件来实现磁盘压力::

   dd if=/dev/zero of=loadfile bs=1M count=1024
   while true; do cp loadfile loadfile1; done

如果仅想循环10次，可以改成::

   for i in {1..10}; do cp loadfile loadfile1; done

参考
======

- `How can I produce high CPU load on a Linux server? <https://superuser.com/questions/443406/how-can-i-produce-high-cpu-load-on-a-linux-server>`_
- `How to create a CPU spike with a bash command <https://stackoverflow.com/questions/2925606/how-to-create-a-cpu-spike-with-a-bash-command>`_
- `Simulate System Loads <https://bash-prompt.net/guides/create-system-load/>`_
