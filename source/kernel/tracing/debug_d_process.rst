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

可以看到:

- ``[load_calc]`` 系统进程在 ``ret_from_fork+0x1f/0x30`` 出现异常阻塞
- ``blink`` 进程在 ``entry_SYSCALL_64_after_hwframe+0x44/0xa9`` 出现异常阻塞

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

再次出现 ``[load_calc]`` 系统进程D
====================================

我在 :ref:`amd_cpu_c-state` ，调整了内核参数( ``processor.max_cstate=1 intel_idle.max_cstate=0`` )关闭海光CPU的电源管理，禁止进入idle状态( :ref:`cpu_c-state` )。但是，服务器重启，再次出现 ``[load_calc]`` 进程D。检查进程堆栈，也和上文相同。

- 我尝试上文方法 :ref:`sysrq` 的提供了 ``t`` 指令dump出当前任务的信息::

   echo t > /proc/sysrq-trigger

结果发现这次命令卡住没有返回，同时系统一下子出现了更多的D进程::

   $ps r -A | grep D
      PID TTY      STAT   TIME COMMAND
     1016 ?        D      0:06 [load_calc]
    13693 ?        D      0:00 runc init
    13806 ?        D      0:00 runc init
    13895 ?        D      0:00 runc init
    14020 ?        D      0:00 runc init
    14073 ?        D      0:00 runc init
    14095 ?        D      0:00 runc init
    16303 ?        Dl     0:00 runsc --version
    18678 ?        Dl     0:00 runsc --version
   458475 ?        D      0:01 [kworker/u256:0+] 

重复出现如下调用 :

.. literalinclude:: debug_d_process/dump_tasks_syscall
   :language: bash
   :caption: 重复出现大量 entry_SYSCALL_64_after_hwframe D住

.. literalinclude:: debug_d_process/dump_tasks_syscall_exit_usermode
   :language: bash
   :caption: 退出用户态也卡住

- 系统大量的内核进程开始运行，异常缓慢::

   #ps r -A
      PID TTY      STAT   TIME COMMAND
       26 ?        R      0:00 [migration/3]
       27 ?        R      0:11 [ksoftirqd/3]
       77 ?        R      0:00 [migration/13]
       78 ?        R      0:00 [ksoftirqd/13]
      226 ?        R      1:18 [migration/42]
      313 ?        R      0:00 [migration/59]
      314 ?        R      0:00 [ksoftirqd/59]
      498 ?        R      0:00 [migration/96]
      499 ?        R      0:00 [ksoftirqd/96]
      518 ?        R      0:00 [migration/100]
      519 ?        R      0:00 [ksoftirqd/100]
      578 ?        R      0:00 [migration/112]
      579 ?        R      0:00 [ksoftirqd/112]
      653 ?        R      0:00 [migration/127]
      654 ?        R      0:00 [ksoftirqd/127]
      742 ?        R      0:01 [kworker/42:1-mm]
     1016 ?        D      0:06 [load_calc]

- 采用 :ref:`kernel_crash_dump` 强制core dump，重启服务器

重启后 ``[load_calc]`` 系统进程依然 ``D`` 但是看不出其他异常，系统运行应用完全正常。这个问题后续再想办法排查...

参考
=======

- `How To Diagnose High Sys CPU On Linux <https://newspaint.wordpress.com/2013/07/24/how-to-diagnose-high-sys-cpu-on-linux/>`_
- `Debugging High CPU Usage Using Perf Tool and vmcore Analysis <https://www.pythian.com/blog/debugging-high-cpu-usage-using-perf-tool-and-vmcore-analysis/>`_
