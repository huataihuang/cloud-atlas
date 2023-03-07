.. _intro_oom_in_k8s:

==================================
Kubernetes Out-of-memory (OOM)简介
==================================

OOM的困扰
==========

在生产环境中，很多时候会出现运行在Kubernetes容器中的应用进程莫名终止，常见的有应用状态不正常引发的Kubernetes杀掉pod，此外非常多的情况是出现了所谓的 ``OOM Killed`` 。

.. note::

   Kubernetes为现代部署带来了适应各种环境的标准化，但是也带来了复杂的架构，这导致 :ref:`devops` 的开发者和运维者之间持续的拉锯：要定位是应用原因还是Kubernetes原因导致的异常需要高超的技术能力。

内存过量使用(overcommit)
==========================

内存overcommit是非常常见常见的操作系统技术，这意味着操作系统为进程分配了超过实际能够分配的内存量。这是因为几乎没有程序会同时使用所有分配给它的内存，类似于银行，除非出现 ``挤兑`` 否则内存overcommit完全不会影响应用程序运行，而且使得内存能够更为有效利用。

- 检查Linux系统内存分配:

.. literalinclude:: intro_oom_in_k8s/meminfo
   :language: bash
   :caption: 检查 /proc/meminfo

输出信息:

.. literalinclude:: intro_oom_in_k8s/meminfo_output
   :language: bash
   :caption: cat /proc/meminfo 输出信息
   :emphasize-lines: 1,33

可以看到 ``MemTotal`` 表示主机实际安装内存大小（192G）；而 ``VmallocTotal`` 则是overcommit的内存大小（大约有32T）


参考
======

- `Out-of-memory (OOM) in Kubernetes – Part 1: Intro and topics discussed <https://mihai-albert.com/2022/02/13/out-of-memory-oom-in-kubernetes-part-1-intro-and-topics-discussed/>`_ 这个系列文章非常用心，但是也存在一些没有探讨的范畴:

  - :ref:`huge_memory_pages`
