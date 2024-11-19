.. _kernel_numa:

===============================
Linux内核NUMA
===============================

NUMA(non-uniform memory access, 非一致性内存访问)是指在一个多处理器系统中配置处理器的cluster方式，以便处理器核心能够就近访问共享内存，提高系统性能和系统的扩展性。NUMA在对称处理器(symmetric multiprocessing, SMP)系统中使用。SMP对称多处理器系统是一个"紧耦合"(tightly-coupled)"共享所有"(share
everything)的系统，即多个处理器工作在一个单一操作系统并通过一个共用总线或"内部连接"路径访问彼此的内存。通常，SMP的缺陷是即使增加处理器，共享的总线或数据路径会超载并成为性能瓶颈。NUMA在多个处理器之间增加了一个共享内存的中间层，这样就不需要将所有数据都通过总线。

NUMA可以被视为一个"cluster in a box"(盒中集群)，这个cluster通常包含4个微处理器(例如，4个奔腾处理器)通过一个本地总线互联(例如，PCI总线)连接到一个位于单块主板(也称为"card")上的共享内存(称为"L3 cache")。这个单元可以加到一个类似单元来构建一个对称多处理器系统(symmetric multiprocessing system,
SMP)，这种共用SMP总线互联了所有的cluster。这种SMP系统通常包含16~256路微处理器。当一个应用程序运行在SMP系统，所有独立的处理器内存看上去就像一个单一内存。

当一个处理器在一个确定内存地址读取数据，它会首先查看微处理器自身的L1 cache，然后检查临近的更大的L1和L2缓存(依然是和这个微处理器相关联的L1 and L2缓存)，再然后检查NUMA配置提供的L3缓存(和这个微处理器最近的L3缓存)，只有这3层缓存都没有查到数据才会检查其他处理器相邻的"远程内存"。这些cluster在NUMA中就像互联网络中的"节点"(node)，而NUMA就维护着这些节点的层次关系视图。

数据在NUMA SMP系统clusters之间的总线中移动，使用了一种称为可伸缩一致性接口(scalable coherent interface, SCI)技术。SCI一致性也被称为 `缓存一致性 <https://www.infoq.cn/article/cache-coherency-primer>`_ 或者多集群节点一致性访问。

SMP和NUMA系统通常用于数据挖掘和决策支持系统的应用程序，这样多个进程可以并行运行在多个处理器上为公共数据库工作。

.. note::

   缓存一致性指在多级缓存和多处理器情况下保证缓存和内存中数据一致的技术：

   - 直写模式：数据直接写到下一级缓存(或直接写到内存)中，如果对应的段被缓存了，则同时更新缓存的内容(甚至直接丢弃缓存)
   - 回写模式: 缓存不会立即把写操作传递到下一级，而是仅修改本级缓存中数据，并把对应的缓存段标记为"脏"段。脏段会触发回写，也就是把里面的内容写到对应的内存或下一级缓存中。回写后，脏段又变"干净"了。当一个脏段被丢弃的时候，总是先进行一次回写。

   直写模式简单，回写模式虽然复杂，但是优势是: 能够过滤掉对同一地址的反复写操作，并且，如果大多数缓存段都在回写模式下工作，系统经常可以一下子写一大片内存，提高了效率。

   缓存一致性协议通常采用"窥探"协议(snooping
   protocol)：所有内存传输都发生在一条共享总线上，而所有处理器都能看到这条总线。缓存本身是独立的，但是内存是共享资源，所有内存访问都要经过仲裁(arbitrate)。同一个指令周期中，只有一个缓存可以读写内存。当一个缓存代表它所属的处理器去读写内存时，其他处理器会得到通知，以此来使得自己的缓存保持同步。只要某个处理器一写内存，其他处理器马上就知道这块内存在它们自己的缓存中对应的段已经失效。上述方式在直写模式下写操作是直接公布的，但是回写模式，则需要在处理器修改本地缓存之前就告知其他处理器。这种处理回写模式的方案称为 MESI协议(MESI, Modified、Exclusive、Shared、Invalid，代表四种缓存状态)。详细技术我将在 :ref:`kernel` 的内存管理相关文档中详细解说。

.. note::

   ARM处理器有一种类似cache的和处理器内核紧密耦合的内存（TCM, Tightly Coupled Memoried)，性能和cache相当，但是提供了程序代码可精确控制的缓存控制，提供用户控制什么函数或代码存放在TCM中，确保永远不会被踢出主存储器: 可预见的实时处理（中断处理）、时间可预见（加密算法）、避免cache分析（加密算法）、或者只是要求高性能的代码（编解码功能）。 参考:  `TCM - 紧耦合内存 <https://zhuanlan.zhihu.com/p/30684711>`_

.. note::

   Intel处理器的拓扑有些复杂，可以使用 `cpu-topology <https://github.com/gbitzes/cpu-topology>`_ 这个脚本检查。

   推荐使用 :ref:`lstopo` 工具查看系统拓扑，可以查看处理器缓存、NUMA节点以及PCI设备连接，并且同时提供了字符界面和图形界面，非常简洁实用。

参考
========

- `What is NUMA? <https://www.kernel.org/doc/html/v4.18/vm/numa.html>`_
- `NUMA (non-uniform memory access)  <https://whatis.techtarget.com/definition/NUMA-non-uniform-memory-access>`_
- `NUMA (Non-Uniform Memory Access): An Overview <https://queue.acm.org/detail.cfm?id=2513149>`_ 非常详尽的科普
