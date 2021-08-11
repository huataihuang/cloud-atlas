.. _debug_high_sys:

==============================
排查Linux系统Sys占用极高问题
==============================

在排查线上系统负载过高时( ``top`` 显示load )，发现CPU实际上还有空闲(idle约40%)，然而Load极高，并且CPU使用率中 ``use`` 仅占 ``40%`` ，剩下的CPU资源约有20%被 ``system`` 吃掉了:

.. figure:: ../../_static/kernel/tracing/top_high_load.png
   :scale: 70

按一下 ``1`` 可以看到每个CPU核心都有极高(20%)的sys消耗:

.. figure:: ../../_static/kernel/tracing/top_high_load_sys.png
   :scale: 70

- 使用 ``sar`` 命令可以概括上述统计信息::

   sar -u 5

显示::

   Linux 4.19.91-007.ali4000.alios7.x86_64 (haiguangxdn011070025023.stl)   08/10/2021      _x86_64_        (128 CPU)

   04:54:06 PM     CPU     %user     %nice   %system   %iowait    %steal     %idle
   04:54:11 PM     all     43.73      0.01     18.10      0.00      0.00     38.16
   04:54:16 PM     all     40.95      0.00     16.54      0.00      0.00     42.50
   04:54:21 PM     all     41.53      0.01     15.76      0.00      0.00     42.70
   04:54:26 PM     all     45.41      0.00     18.05      0.00      0.00     36.53
   04:54:31 PM     all     37.84      0.00     15.65      0.00      0.00     46.51
   04:54:36 PM     all     37.46      0.24     16.84      0.00      0.00     45.46
   04:54:41 PM     all     39.63      0.59     19.08      0.00      0.00     40.70
   04:54:46 PM     all     41.19      0.13     17.72      0.00      0.00     40.96
   04:54:51 PM     all     39.89      0.13     16.74      0.00      0.00     43.24
   04:54:56 PM     all     41.42      0.01     16.46      0.00      0.00     42.10
   ^C

   04:55:10 PM     all     42.26      0.01     18.18      0.00      0.00     39.54
   Average:        all     41.30      0.09     17.40      0.01      0.00     41.20

查询僵尸和D进程
==================

僵尸进程 ``zombie`` 是虽然不占用资源，但是表明系统有不正常的资源回收问题。

根据经验，我们知道Linux中有一种状态为 ``D`` 的进程，会阻塞CPU使用(因为CPU需要等待设备返回，例如等待磁盘)，所以我们检查一下系统是否存在 ``D`` 进程::

   ps r -A

可以看到如下进程::

   PID TTY      STAT   TIME COMMAND
   ...
   932 ?        D     78:08 [load_calc]
   32180 ?      Dl    49:37 /opt/taobao/java/bin/java -classpath /opt/flink/conf:/opt/flink/lib/blink-launcher-blink-3.4.3-SNAPSHOT.jar:/opt/flink/lib/blink-metrics-ceresdb-blink-3.4.3-SNAPSHOT.jar:/opt/flink/lib/blink-pangu-fs-blink-3.4.3-SNAPSHOT.jar:/opt/flink/lib/blink-statebackend-antkv_2.11-blink-3.4.3-SNAPSHOT.jar:/opt/flink/lib/blink-statebackend-gemini-2.1.19-20210307.140847-1.jar:/opt/flink/lib/
   ...
   184543 ?     Dl   444:32 /opt/taobao/java/bin/java -classpath /opt/flink/conf:/opt/flink/lib/blink-launcher-blink-3.4.2-SNAPSHOT.jar:/opt/flink/lib/blink-metrics-ceresdb-blink-3.4.2-SNAPSHOT.jar:/opt/flink/lib/blink-pangu-fs-blink-3.4.2-SNAPSHOT.jar:/opt/flink/lib/blink-statebackend-antkv_2.11-blink-3.4.2-SNAPSHOT.jar:/opt/flink/lib/blink-statebackend-gemini-2.1.19-20210307.140847-1.jar:/opt/flink/lib/
   ...

- 检查 ``D`` 住进程的堆栈:

.. literalinclude:: d_process_stack
   :language: bash
   :linenos:
   :caption:

可以看到上述 ``blink`` 进程在 ``entry_SYSCALL_64_after_hwframe+0x44/0xa9`` 出现异常阻塞

进程信息排查
=============

:ref:`sysrq` 的提供了 ``t`` 指令dump出当前任务的信息，所以我在服务器上执行以下命令，打开进程信息::

   echo t > /proc/sysrq-trigger

- 此时， ``dmesg -T`` 可以看到大量的系统调用被记录下来，其中有非常值得注意的 :ref:`bad_rip_value` 

可以看到 :ref:`bad_rip_value` 同样集中在系统调用 ``entry_SYSCALL_64_after_hwframe+0x44/0xa9`` ，也就是阻塞进程的调用。

.. literalinclude:: dump_tasks_info
   :language: bash
   :linenos:
   :caption:

待续

