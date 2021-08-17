.. _debug_d_process:

==============================
排查Linux D住进程原因
==============================

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

参考
=======

- `How To Diagnose High Sys CPU On Linux <https://newspaint.wordpress.com/2013/07/24/how-to-diagnose-high-sys-cpu-on-linux/>`_
- `Debugging High CPU Usage Using Perf Tool and vmcore Analysis <https://www.pythian.com/blog/debugging-high-cpu-usage-using-perf-tool-and-vmcore-analysis/>`_

