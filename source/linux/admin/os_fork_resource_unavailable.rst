.. _os_fork_resource_unavailable:

===========================================================
执行报错"fork failed: Resource temporarily unavailable"
===========================================================

在使用 :ref:`pssh` 时，会 :ref:`ssh` 并发访问大量服务器，如果同时使用了 :ref:`speed_up_ssh` 的 :ref:`ssh_multiplexing` 方法，就会在系统中保持大量SSH连接进程。此时，可能会出现以下报错::

   Traceback (most recent call last):
     File "/home/admin/venv2/bin/pssh", line 118, in <module>
       do_pssh(hosts, cmdline, opts)
     File "/home/admin/venv2/bin/pssh", line 89, in do_pssh
       statuses = manager.run()
     File "/home/admin/venv2/lib/python2.7/site-packages/psshlib/manager.py", line 68, in run
       self.update_tasks(writer)
     File "/home/admin/venv2/lib/python2.7/site-packages/psshlib/manager.py", line 133, in update_tasks
       self._start_tasks_once(writer)
     File "/home/admin/venv2/lib/python2.7/site-packages/psshlib/manager.py", line 146, in _start_tasks_once
       task.start(self.taskcount, self.iomap, writer, self.askpass_socket)
     File "/home/admin/venv2/lib/python2.7/site-packages/psshlib/task.py", line 99, in start
       close_fds=False, preexec_fn=os.setsid, env=environ)
     File "/usr/lib64/python2.7/subprocess.py", line 711, in __init__
       errread, errwrite)
     File "/usr/lib64/python2.7/subprocess.py", line 1224, in _execute_child
       self.pid = os.fork()
   OSError: [Errno 11] Resource temporarily unavailable

检查ssh进程，可以看到::

   ps aux | grep ssh

输出::

   admin    101317  0.0  0.0  78828   992 ?        Ss   08:46   0:00 ssh: /home/admin/.ssh/demo1-22-admin [mux]
   admin    101321  0.0  0.0  78828  3164 ?        Ss   08:46   0:00 ssh: /home/admin/.ssh/demo3-22-admin [mux]
   admin    101324  0.0  0.0  78828   996 ?        Ss   08:46   0:00 ssh: /home/admin/.ssh/demo4-22-admin [mux]
   admin    101330  0.0  0.0  78828  3176 ?        Ss   08:46   0:00 ssh: /home/admin/.ssh/demo7-22-admin [mux]
   ...

大量包含 ``[mux]`` 的 ``multiplexing（多路传输）`` SSH连接存在，导致执行pssh时无法 ``os.fork()`` 出新的ssh连接进程

解决
========

有多种原因可能会导致进程无法 ``fork`` ，所以也有不同的解决方法：

- 可能有大量的服务或进程在运行，需要检查确认进程数量，线程或内存消耗是否符合使用案例的预期，确保不超过限制。单纯提高限制并不能解决进程、线程或内存泄漏导致的资源浪费和不可预期的后果。
- 当系统运行在一个进程数量有限制状态，增加 ``/etc/security/limits.conf`` 的 ``nproc`` 值或者 ``/etc/security/limits.d/90-nproc.conf`` 配置。这个限制可以针对特定用户或者所有用户::

   <user>       -          nproc     2048      <<<----[ Only for "<user>" user ]
   *            -          nproc     2048      <<<----[ For all user's ]

- 当系统运行出现内存超出，需要定位内存泄漏的应用程序，建议采用 :ref:`valgrind` 来排查应用程序的内存使用情况，并且使用 :ref:`cgroup` 来限制进程的资源使用

参考
========

- `What does the error message "fork failed: Resource temporarily unavailable" mean? <https://access.redhat.com/solutions/22105>`_
