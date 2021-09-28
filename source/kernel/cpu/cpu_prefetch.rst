.. _cpu_prefetch:

================
CPU预取
================

缓存预取(Cache prefetching)是计算机处理器在真正使用之前就通过从缓慢的内存中将指令或数据加载到快速到本地内存(即 ``预取`` )来加速执行性能的技术。由于处理器的本地缓存通常比主内存更快，所以预取数据并且从换从中访问数据会比直接从主内存访问数据要快。这种预取可以通过非阻塞缓存控制指令来实现。

参考
======

- `Cache prefetching <https://en.wikipedia.org/wiki/Cache_prefetching>`_
- `CPU Hardware Prefetch – The BIOS Optimization Guide <https://www.techarp.com/bios-guide/cpu-hardware-prefetch/>`_
