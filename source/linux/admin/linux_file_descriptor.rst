.. _linux_file_descriptor:

===========================
Linux文件描述符(文件句柄)
===========================

Linux文件描述符(文件句柄)表示进程打开的文件:

- 查看指定 ``PID`` 打开的文件::

   # lsof -p 28290
   # lsof -a -p 28290
   # ls -l /proc/28290/fd

- 使用 ``wc -l`` 计算打开文件数::

   lsof | wc -l

- 列出内核内存的文件描述符::

   sysctl fs.file-nf

输出可能类似::

   fs.file-nr = 7424	0	9223372036854775807

找出系统中占用FD最多的进程
=============================

当进程占用文件句柄过多，甚至达到了limits上限时，会导致应用程序无法正常工作，此时需要找出系统中占用文件句柄最多的进程:

.. literalinclude:: linux_file_descriptor/get_hogging_fd_process.sh
   :language: bash
   :caption: 列出系统中每个进程占用的文件句柄且按照打开FD数量排序

不过，我遇到过陈旧的操作系统 ``lsof`` 整个系统非常卡的情况，所以也可以改写如下脚本:

.. literalinclude:: linux_file_descriptor/get_hogging_fd_process_script.sh
   :language: bash
   :caption: 采用脚本列出系统中每个进程占用的文件句柄

获取指定PID的对应进程名:

.. literalinclude:: linux_file_descriptor/get_process_name_by_pid.sh
   :language: bash
   :caption: 列出指定进程ID对应的进程名

对于每个进程，可以独立检查其打开的文件:

.. literalinclude:: linux_file_descriptor/get_process_fd_list.sh
   :language: bash
   :caption: 列出指定进程打开的文件(句柄)

实时监控指定进程打开的文件
=============================

如果要观察当前登陆实例(bash)的打开文件，可以结合 ``watch`` ::

   watch -n 10 ls -l /proc/$$/fd

或者使用如下一个简单循环::

   while:
   do
    ls -l /proc/$$/fd
    sleep 10
   done

或者还是使用 ``lsof`` ::

   watch "lsof -p 1234"

参考
=======

- `Linux: Find Out How Many File Descriptors Are Being Used <https://www.cyberciti.biz/tips/linux-procfs-file-descriptors.html>`_
- `Kubernetes can't start due to too many open files in system <https://stackoverflow.com/questions/37067434/kubernetes-cant-start-due-to-too-many-open-files-in-system>`_
- `Monitor open process files on Linux in real-time <https://serverfault.com/questions/219323/monitor-open-process-files-on-linux-in-real-time>`_
- `Increasing open files limit for all processes: Do I need to set Soft/Hard limits? <https://unix.stackexchange.com/questions/410672/increasing-open-files-limit-for-all-processes-do-i-need-to-set-soft-hard-limits?rq=1>`_
