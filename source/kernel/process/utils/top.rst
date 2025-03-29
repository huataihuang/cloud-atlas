.. _top:

====================
性能观察工具top
====================

``top`` 命令用于显示Linux进程，提供了一个动态实时观察运行系统的功能。通常，这个命令可以显示系统的综合信息，并且显示出由Linux内核管理的进程和线程。 ``top`` 通过交互命令模式，提供了进程状态和使用资源。

.. note::

   虽然 ``top`` 命令(另一个命令是 :ref:`ps` )是我们使用Linux最常用的工具，浅显明了。但是，实际上这个工具提供了极其强大的多种观察角度，可以帮助我们分析系统。相应，我们需要掌握一些使用技巧。

top解读
===========

- 一个简单的案例::

   top - 22:48:55 up 51 days,  8:47,  1 user,  load average: 10.79, 10.45, 16.44
   Tasks: 5971 total,  20 running, 5948 sleeping,   0 stopped,   3 zombie
   Cpu(s):  8.8%us,  7.4%sy,  0.0%ni, 82.9%id,  0.3%wa,  0.0%hi,  0.6%si,  0.0%st
   Mem:  263819896k total, 100621984k used, 163197912k free,  1986536k buffers
   Swap:        0k total,        0k used,        0k free, 30298168k cached
   
     PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
   20855 root      20   0 1308m 1.1g 6276 S 100.6  0.4 852:57.14 qemu-kvm
    9830 root      20   0 8770m 8.3g 5544 S 58.3  3.3   2471:14 qemu-kvm
    2955 root      20   0 1321m 1.1g 5340 S 42.0  0.4   5627:29 qemu-kvm

解析:

  - 第一行 ``top - 22:48:55 up 51 days,  8:47,  1 user,  load average: 10.79, 10.45, 16.44`` ::

     当前时间( ``22:48:55`` )，系统启动时间（ ``up 51 days, 8:47`` ），当前用户数量（ ``1 user`` ），以及1分钟，5分钟和15分钟的 :ref:`` ``10.79, 10.45, 16.44``

.. _top_nth:

top检查线程数量
==================

``top`` 命令提供了一个 ``nTH`` 字段来显示进程的线程数量:

- 按下 ``f`` 进入 ``field`` 选择页面
- 使用上下键在字段上找到 ``nTH`` (Number of Threads)，然后按下 ``空格键`` 表示选择显示
- 再按一下 ``s`` 键表示以 ``nTH`` 排序
- 再按一下 ``q`` 退出 ``field`` 选择页面

此时 ``top`` 就会完整输出每个进程的线程数量并且方便观察哪个进程的线程过多

举例:

.. literalinclude:: top/top_nth_output
   :caption: 通过 ``nTH`` 字段在 ``top`` 中显示每个进程的线程数量

不过，实践也发现一个问题，如果一个进程的线程数量实在太多，超过了3位数值(999+)就无法完整在 ``nTH`` 显示，例如我在排查线上的一个线程数量过多告警:

.. literalinclude:: top/top_nth_output_too_large
   :caption: ``top`` 的 ``nTH`` 字段无法显示超过3位数值
   :emphasize-lines: 8

那么这个 ``378199`` PID实际有多少线程呢？

可以使用 ``ls`` 检查 ``/proc/<PID>/task`` 数量::

   $ls /proc/378199/task | wc -l
   149642

或者直接查看进程 ``status`` 中的 ``Threads`` 计数::

   $cat /proc/378199/status | grep Threads
   Threads:149705

可以看到这个 ``378199`` 进程的线程数量不断增加，这可能存在线程泄漏

参考
=======

- `What does “batch mode” mean for the top command? <http://unix.stackexchange.com/questions/138484/what-does-batch-mode-mean-for-the-top-command>`_
- `Linux and Unix top command <http://www.computerhope.com/unix/top.htm>`_
- `Change top's sorting back to CPU <http://unix.stackexchange.com/questions/158584/change-tops-sorting-back-to-cpu>`_
- `12 TOP Command Examples in Linux <http://www.tecmint.com/12-top-command-examples-in-linux/>`_
- `Can You Top This? 15 Practical Linux Top Command Examples <http://www.thegeekstuff.com/2010/01/15-practical-unix-linux-top-command-examples>`_
- `top command in Linux with Examples <https://www.geeksforgeeks.org/top-command-in-linux-with-examples/>`_
- `Solved: Check thread count per process in Linux [5 Methods] <https://www.golinuxcloud.com/check-threads-per-process-count-processes/>`_
