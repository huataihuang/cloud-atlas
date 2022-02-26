.. _runtime_mem:

===================
容器运行时内存配置
===================

运行时限制内存方法
======================

在 ``docker run`` 命令运行容器时，可以通过传递参数 ``--memory`` 和 ``--memory-swap`` 来限制容器能够使用的内存和交换空间。

参考
=====

- `Runtime options with Memory, CPUs, and GPUs <https://docs.docker.com/config/containers/resource_constraints/>`_
- `Docker: Placing limits on container memory using cgroups <https://fabianlee.org/2020/01/18/docker-placing-limits-on-container-memory-using-cgroups/>`_
