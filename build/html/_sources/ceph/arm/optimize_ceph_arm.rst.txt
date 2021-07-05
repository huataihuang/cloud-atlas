.. _optimize_ceph_arm:

===============
ARM架构Ceph优化
===============

.. note::

   汇总ARM架构Ceph优化思路，然后逐步实践

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


参考
=====

- `Ceph Month 2021: Optimizing Ceph on Arm64 <https://www.youtube.com/watch?v=IzYYOdm2nuE&list=WL&index=8>`_
