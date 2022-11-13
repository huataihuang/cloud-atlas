.. _get_container_by_pid:

==================================
从进程pid反推获得该进程所属容器
==================================

在生产环境中排查系统异常，经常会遇到某个进程异常，如D状态。此时我们需要找出这个进程所属哪个容器，以便找到对应的应用服务器进行排查。

通过procfs获取容器信息
==========================

通常我们使用 ``systemd-cgls`` 可以比较容易通过树形结构找出某个进程以及对应进程的容器，不过，在脚本中，其实还有一个办法，就是直接从 ``procfs`` 找出进程的 ``cgroup`` 来确定所属容器::

   cat /proc/<process-pid>/cgroup

此时会看到所属cgroup的字符串，这个字符串就对应容器id，可以进一步获取容器名字::

   docker inspect --format '{{.Name}}' "${containerId}" | sed 's/^\///'

反复查找ppid直到找到容器名
===========================

另一个思路是不断查找进程的父id，直到匹配上容器名特征，此时就能顺藤摸瓜找出容器:

.. literalinclude:: get_container_by_pid/get_docker_container.sh
   :language: bash
   :caption: 获取docker的容器

类似思路，如果不是运行docker，而是使用 :ref:`containerd` ，则脚本修订:

.. literalinclude:: get_container_by_pid/get_containerd_container.sh
   :language: bash
   :caption: 获取containerd的容器

参考
=======

- `CoreOS - get docker container name by PID? <https://stackoverflow.com/questions/24406743/coreos-get-docker-container-name-by-pid>`_
  - `jsidhu/find_docker_container_from_pid.sh <https://gist.github.com/jsidhu/d6924f549df7f2f440a6e8af109f9d08>`_
