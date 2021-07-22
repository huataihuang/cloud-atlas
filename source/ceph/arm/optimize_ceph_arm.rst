.. _optimize_ceph_arm:

===============
ARM架构Ceph优化
===============

.. note::

   汇总ARM架构Ceph优化思路，然后逐步实践。目前以资料整理为主，待实践

ARM架构的Ceph优化主要思路是基于ARM架构的特性，充分利用硬件加速、缓存以及库优化，实现性能加速。

Ceph共享库优化
=================

ARM共享库的优化思路是采用ARM CPU特性来优化Ceph共享库:

- 优化UTF8字符串处理 

  - 可以获得8倍的字符串验证性能突破
  - 可以获得字符串编码的50%性能提升

- 通过ARM CRC32加速可以获得3倍的突发性能提升

Ceph ISA-L卸载
================

ISA-L卸载可以加速Ceph的压缩、加密等性能:

- CRC, IGZIP, RAID, AES-GCM 多字节MD5/SHA1/SHA256/SM3/SHA256...

需要充分使用ARM架构的硬件加密和压缩加速，来实现对Ceph性能的提升。

`isa-l/isa-l_crypto <https://github.com/isa-l/isa-l_crypto>`_ 提供了详细信息

64K内核页
============

ARM支持64K内核大页，内核大页可以提升Ceph的以下性能:

- 提高了TLB命中率和降低页表查询影响
- 较小的页表可以使用较少的内存空间
- 页表级别降低以后，可以提供更好的 VA->PA 转换速度

测试案例使用了:

- Ceph集群

  - Ceph 15.2.11, SPDK
  - 1 MON, 1 MGR, 3 OSD
  - 每个OSD使用一个 P4610 NVMe
  - Linux 5.8.0 内核

- 客户端: 2.8GHz多核处理器，Linux 5.8.0内核

- 测试工具: Fio v3.16

- 测试案例:

  - 顺序 读/写 和 随机 读/写 ，分别使用 4/16/64/256/4096K 块大小， 4KB / 64KB 内核页

测试结果:

- 顺序读: 性能提高 3.39% ~ 11.11%
- 顺序写: 性能提高 8.35% ~ 21.91%
- 随机读: 性能提高 6.24% ~ 9.99%
- 随机写: 性能提高 5.93% ~ 15.4%


参考
=====

- `Ceph Month 2021: Optimizing Ceph on Arm64 <https://www.youtube.com/watch?v=IzYYOdm2nuE&list=WL&index=8>`_
