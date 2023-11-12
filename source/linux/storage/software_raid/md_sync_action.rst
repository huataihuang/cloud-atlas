.. _md_sync_action:

================
md_sync_action
================

停止
======

我在 :ref:`raid-check` 遇到了 ``[md10_resync]`` 的系统进程影响服务器的IO，我在排查过程中发现这个系统进程是始终陷入 ``D`` 状态的(正常，在等待整个 ``md`` 设备完成同步，这是一个漫长的过程)。由于 ``D`` 状态进程是无法接收信号的，所以不管怎么使用 ``kill -9`` 都无法停止这个 ``[md10_resync]`` 系统进程。那么就无法停止么？

**显然不是**

- 检查当前状态:

.. literalinclude:: md_sync_action/get_md_sync_action
   :caption: 获取当前MD设备的同步动作

由于当前正在运行 :ref:`raid-check` ，所以看到输出的 ``action`` 是::

   check

- 停止当前 ``check`` :

.. literalinclude:: md_sync_action/stop_md_sync_action
   :caption: 停止MD设备当前动作

此时检查 md 设备状态 ``cat /proc/mdstat`` 输出可以看到停止了 :ref:`raid-check` :

.. literalinclude:: md_sync_action/stop_md_sync_action_mdstat
   :caption: 停止MD设备当前动作之后 ``mdstat``

