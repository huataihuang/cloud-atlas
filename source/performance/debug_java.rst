.. _debug_java:

=======================
排查Java程序
=======================

.. note::

   虽然我不懂Java开发，但是运维工作中还是会遇到一些Java程序运行异常问题需要排查，例如CPU过高，负载过高等。对于Java程序简单排查可以方便我们定位问题。

Java程序和线程
=================

Java程序有时候会出现挂起和运行缓慢的问题，通过线程dump可以提供一个当前运行的java集成的状态快照，方便进行分析诊断。这种方式简单有效，经常能够发现一些线索以及简单的错误。

Java使用线程来执行每个内部和外部操作。Java的垃圾搜集进程有自己的线程，Java应用程序内部的任务也会创建自己的线程。

在Java程序的生命周期中，线程会经历多种状态。每个线程都有一个跟踪当前操作的执行堆栈。此外，JVM还存储了之前调用成功的所有方法。因此，分析完整的堆栈可以帮助我们研究出现问题时应用程序发生了什么。

获取Java程序线程dump
=====================

一旦Java程序开始运行，有多种方式来生成Java线程dump用于分析诊断:

  - JVM Process Status(jps)
  - jstack

- 首先使用 ``top`` 命令检查系统中运行的Java程序，找出进程 ``PID`` ; 也可以使用 ``jps`` 命令找出Java进程PID:

.. literalinclude:: debug_java/jps
   :language: bash
   :caption: 使用 ``jps`` 命令输出运行的java进程PID

输出类似:

.. literalinclude:: debug_java/jps_output
   :language: bash
   :caption: 使用 ``jps`` 命令输出运行的java进程PID

- 记录下Java进程的所有LWP线程:

.. literalinclude:: debug_java/ps_lwp
   :language: bash
   :caption: 使用 ``ps`` 命令输出运行的java进程线程

执行 ``cat OS_LWP | sort -k3`` 可以看到按线程CPU繁忙程度排序的结果:

.. literalinclude:: debug_java/ps_lwp_output
   :language: bash
   :caption: 按CPU繁忙程度排序java线程

.. note::

   在 ``jstack`` 中记录的线程 ``nid`` 是十六进制，所以这里 ``OS_LWP`` 的PID需要从十进制转换成十六进制来对应

- 执行 ``jstack`` 命令获取Java线程堆栈:

.. literalinclude:: debug_java/jstack_pid
   :language: bash
   :caption: jstack命令输出java进程PID的堆栈

获得 ``jstack.txt`` 进行下一步分析

分析java线程dump
==================

- 在 ``jstack.txt`` 的前面部分可能有类似如下内容，显示了JVM版本以及 Safe Memory Reclamation (SMR) 和 non-JVM internal threads::

   2021-01-04 12:59:29
   Full thread dump OpenJDK 64-Bit Server VM (15.0.1+9-18 mixed mode, sharing):

   Threads class SMR info:
   _java_thread_list=0x00007fd7a7a12cd0, length=13, elements={
   0x00007fd7aa808200, 0x00007fd7a7012c00, 0x00007fd7aa809800, 0x00007fd7a6009200,
   0x00007fd7ac008200, 0x00007fd7a6830c00, 0x00007fd7ab00a400, 0x00007fd7aa847800,
   0x00007fd7a6896200, 0x00007fd7a60c6800, 0x00007fd7a8858c00, 0x00007fd7ad054c00,
   0x00007fd7a7018800
   
   }

- 然后是完整的线程列表dump，包含了以下信息:

.. csv-table:: Java线程dump ( ``jstack`` )输出内容字段说明
   :file: debug_java/jstack_info.csv
   :widths: 20, 80
   :header-rows: 1

分析关注点
------------

- 在 ``jstack.txt`` 最后显示 Java 本机接口(JNI)引用。当发生内存泄漏时，需要特别关注，因为它们不会被自动垃圾回收::

   JNI global refs: 15, weak refs: 0

- 重点关注 ``RUNNABLE`` 和 ``BLOCKED`` 线程，以及 ``TIMED_WAITING`` 线程:

  - 这些状态会提示我们两个或多个线程之间发生冲突的方向
  - **在死锁情况下，多个线程运行在共享对象上持有一个同步块** ( ``In a deadlock situation in which several threads running hold a synchronized block on a shared object`` )
  - **在线程争用时，一个线程会阻塞等待其他线程完成** ( ``In thread contention, when a thread is blocked waiting for others to finish`` )

- 对于异常高的CPU使用率，通常我们只需要查看 ``RUNNABLE`` 线程

参考
=======

- `How to Troubleshoot Java High CPU Usage Issues in Linux? <https://middlewareworld.org/2020/09/12/how-to-troubleshoot-java-cpu-usage-issues-in-linux/>`_
- `How to Analyze Java Thread Dumps <https://www.baeldung.com/java-analyze-thread-dumps>`_
