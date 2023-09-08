.. _ps:

=======================
ps进程检查工具
=======================

``ps`` 输出字段
====================

Linux/Unix 通常采用 System V ( ``ps -elf`` ) 或 BSD ( ``ps alx`` ) 风格 ``ps``

.. note::

   :ref:`ubuntu_linux` 使用 ``ps -elf`` 或 ``ps alx`` 都可以工作，但是输出字段有细微差异

   似乎 ``ps -elf`` 更为适合(输出字段中有 ``C`` 表明CPU使用率)

- 检查进程启动时间 ``lstart`` :

.. literalinclude:: ps/ps_lstart
   :caption: 检查进程启动时间，例如 ``qemu-system-x86``

输出显示案例类似如下:

.. literalinclude:: ps/ps_lstart_output
   :caption: 检查进程启动时间，例如 ``qemu-system-x86`` 可以看到详细的启动时间

.. note::

   在 ``ps`` 检查进程启动时间的 ``field`` 格式参数可以有3种:

   - ``start`` 启动时间类似 ``09:46:10`` ，但是超过24小时的进程会显示为日期，类似 ``Aug 31``
   - ``stime`` 启动时间类似 ``09:10`` ，但是超过24小时的进程也是显示为日期，类似 ``Aug31``
   - ``lstart`` 启动时间最详尽和标准化，非常方便对比检查，类似 ``Thu Aug 31 23:58:01 2023`` 强烈推荐

``ps`` 检查线程
=================

``ps`` 命令的 ``-T`` 参数表示输出线程， ``-p`` 可以指定进程，结合上文的输出字段，我们可以构建一个检查某个进程所有线程的CPU使用率以及运行在哪些cpu core上，以便进一步排查进程异常。

举例，进程 ``qemu-system-x86`` 的 ``pid`` 是 ``7354`` ，当前 ``top`` 可以看到使用的CPU百分比大约是 10+% :

.. literalinclude:: ps/top_qemu
   :caption: 检查 ``qemu-system-x86`` 进程的线程负载
   :emphasize-lines: 8

- 现在来解析这个进程的线程:

.. literalinclude:: ps/ps_tid_cpu
   :caption: 检查进程的所有线程使用的cpu资源以及调度的cpu core

输出信息:

.. literalinclude:: ps/ps_tid_cpu_output
   :caption: 检查进程的所有线程使用的cpu资源以及调度的cpu core

这里可以看到4个kvm线程分别消耗了大约 2.5% 的CPU资源

参考
======

- `About the output fields of the ps command in Unix <https://kb.iu.edu/d/afnv>`_ 非常清晰的 ``ps -o`` 参数字段快速查询，建议参考
- `How to get the start time of a long-running Linux process? <https://stackoverflow.com/questions/5731234/how-to-get-the-start-time-of-a-long-running-linux-process>`_
