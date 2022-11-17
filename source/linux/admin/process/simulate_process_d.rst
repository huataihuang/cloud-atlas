.. _simulate_process_d:

==================================
模拟一个不可kill的D状态进程
==================================

我们在排查线上故障，有时需要编写脚本或者配置监控 :ref:`find_process_d` ，此时我们可能需要有一个模拟环境来调试程序。那么，怎么在Linux环境下模拟出一个D进程呢?

由于大多数 ``D`` 进程都和存储有关，所以模拟出存储故障就能 **制造** 出 ``D`` 进程:

- 在主机(VM)上挂载NFS，然后 **故意** 将NFS服务端关闭
- 在主机(VM)上读写虚拟磁盘，然后将虚拟磁盘移除

但是上述操作磁盘的方法都比较 **沉重** ，容易引发不好处理的故障


`Simulate an unkillable process in D state <https://unix.stackexchange.com/questions/134888/simulate-an-unkillable-process-in-d-state>`_ 有人提供了一个非常巧妙的方法:

使用 ``vfork`` 系统调用: ``vfork`` 类似 ``fork`` ，但是因为预期 ``exec`` 只会丢弃复制的数据，地址空间不会从父进程复制到子进程。这样当 ``vfork`` 时，父进程 ``uninterruptibly`` 地等待子进程的 ``exec`` 或 ``exit`` ，就能模拟出 ``D`` 状态。

- ``uninterruptible.c`` :

.. literalinclude:: simulate_process_d/uninterruptible.c
   :language: c
   :caption: 模拟D进程的 uninterruptible.c

.. note::

   这里调整源代码 ``sleep(60)`` 可以延长模拟 ``D`` 状态时间

- 编译::

   gcc -o uninterruptible uninterruptible.c

此时执行进程 ``uninterruptible`` 就会 ``D`` 住直到60秒睡眠时间结束自动退出，并且这个 ``D`` 住的进程实际上是可以 ``kill`` 的(另外开一个终端窗口执行如下)，不会导致线上故障::

   $ ps r -A
       PID TTY      STAT   TIME COMMAND
    111138 pts/1    D+     0:00 ./uninterruptible
    111142 pts/5    R+     0:00 ps r -A
   $ kill 111138
   $ ps r -A
       PID TTY      STAT   TIME COMMAND
    111143 pts/5    R+     0:00 ps r -A


可以在通过以下方式将 ``uninterruptible`` 批量放到后台运行， 就能模拟出大规模的 ``D`` 进程::

   for i in {0..10};do (./uninterruptible &);done

模拟出load极高的系统故障::

   $ ps r -A
       PID TTY      STAT   TIME COMMAND
    111261 pts/1    D      0:00 ./uninterruptible
    111263 pts/1    D      0:00 ./uninterruptible
    111265 pts/1    D      0:00 ./uninterruptible
    111267 pts/1    D      0:00 ./uninterruptible
    111269 pts/1    D      0:00 ./uninterruptible
    111271 pts/1    D      0:00 ./uninterruptible
    111273 pts/1    D      0:00 ./uninterruptible
    111275 pts/1    D      0:00 ./uninterruptible
    111277 pts/1    D      0:00 ./uninterruptible
    111279 pts/1    D      0:00 ./uninterruptible
    111281 pts/1    D      0:00 ./uninterruptible
    111285 pts/1    R+     0:00 ps r -A
   $ uptime
    17:46:25 up 17 days,  6:15,  4 users,  load average: 7.02, 2.06, 0.73

参考
=======

- `Simulate an unkillable process in D state <https://unix.stackexchange.com/questions/134888/simulate-an-unkillable-process-in-d-state>`_
