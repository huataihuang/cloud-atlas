.. _find_container_process:

=============================
容器进程查找(物理主机视角)
=============================

现代使用容器的系统，我们经常需要查找一个异常进程属于哪个容器，以便能够顺藤摸瓜分析存在的问题。但是，在物理主机上无法直接看到容器namespace，所以不是很容易找到进程所述容器。

解决思路
=========

:ref:`systemd` 提供了一个工具可以直接列出所有cgroup的进程，以树状方式展示，类似 ``tree`` 命令::

   systemd-cgls

将输出内容重定向到文件，然后通过搜索可以找到进程的父进程，直到定位到容器。接下来就可以通过 :ref:`nsenter` 进入对应namespace，或者使用 ``docker exec -it <container_id> /bin/bash`` 进入容器进行检查。

参考
======

- `Finding Docker container processes? (from host point of view) <https://stackoverflow.com/questions/34878808/finding-docker-container-processes-from-host-point-of-view>`_
