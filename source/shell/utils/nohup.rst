.. _nohup:

=================
nohup
=================

最近编写一个简单的脚本，不过数据处理量很大，所以需要采用一些并发机制来完成。首先想到的就是 ``nohup`` ，通过 ``nohup`` 来执行脚本命令可以不阻塞执行，充分利用服务器的多处理器并行计算。简单来说，将大量的数据通过 :ref:`split` 拆分成小文件数据，然后将数据处理脚本 ``process_data.sh`` 通过传递参数结合 ``nohup`` ，就能够实现并发::

   nohup ./process_data.sh aa &
   nohup ./process_data.sh ab &
   ...

.. note::

   这个简单的处理思路其实就是 :ref:`big_data` 最基本的 **map reduce** ，实际脚本编写中结合 ``nohup`` 日志以及不断监控日志输出判断每个处理进程的进度，就能够自动化处理大量的数据 **map reduce** ，实现效率提升。

``nohup`` 是一个 POSIX 命令，表示 "no hang up"，也就是不挂起。这个工具命令执行命令时能够忽略 ``HUP`` (hangup) 信号，这样即使用户退出也不会终止程序执行::

   nohup abcd &

此外，对于不同进程可以结合 :ref:`nice` 命令来将进程运行在较低优先级避免影响在线业务::

   nohup nice abcd &

nohup的输出(日志)
====================

对于 ``nohup`` 输入和输出的处理:

- 如果标准输入是终端，则输入重定向到 ``/dev/null``
- 如果标准输出是终端，则如可能就将输出附加到 ``nohup.out`` 文件
- 如果标准错误是终端，则错误重定向到标准输出
- 上述2条规则可以看到，标准输出和标准错误实际上都是在 ``nohup.out`` 文件，如果要区分不同的 ``nohup`` 执行(例如上文编写并发处理数据文件，要监控每个执行命令的进度以便判断何时进行数据合并进入下一个处理流程):

  - 采用 ``nohup COMMAND > FILE`` 可以为每个 ``nohup`` 执行分离输出信息
  - 多个并发 ``nohup`` 脚本可以在脚本中通过 ``echo`` 输出日志信息，这样就能够记录到文件

完整的执行命令可以采用重定向标准输出和标准错误到同一个 ``myprogram.out`` 文件::

   nohup myprogram > myprogram.out 2>&1 &

也可以分离标准输出和标准错误::

   nohup myprogram > myprogram.out 2> myprogram.err &
  
替代nohup的方法: :ref:`screen_dm`
====================================

通过 :ref:`screen_dm` 可以实现和 ``nohup`` 相同的效果::

   screen -A -m -d -S somename ./somescript.sh &

参考
======

- `Linux nohup command <https://www.computerhope.com/unix/unohup.htm>`_
- `Wikipedia: nohup <https://en.wikipedia.org/wiki/Nohup>`_
- `Is there a way to redirect nohup output to a log file other than nohup.out? <https://unix.stackexchange.com/questions/45913/is-there-a-way-to-redirect-nohup-output-to-a-log-file-other-than-nohup-out>`_
