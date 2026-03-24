.. _truss_startup:

======================
truss快速起步
======================

``truss`` 即 ``trace system calls`` ，用于跟踪特定进程或程序的系统调用。输出是指定的问津啊或标准错误输出。 ``truss`` 是同通过 ``ptrace`` 的监控进程停止和启动来实现。

.. note::

   ``truss`` 类似于Linux平台的 :ref:`strace` ，是一种记录和显示进程产生的系统调用(System Calls)以及接收到的信号(Signals)

当遇到程序在某个地方卡住了，或者莫名其妙退出， ``truss`` 能够看到进程最后在和内核之间如何交互的。

注意， ``truss`` 基于 ``ptrace`` 或内核钩子，会暂停进程执行。 ``truss`` 跟踪仅限于应用层与内核的边界(系统调用)。其跟踪开销很大，由于频繁的上下文，被跟踪程序会变得很慢。

``truss`` 的优点是使用方便，但是仅限于看到进出内核的系统调用，所以透视能力有限。

通常想要快速查看某个进程为什么 ``open()`` 失败或者为什么 ``exit()`` ，使用 ``truss`` 会比较容易定位。但是如果要排查生产环境的性能瓶颈、死锁或复杂的内核行为，则需奥使用 :ref:`dtrace` 。

参考
=====

- `FreeBSD Manual Pages: truss <https://man.freebsd.org/cgi/man.cgi?truss>`_
