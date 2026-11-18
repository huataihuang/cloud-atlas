.. _zvol:

=============
ZVOL
=============

zvol是一个作为块设备而不是文件系统的数据集。zvol提供了一个数据集的所有功能:

- checksums
- 压缩
- 快照
- clone
- replication
- 加密

同时向使用者(即操作系统、上层文件系统)呈现为一个raw设备，提供虚拟机磁盘，iSCSI LUN，ZFS本身未实现的文件系统(我理解为可以在zvol上建立另一个文件系统)，或是交换空间(swap，即可以在zvol上创建交换空间)。

zvol的特性和性能
===================

从我看到的一些资料来看， ``zvol`` 既是一个功能强大的裸设备，但是底层也背负了极多的功能。这使得它使用起来极有可能和常规raw设备不同(而冲突)导致非常差的性能:

我理解zvol就是剥离了最上层文件系统结构的底层文件系统，也就是说除了没有目录和文件，其他文件系统的功能它都具备了。所以它提供了压缩、快照、clone、replication、加密这些在其他文件系统上可能见到的不同功能。

这带来一个问题，就是 ``zvol`` 自身是具有缓存功能的，它的缓存功能和在 ``zvol`` 块设备上创建的其他文件系统的缓存功能是"冲突"的，换句话说，双重缓存虽然不报错，但是会导致性能急剧下降。

所以在实践中，我觉得要深入了解不同文件系统实现的功能以及原理，特别是叠加起来导致冲突的功能，必须要妥善调优，以避免出现不可预知的性能损耗甚至数据损坏。

举例:

- :ref:`qemu-img_convert_qcow2_zvol` 为避免 ``qcow2`` 这种压缩的 **稀疏文件** 使用的 ``CoW`` 写时复制机制和 ZFS的 ``CoW`` 写时复制机制冲突(双重写时复制带来不必要的性能损耗)，需要将 ``qcow2`` 转换成 ``raw`` 磁盘存储到 zvol 上。

zvol实践
=============

在 :ref:`incus_freebsd` 和 :ref:`incus_debian_vm` 这种基于ZFS后端存储引擎上的 :ref:`incus` 管理存储就是针对虚拟机采用了 ``zvol`` ，当执行 ``zfs list`` 就可以看到如下 ``zvol`` :

.. literalinclude:: zvol/incus_vm_zvol
   :caption: :ref:`incus` 使用ZFS作为存储引擎时，虚拟机都是使用 ``zvol``
   :emphasize-lines: 4,6

为了在 :ref:`debian` 和 :ref:`freebsd` 虚拟机中模拟使用ZFS系统，我需要创建一些 ``zvol`` 块设备并通过 :ref:`incus_disk_device_mapping` 来模拟实践:

.. literalinclude:: zvol/create_zvol
   :caption: 创建 zvol 

.. note::

   :ref:`incus_storage_volumes` 直接在 :ref:`incus` 中集成了 ``zvol`` 管理功能

参考
======

- `OpenZFS Basic Concepts / Datasets / ZVOLs <https://openzfs.github.io/openzfs-docs/Basic%20Concepts/Datasets/ZVOLs.html>`_
