.. _suspend_process:

======================
挂起进程(信号和方法)
======================

我在修改 :ref:`rstunnel` 脚本，改写为 `CTunnel <https://github.com/huataihuang/CTunnel>`_ 时，需要调试脚本，模拟 :ref:`ssh_tunneling` 冻结卡死的情况。这需要短暂使得运行中的 ``ssh`` 进程冻结(没有数据传输)，所以考虑使用shell命令来实现进程挂起。

这个进程 ``suspend`` 和 ``resume`` 是通过发给进程的信号来实现的:

- 温和挂起进程(进程可以忽略这个信号，进程可以优雅处理完手头工作后再挂起): ``SIGTSTP``
- 强制挂起进行(进程不能忽略信号，立即挂起): ``SIGSTOP``
- 恢复运行: ``SIGCONT``

简单来说，就是执行类似如下命令:

.. literalinclude:: suspend_process/kill
   :caption: ``kill`` 发送信号给进程

参考
=======

- `Can a process be frozen temporarily in linux? <https://superuser.com/questions/485884/can-a-process-be-frozen-temporarily-in-linux>`_
  - `How to suspend and resume processes <https://unix.stackexchange.com/questions/2107/how-to-suspend-and-resume-processes>`_
