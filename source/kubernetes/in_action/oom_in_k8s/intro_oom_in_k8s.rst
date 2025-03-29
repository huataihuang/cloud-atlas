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

Linux内核通过 :ref:`overcommit-accounting` 实现内存过量使用，默认是 **启发式** ``overcommit`` ( ``heuristic overcommit`` )

.. note::

   Kubernetes默认的overcommit策略是 ``接受任何分配请求`` 而不检查提交限制

oom-killer
==============

:ref:`oom_manager` 负责确保内存，在检查可用内存、判断OOM状态(调用 ``out_of_memory()`` )和选择哪个进程( ``select_bad_process()`` )有复杂的逻辑。

注意，如果出现 ``oom-killer`` 现象，应该想办法解决OOM问题的根因，而不是禁止``oom-killer`` 

一种排查思路: 如果系统内存充足，不足以触发 ``oom-killer`` ，可以采用先配置 ``vm.overcommit_memory=0`` ，在运行一段时间后，改为 ``vm.overcommit_memory=2`` ，并且 ``vm.overcommit_ratio`` 配置为比当前内存分配更小一些。此时就会出现系统分配状态 ``/proc/meminfo`` 中 ``Committed_AS`` 大于 ``CommitLimit`` 。此时运行任何程序都会出现报错 ``-bash: fork: Cannot allocate memory``

cgroups
==========

:ref:`cgroup` 是容器技术( :ref:`container_terminology` )的核心，也是Kubernetes计算节点内存依据(根据内存 **根cgroup** 统计信息计算)

cgrouops和kubernetes
---------------------

- Kubernetes的Pod中创建的每个容器都有自己的cgroup
- 在Kubernetes的每个pod中都有一个 :ref:`pause_container` 
- 容器的cgroup提供了检查统计信息，可以通过 :ref:`cadvisor` 输出

cgroups v2
------------

Kubernetes已经开始支持 :ref:`cgroup_v2` ，但是需要明确配置，例如我在 :ref:`prepare_z-k8s` 启用了 :ref:`cgroup_v2`

cgroups 和 OOM killer
-----------------------

cgroup的内存使用量超过配置限制是，就会可能触发 OOM killer :

- 首先尝试从中回收内存 cgroup 以便为 cgroup 触及的新页面(达到cgroup限制)腾出空间
- 如果回收不成功，则会调用 OOM 例程来选择并终止 cgroup 中最庞大的任务(即各个cgroup中使用内存最多的进程)

Kubernetes和OOM killer
===========================

OOM killer是内核组件，所以并不是Kubernetes决定调用OOM killer，而是OOM killer在cgroup中所有进程累计内存使用超出了cgroup限制时自动触发。这里带来一个问题，就是OOM killer并不理解Kubernetes pod概念，可能会杀掉容器中非常重要的进程但是由于没有触及 ``pid 1`` 进程，可能会导致Kubernetes依然判断pod无需终止。

.. note::

   避免关键进程不被误杀的方法是使用 :ref:`oom_score_adj`

OOM killer支持 soft limits ，不过Kubernetes尚未使用它

OOM相关的运行时( ``runtime`` )影响
===================================

对于使用 .NET 或 Java程序，是使用运行时的编程语言，除了操作系统的内存分配限制以及cgroup内存分配限制，程序运行时也会对应用内存进行限制。运行时相当于应用程序和操作系统之间的中间人，运行时runtime负责跟踪使用了哪些对象，以及对象周围的内存在不使用时可以被GC(回收)。

运行时runtime有设置选项来限制应用程序可以分配的最大内存，所以在排查应用程序无法分配内存时，我们还需要检查runtime限制。此外需要关注runtime的默认限制，也就是即使你不配置runtime限制参数，但是实际上应用程序运行还是会受到runtime限制。

.NET运行时内存限制:

- .NET GC使用容器内存(已分配但不一定使用的内存)限制的 75% 作为默认分配限制
- .NET 运行时 ``System.GC.HeapHardLimitPercent`` (75%) 机制只在容器设置限制时生效

Go语言没有实际运行时，而是将GC功能放到运行时库(runtime library)中。Go 当前缺少（截至 2021 年 12 月）用于指定堆最大限制的设置。

Kubernetes资源请求和限制
=========================

在Kubernetes中 :ref:`resource_management_for_pods_containers` 对资源请求和限制提供支持：

- 当为一个Pod中的容器指定资源请求时， ``kube-scheduler`` 使用这个信息来决定将pod调度到哪个节点
- 当为一个容器指定资源限制时， ``kubelet`` 会强制执行这些限制，以便确保运行的容器使用资源不超过设置的限制

pod的QoS:

- 决定了当节点上内存变得稀缺时pod被驱逐的顺序
- 决定了Linux上根内存cgroup ``/sys/fs/cgroup/memory/`` 层级结构中的位置: node将放置pod以及container的cgroup( 当前版本默认配置了 ``--cgroups-per-qos=true`` 标志给 ``kubelet`` )

Pod的QoS不是手工配置的，而是Kubernetes根据分配给pod中的容器的请求(request)和限制(limit)来决定的。本质上，Kubernetes通过算法查看pod中容器上的设置和限制，并最终为pod分配相应的QoS:

- ``Guaranteed`` 保证Pod一定有指定资源提供(CPU和内存)
- ``Burstable`` 则指Pod中至少有一个容器有CPU和内存的request，但是不能确保(guaranteed)
- ``BestEffort`` 指没有一个容器指定至少一个CPU或内存限制以及请求

参考
======

- `Out-of-memory (OOM) in Kubernetes – Part 1: Intro and topics discussed <https://mihai-albert.com/2022/02/13/out-of-memory-oom-in-kubernetes-part-1-intro-and-topics-discussed/>`_ 这个系列文章非常用心，但是也存在一些没有探讨的范畴:

  - :ref:`huge_memory_pages`
