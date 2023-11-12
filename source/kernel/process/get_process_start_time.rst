.. _get_process_start_time:

=========================
获取进程启动时间
=========================

``ps`` 检查启动时间
====================

使用 :ref:`ps` 命令可以轻易获得进程启动时间:

- 检查进程启动时间 ``lstart`` :

.. literalinclude:: utils/ps/ps_lstart
   :caption: 检查进程启动时间，例如 ``qemu-system-x86``

输出显示案例类似如下:

.. literalinclude:: utils/ps/ps_lstart_output
   :caption: 检查进程启动时间，例如 ``qemu-system-x86`` 可以看到详细的启动时间

.. note::

   在 ``ps`` 检查进程启动时间的 ``field`` 格式参数可以有3种:

   - ``start`` 启动时间类似 ``09:46:10`` ，但是超过24小时的进程会显示为日期，类似 ``Aug 31``
   - ``stime`` 启动时间类似 ``09:10`` ，但是超过24小时的进程也是显示为日期，类似 ``Aug31``
   - ``lstart`` 启动时间最详尽和标准化，非常方便对比检查，类似 ``Thu Aug 31 23:58:01 2023`` 强烈推荐

从 ``stat`` 获取进程启动时间
==============================

我在生产实践中遇到过一种异常情况，OS异常导致 ``ps`` 命令无法执行。这时候可以考虑从 ``/proc`` 目录下进程对应pid的 ``stat`` 来获取信息:

.. literalinclude:: get_process_start_time/process_stat
   :caption: 从进程的 ``procfs`` 的 ``stat`` 来获得启动时间

.. note::

   从 ``stat`` 文件中读取的数值是从系统启动到进程启动启动之间的 ``clock ticks`` ，上述脚本命令做了转换

参考
======

- `How to get the start time of a long-running Linux process? <https://stackoverflow.com/questions/5731234/how-to-get-the-start-time-of-a-long-running-linux-process>`_
