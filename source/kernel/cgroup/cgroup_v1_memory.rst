.. _cgroup_v1_memory:

====================
cgroup v1 内存管理
====================

.. _memcg_kmem:

Kernel Memory Extension (CONFIG_MEMCG_KMEM)
================================================

通过内核内存扩展(Kernel Memory Extension)，内存控制器(Memory Controller)能够限制系统使用的内核内存量。内核内存基本上不同于用户内存，因为它不能 ``swap out`` (换出)，所以DoS攻击可能会针对消耗这种宝贵的资源来进行系统攻击。

默认情况下，所有内存 ``cgroup`` 都启用内核内存记账，但是可以通过 ``cgroup.memory=nokmem`` 内核参数来在系统范围内 ``禁用`` **内核内存记账** 。

.. note::

   Red Hat 7所使用 ``3.10.0-1160.88.1.el7`` 存在 SLAB leak，会一定概率导致 :ref:`fail_create_container_cannot_allocate_memory` 。目前(2023年4月)Red Hat尚未发布修复补丁(也可能因为RHEL 7终止支持而不修复)，所以建议升级到 RHEL 8.1(内核已修复)，或者在不升级内核的系统中 ``禁用`` **内核内存记账** 来绕过这个问题。

根cgroup没有强制内核内存限制，所以根使用的 ``cgroup`` 可能记入页可能不记入，使用的内存累积到 ``memory.kmem.usage_in_bytes`` 。目前没有对内核内存实施软限制，未来可能会达到限制时触发slab回收。

当前记账的内核内存资源
-----------------------

- ``stack pages`` : 每个进程都消耗一些stack pages，记入内核内存可以防止内核运行时创建新内存使用率过高
- ``slab pages`` : 跟踪由 SLAB 或 SLUB 分配器分配的页面。在 ``memcg`` 内部，每次第一次访问缓存都会创建每个 ``kmem_cache`` 副本，创建是延迟完成的，所以一些对象仍可以在创建缓存时跳过，slab页面的所有对象都应该属于同一个 ``memcg`` ，仅在缓存页面分配期间迁移到不同的 ``memcg`` 会出现保留失败
- ``sockets memory pressure`` : sockets协议有内存压力阈值
- ``tcp memory pressure`` : tcp 协议的套接字内存压力

参考
======

- `kernel document: cgroup v1 memory.txt <https://www.kernel.org/doc/Documentation/cgroup-v1/memory.txt>`_
