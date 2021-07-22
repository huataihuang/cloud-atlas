.. _docker_cgroup_v2:

=====================
Docker支持Cgroup v2
=====================

从 Docker Engine 20.10开始支持 :ref:`cgroup_v2` ，提供了精细的io隔离功能。舍弃了之前在 cgroups v1 提供的 ``blkio-weight`` 选项，原因是 Kernel v5.0开始舍弃支持 cgroups v1 的blkio-weight选项 ( blkio.weight was removed in kernel 5.0:  `torvalds/linux@f382fb0 <https://github.com/torvalds/linux/commit/f382fb0bcef4c37dc049e9f6963e3baf204d815c>`_ )。

参考
======

- `Docker Engine 20.10 Released: Supports cgroups v2 and Dual Logging <https://www.infoq.com/news/2021/01/docker-engine-cgroups-logging>`_
- `deprecate blkio-weight options with cgroups v1 #2908 <https://github.com/docker/cli/pull/2908>`_
