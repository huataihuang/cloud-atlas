.. _parallel_make_oom:

=======================
并行make触发OOM排查
=======================

我在使用 :ref:`parallel_make` 时候遇到一个困难，大量并行的 ``cc1plus`` 触发系统OOM导致大型编译 :ref:`upgrade_gcc_on_centos7` 无法完成:

.. literalinclude:: parallel_make_oom/dmesg
   :caption: 并行make触发OOM的系统日志
   :emphasize-lines: 36,37

可以看到内存限制大约10G，当达到内存限制时， ``cc1plus`` 被系统OOM杀掉

那么，这个ssh的子进程的内存限制是在哪里继承和配置的呢？

这里可以看到 ``Task in /system.slice/sshd.service killed as a result of limit of /system.slice/sshd.service`` ，这表明 :ref:`linux_oom` 受到 :ref:`cgroup` 限制

简单来说 ``system.slice/sshd.service`` 位于 ``/sys/fs/cgroup/memory/system.slice/sshd.service`` 可以找到 ``memory.limit_in_bytes`` ::

   cat /sys/fs/cgroup/memory/system.slice/sshd.service/memory.limit_in_bytes

当前值是::

   10737418240

折算G恰好就是 ``10GB`` ( ``10737418240/1024/1024/1024`` )

临时修订::

   echo 1073741824000 > memory.limit_in_bytes

然后重新执行 :ref:`parallel_make` 

.. note::

   详细我准备系统学习 :ref:`systemd_manage_resources` 来完善这方面知识

参考
======

- `How does systemd put sshd processes in slices? <https://serverfault.com/questions/968717/how-does-systemd-put-sshd-processes-in-slices>`_
- `The sshd service easily reaches the TasksMax limit after disabling "UsePAM" in sshd_config <https://www.suse.com/support/kb/doc/?id=000020981>`_
- `systemd, per-user cpu and/or memory limits <https://serverfault.com/questions/874274/systemd-per-user-cpu-and-or-memory-limits>`_
