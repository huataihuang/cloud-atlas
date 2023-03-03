.. _illegal_instruction_core_dumped:

==========================================
排查 "Illegal instruction (core dumped)"
==========================================

现象
======

在一台服务器上无法运行程序 ``demo`` ::

   ./demo --server --config ../config/config.xml

提示直接core掉了::

   Illegal instruction (core dumped)

通过 ``dmesg -T`` 检查系统日志可以看到::

   [Fri Mar  3 17:52:34 2023] traps: demo[107300] trap invalid opcode ip:89813b3 sp:7fff24b82d98 error:0
   [Fri Mar  3 17:52:34 2023]  in demo[400000+e49a000]

``Illegal instruction``
==========================

所谓 ``Illegal instruction`` (错误指令)，表示处理器(CPU)收到了一条它不支持的指令:

大多数情况下，是因为程序采用了特定的优化编译，需要依赖一定(新型)的CPU指令集。例如，一些近期的tensorflow构建都是假设你的CPU支持 ``AVX`` 指令，而对于早于2011年的处理器或者低端x86 CPU(Pentium, Celeron, Atom)都不支持AVX指令集。 **很巧，我这个案例就是这样**

当出现 ``Illegal instruction (core dumped)`` 信息是，表示内核发送了一个 ``SIGILL`` ，也就是在  ``kernel/traps.c`` 中捕获 ``X86_TRAP_UD`` 定义的 ``CPU Trap`` 。那么，要如何找到这个程序触发的CPU指令是什么呢？

**Debug** ``Illegal instruction``
===================================

使用 ``gdb`` 工具可以调试程序，找到导致非法指令，以及该指令从哪里来，或者找到程序所依赖的库:

- 需要在能够重现错误的服务器上使用 ``gdb`` 调试才能发现导致 ``Illegal instruction`` 的指令
- 如果没有重现环境，则可能需要采用反汇编来找出特定指令集

**调试步骤**

- 首先用 ``gdb`` 加载程序::

   gdb demo

此时按照以下指令步骤::

   run
   bt   打印backtrace，这个指令需要debug symbols才能定位源码
   display/i $pc  打印指令，也就是导致程序崩溃的最后一条指令

.. note::

   编译程序时采用 ``debug`` 模式，可以添加 ``debugging symbols`` (调试符号表)，这样使用 ``gdb`` 调试就更好了，能够通过汇编调试找到源代码，方便发现bug

调试信息如下:

.. literalinclude:: illegal_instruction_core_dumped/gdb_output
   :language: bash
   :caption: 通过 ``gdb`` 找出 ``Illegal instruction (core dumped)`` 指令
   :emphasize-lines: 18,26,38,40

通过 ``display/i $pc`` 我们可以看到::

   => 0x89813b3 <_ZN10tensorflow13boosted_trees7learner13LearnerConfig21InitAsDefaultInstanceEv+51>:	vinserti128 $0x1,%xmm1,%ymm0,%ymm0

这里就可以看到导致程序奔溃( ``Illegal instruction`` ) 的指令就是 ``vinserti128``

从Intel开发手册，或者直接Google就能够找到 `WikiPedia: Advanced Vector Extensions <https://en.wikipedia.org/wiki/Advanced_Vector_Extensions>`_ : ``vinserti128`` 是 ``AVX2`` 指令集中的一条指令，以及对应的Intel/AMD CPU型号。

之所以遇到这个 ``Illegal instruction`` 是因为运行程序的那台老服务器恰好是只支持 ``AVX`` 的Intel Xeon E5-2650 v2 ；换了一台 Intel Xeon E5-2670 v3 就能够看到 ``AVX2`` 支持了(请检查 ``lscpu`` 输出的 ``Flags`` )

参考
=======

- `Fixing illegal instruction issues <https://wiki.parabola.nu/Fixing_illegal_instruction_issues>`_
- `Program crash messages <https://helpful.knobs-dials.com/index.php/Program_crash_messages>`_
- `What exactly does "Illegal instruction (core dumped)" mean? [duplicate] <https://unix.stackexchange.com/questions/471047/what-exactly-does-illegal-instruction-core-dumped-mean>`_
