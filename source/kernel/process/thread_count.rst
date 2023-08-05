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

参考
=====

- `How to get (from terminal) total number of threads (per process and total for all processes) <https://askubuntu.com/questions/88972/how-to-get-from-terminal-total-number-of-threads-per-process-and-total-for-al>`_ 
- `Thread count of a process in Linux <https://www.site24x7.com/learn/linux/linux-threads.html#:~:text=This%20is%20found%20in%20the,threads%20created%20for%20a%20process.>`_ 这篇文章更为详细，待学习
- `Maximum Number of Threads per Process in Linux <https://www.baeldung.com/linux/max-threads-per-process#:~:text=How%20to%20Retrieve%20Maximum%20Thread,%2Fkernel%2Fthreads%2Dmax.&text=Here%2C%20the%20output%2063704%20indicates,a%20maximum%20of%2063%2C704%20threads.>`_ 操作系统对每个进程的线程数量是有限制的
- `Maximum number of threads per process in Linux? <https://stackoverflow.com/questions/344203/maximum-number-of-threads-per-process-in-linux>`_
- `Solved: Check thread count per process in Linux [5 Methods] <https://www.golinuxcloud.com/check-threads-per-process-count-processes/>`_
