.. _btrfs_facebook:

=======================
Facebook的Btrfs
=======================

目前最大的生产环境应用Btrfs可能是互联网巨头Facebook，已经在上百万的服务器上使用Btrfs。Facebook使用Btrfs主要是为了提高存储硬件的质量，即在硬件失效前可以通过Btrfs检测出问题。

Btrfs快照和镜像
==================

我们知道现在云计算已经从最初的虚拟化演进到虚拟化结合容器化的云计算，通过容器化可以更为快速可伸缩地部署应用服务。但是类似Docker容器化的磁盘隔离，需要设置复杂的文件系统Quota以及卷隔离，不仅复杂而且创建缓慢，拖累 :ref:`kubernetes` 实现serverless的快速部署。

Facebook推出了容器化隔离解决方案是Tupperware：以前是每次启动一个任务来设置容器的文件系统，但是消耗了大量的磁盘IO和CPU。现在，通过Btrfs的快照功能，Tupperware可以从一个预先准备的Btrfs image生成snapshot。

Tupperware Btrfs实现也存在3个主要的问题：

- 缺乏实际进程隔离：每个从scratch创建的容器文件系统给予每个任务进程一个隔离的文件系统视图，但是这个视图并不是真正和主机上其他任务相隔离的。一个任务可以轻易访问主机上另一个进程的根文件系统，而无需用户显式配置任务共享文件系统。也就是说一个任务可以覆盖另一个任务的数据存储。

- 管理进程需要消耗大量IO: 在重启、移动或更新Tupperware是需要大量的I/O操作。

- 可检测性：先后设置Tupperware消耗大量用户准备任务运行，很多操作可能会因为不同原因失败。

Facebook的解决方案主要是：

- 采用基于镜像的设置可以真正隔离任务，一个任务不能修改另一个任务的文件系统
- 对于已经存在主机上的镜像，可以只消耗很少的IO就能实现复制(COW)，并且很多时候基础镜像是相同的，每个容器仅修改很少部分，这就大大节约了磁盘消耗。
- 基于镜像的实现可以包装任务的所有文件系统配置，并且任务owner可以很好配置镜像内容。

.. note::

   Btrfs是目前Linux系统中唯一完善支持 `io.latency <https://lwn.net/Articles/782876/>`_ 和 `io.cost <https://lwn.net/Articles/792256/>`_ 块I/O控制器。这些控制器不能用于ext4文件系统，在XFS文件系统上目前也存在一些问题。

cgroup2的IO管控
================

在Facebook公司内部采用了 :ref:`cgroup_v2` Linux内核机制来分组工作负载以及控制系统每个资源组的资源分配。使用了cgroup2的Tupperware共享池是使用Btrfs作为重要角色来增加IO效率。

之前Tupperware采用ext4作为共享池的文件系统，但是遇到了ext4更新文件系统日志缓慢，特别是必须等待一些辅助数据完成写盘才能更新ext4文件系统日志的瓶颈。所以Facebook切换到Btrfs来解决ext4文件系统的不足：

- 通过将ext4替换成Btrfs，主要的改进是日志的多余步骤被消除了，这要就能够允许 :ref:`cgroup_v2` 实现复杂的IO控制
- Btrfs的实现也带了附加好处：数据一致性，快速回滚以及更容易管理

透明文件压缩节约磁盘空间
=========================

Btrfs支持透明文件压缩，有3种压缩算法:

- ZLIB
- LZO
- ZSTD

Btrfs是基于 ``file-by-file`` 方式压缩的，也就是在一个Btrfs挂载种，可以混合使用不同压缩算法的压缩文件，也可以混合不压缩的文件。

为了增加容量，Facebook在开发环境采用了 Zstd压缩算法(这个压缩算法也是Facebook开源的)，以便能够提供更多的开发VM的空间。这个压缩文件系统不仅节约了SSD存储的空间消耗，也延长了固态存储的寿命(因为通过压缩可以最小化写操作执行)。特别是对于源代码，压缩效果非常好，写操作降低也带来了存储设备擦除减少。

.. note::

   在Facebook每个开发者都有一个工作虚拟机，这些工作虚拟机包含了整个web网站的 全部源代码。也就是说每个虚拟机都需要包含800GB以上源代码，并且有足够共建能够完成开发工作，所以文件系统压缩是具有巨大价值。

通过快照改进持续集成
=======================

Facebook的持续集成系统Sandcastle是一个构建、测试和加载代码的CI系统，也是Facebook公司最大的服务之一。

Facebook的工作流要求任何人都不可以直接提交代码仓库，所有的提交修改前都需要完成一个完整测试。build系统会clone整个公司的代码仓库，apply上patch，build整个系统，然后运行测试。

一旦测试完成，整个测试系统就被清理掉，然后准备下一个patch的测试。这个清理过程是相当缓慢的，平均删除一个完整代码书的大型目录需要花费2~3分钟，一些测试甚至需要十分钟才能完成清理，在这个清理过程中会阻塞下一次测试。

Facebook的基础架构团队使用Btrfs的快照功能来实现海量的持续集成软件仓库副本创建和删除操作，由于Btrfs的快照可以瞬间创建，无需实际的数据复制，这就消除了复制代码仓库的延迟，提高了Sandcastle持续集成系统的可用性。

测试系统只是创建一个快照(几乎瞬间完成)，测试运行完成后，从用户角度看快照又是瞬间删除的，远比删除整个文件目录要快。这个文件系统从ext4迁移到Btrfs极大改进了编译系统效率也降低了容量要求，Facebook实现了只需要之前1/3的服务器就满足了系统编译和测试。

Facebook在Btrfs上的持续优化
============================

Facebook还在改进和实现的架构方案:

- Btrfs的增量备份支持，可以实现Tupperware镜像更新时节约网络带宽和IO
- Btrfs的数据去重来节约磁盘空间占用
- 支持多租户虚拟机的Quota
- checksum清洗来监控磁盘健康状态

Btrfs存在的不足和挑战
=======================

在Facebook的WhatsApp服务需要存储用户的海量消息文本，但是消息非常小，导致元数据存储消耗了数百G空间以及碎片化极为严重。这种情况下可能不适合采用Btrfs进行存储。

根据Facebook的Btrfs经验，在特定的RAID控制器上Btrfs会持续报告checksum errors，每次重启RAID控制器会写入一些所及数据到磁盘中间，这个问题会导致无声地损坏文件系统。

.. note::

   根据上下文，似乎Facebook使用了非LSI的RAID控制器，可能是为了降低成本。不过我个人觉得类似ZFS和Btrfs不应该在硬件RAID之上构建文件系统，因为硬件RAID屏蔽了底层磁盘，如果存在firmware的BUG是难以发现的。不如直接使用ZFS或Btrfs的软件RAID功能，或者采用分布式文件系统构建多副本方式。通过软件实现存储可以不断通过软件迭代来修复问题。

比较出乎意料的优点是Btrfs提供了发现微处理器bug的跟踪方式。原因是Btrfs趋向于比其他文件系统对CPU压力更大，例如checksume，压缩以及将工作负载卸载到线程中，这些特性都使得系统繁忙。Fackbook公司的服务器都是自己定制的硬件，通过Btrfs暴露了一些CPU问题。

对于Facebook而言，目前还没有解决WhatsApp工作负载对于海量小文件(消息)的Btrfs存储。

.. note::

   传统的文件系统需要元数据支持来存储文件，这导致对于海量数量的文件存储非常消耗资源。Facebook寻求通过Btrfs解决消息小文件存储的方案可能是由于历史原因不得不如此，另一种可能是为了解决消息文件的加密，毕竟Btrfs内建支持了加密功能。
   现代分布式文件系统通过对象存储方式避免元数据处理开销，可能比较适合海量小文件存储，但是对于加密和压缩，可能还没有成熟解决。

参考
======

- `Btrfs at Facebook(facebookmicrosites) <https://facebookmicrosites.github.io/btrfs/docs/btrfs-facebook.html>`_
- `Btrfs at Facebook <https://lwn.net/Articles/824855/>`_ - Facebook的Btrfs开发Josef Bacik介绍了Facebook如何投入Btrfs以及依然存在的挑战（ `2020 Open Source Summit North America <https://events.linuxfoundation.org/open-source-summit-north-america/>`_ )
