.. _dl360_bios:

=====================
HPE DL360 BIOS设置
=====================

通过调整HP DL360 Gen9 服务器的BIOS，尝试优化服务器性能

CPU Hardware Prefetch
========================

CPU处理器有一种硬件预取功能，可以自动分析请求并从内存中预取出未来很可能使用到数据和指令存放到Level 2缓存。这种技术可以降低内存读取延迟。

除了对于古老的Intel Pentium 4 或 Pentium 4 Xeon处理器需要关闭这个 ``CPU Hardware Prefetch`` ，其他情况下，较新的Intel处理器通常都应该激活CPU硬件预取功能。

这项缓存预取可以是:

- Data prefetching
- Instruction prefetching

但是，不一定所有应用都会得到这项技术的收益，所以还是需要做业务测试以及性能压测。特被需要关注数据库应用。

参考
======

- `Understanding BIOS Configuration for Performance Tuning <https://community.mellanox.com/s/article/understanding-bios-configuration-for-performance-tuning>`_
- `BIOS Performance Tuning Example <https://community.mellanox.com/s/article/bios-performance-tuning-example>`_
- `CPU Hardware Prefetch – The BIOS Optimization Guide <https://www.techarp.com/bios-guide/cpu-hardware-prefetch/>`_
