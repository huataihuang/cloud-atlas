.. _bad_rip_value:

=======================
"Bad RIP value"含义
=======================

在 :ref:`debug_high_sys` 时，采用 :ref:`sysrq` 指令 ``t`` dump出进程信息::

   echo t > /proc/sysrq-trigger

其中的报错信息

.. literalinclude:: dump_tasks_info
   :language: bash
   :linenos:
   :caption:
   
从上述当前任务的信息可以看出:

- ``RIP: 0033:0x7f4f6a70b4f3`` 对应地址错误 ( ``Code: Bad RIP value.`` )

RIP概念
=========

``RIP`` 是CPU的64位指令指针寄存器，这个值决定了CPU将要取出来执行的下一个指令的地址。

在x86架构中，最初16位指令指针被称为 ``IP`` (instruction pointer, 指令指针) ；当架构扩展到32位时候，在寄存器名字前面加上了 ``E`` 表示是32位访问宽度( ``EIP`` )；当扩展到64位 ``x86_64`` 时候，则使用 ``R`` 前缀表示是完全的64位访问宽度( ``RIP`` )。

所谓的 ``Bad RIP value`` 表示指令指针寄存器指向了一个没有包含可执行内存的地址。通常这个错误表示在没有正确初始化一个函数的指针就开始尝试使用该指针，也有可能是在堆栈中覆盖了一个函数的返回地址，所以 ``RET`` 机器码指令就会在尝试返回一个错误地址时终止。

参考
=====

- `What's does Bad RIP value mean? <https://unix.stackexchange.com/questions/622673/whats-does-bad-rip-value-mean>`_
