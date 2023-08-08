.. _thread_count:

====================
线程数量统计
====================

快速起步
==========

在系统监控时，我们需要关注一个进程的线程数量以及操作系统的线程总量，可以采用如下简便的方法:

- 获取一个指定 ``pid`` 的所有线程数量:

.. literalinclude:: thread_count/ps_pid_thread
   :caption: 获取指定pid的所有线程的数量

注意，这里会直接返回一个进程的所有线程总数(直接返回数字)，原因是这里参数 ``nlwp`` 表示 ``Number of LightWeight Processes`` ，也就是线程数量

举例 我的 :ref:`kvm` 虚拟机 ``z-b-data-1`` 的进程PID是 ``7410`` ，则可以通过以下命令检查::

   ps -o nlwp 7410

输出结果::

   9

表明有9个线程

其实，这个线程数量可以从 ``/proc/<pid>/status`` 中查看::

   cat /proc/7410/status

输出案例:

.. literalinclude:: thread_count/proc_status_output
   :caption: 检查进程对应的状态(线程数量)
   :emphasize-lines: 35

- 获取整个操作系统的线程数量(非常有用的监控命令):

.. literalinclude:: thread_count/linux_os_threads_number
   :caption: 获取Linux操作系统所有线程总数

排查线程数过度问题
=====================

生产环境出现线程过多问题，检查是哪个进程导致线程过多:

- 获取系统消耗线程最多的进程:

.. literalinclude:: thread_count/linux_os_max_threads_process
   :caption: 获取Linux操作系统消耗最多线程的进程

.. literalinclude:: thread_count/linux_os_max_threads_process_output
   :caption: 获取Linux操作系统消耗最多线程的进程

这个命令不太完善，不过可以看到 ``378199`` 进程消耗了过多的线程。实际上在 :ref:`top_nth` 也看到了这个消耗过多的进程:

.. literalinclude:: utils/top/top_nth_output_too_large
   :caption: ``top`` 的 ``nTH`` 字段无法显示超过3位数值
   :emphasize-lines: 8

- (推荐) ``ps`` 命令可以检查指定进程的线程，非常重要的命令:

.. literalinclude:: process_vs_thread/ps_special_thread
   :caption: 检查指定进程的线程 **重要命令**

输出显示类似:

.. literalinclude:: process_vs_thread/ps_special_thread_output
   :caption: 检查指定进程的线程输出案例

可以看到，这里根据第5列 ``线程命令`` 进行统计，就能找出哪个命令大量出现线程泄漏:

.. literalinclude:: process_vs_thread/ps_special_thread_count
   :caption: 统计指定进程的哪个线程出现泄

输出类似:

.. literalinclude:: process_vs_thread/ps_special_thread_count_output
   :caption: 统计指定进程的哪个线程出现泄

debug线程数量问题
---------------------

根据找到的怀疑泄漏线程的命令，例如上文 ``client_handler`` ，我们可以找一下这个问题线程的堆栈是否有异常:

.. literalinclude:: thread_count/threads_stack
   :caption: 检查异常线程的堆栈

可以看到陷入了一个 syscall 


进程允许的最大线程数量
=======================

- 操作系统级别允许每个进程 ``clone()`` 的线程数量可以从 ``procfs`` 获取:

.. literalinclude:: thread_count/kernel_threads-max
   :caption: 通过 ``procfs`` 检查操作系统允许每个进程的最大线程数量

在我的 :ref:`ubuntu_linux` 22.04 上，默认每个进程最多允许大约 ``31w`` 线程

.. literalinclude:: thread_count/kernel_threads-max_output
   :caption: 通过 ``procfs`` 可以看到操作系统允许每个进程最多31w线程

- 此外，可以通过 ``ulimits`` 检查每个用户允许发起的进程数量:

.. literalinclude:: thread_count/ulimits_processes
   :caption: 通过 ``ulimits -a`` 可以检查当前用户允许的最大进程数量

可以看到每个用户允许的进程数量恰好是每个进程允许线程数量的一半，即 ``15.5w`` 进程:

.. literalinclude:: thread_count/ulimits_processes_output
   :caption: 通过 ``ulimits -a`` 查当前用户允许的最大进程数量大约是 15.5w 

.. note::

   根据操作系统允许的每个用户的最大进程数量 ``15.5w`` ，乘以操作系统允许每个进程的最大线程数量 ``31w`` ，实际上每一个用户能够在操作系统发起的线程数量是惊人的 ``4.785`` 万亿个线程，差不多 **接近5万亿线程** 。不过，实际上，海量的线程会导致系统运行缓慢，所以我们需要在进程出现线程大量堆积的时候，及时排查故障解决软件bug。

- 操作系统级别允许的进程数量也可以从 ``procfs`` 中获取:

.. literalinclude:: thread_count/kernel_pid_max
   :caption: 通过 ``procfs`` 检查操作系统允许的进程数量

在我的 :ref:`ubuntu_linux` 22.04 上，默认操作系统允许最大进程数量大约是 ``42w`` 进程:

.. literalinclude:: thread_count/kernel_pid_max_output
   :caption: 通过 ``procfs`` 检查操作系统默认允许的进程总量大约是42w

该参数可以调整:

.. literalinclude:: thread_count/change_kernel_pid_max_output
   :caption: 通过 ``sysctl`` 修改操作系统最大允许进程数量，例如修改成6.5w

参考
=====

- `How to get (from terminal) total number of threads (per process and total for all processes) <https://askubuntu.com/questions/88972/how-to-get-from-terminal-total-number-of-threads-per-process-and-total-for-al>`_ 
- `Thread count of a process in Linux <https://www.site24x7.com/learn/linux/linux-threads.html#:~:text=This%20is%20found%20in%20the,threads%20created%20for%20a%20process.>`_ 这篇文章更为详细，待学习
- `Maximum Number of Threads per Process in Linux <https://www.baeldung.com/linux/max-threads-per-process#:~:text=How%20to%20Retrieve%20Maximum%20Thread,%2Fkernel%2Fthreads%2Dmax.&text=Here%2C%20the%20output%2063704%20indicates,a%20maximum%20of%2063%2C704%20threads.>`_ 操作系统对每个进程的线程数量是有限制的
- `Maximum number of threads per process in Linux? <https://stackoverflow.com/questions/344203/maximum-number-of-threads-per-process-in-linux>`_
- `Solved: Check thread count per process in Linux [5 Methods] <https://www.golinuxcloud.com/check-threads-per-process-count-processes/>`_
