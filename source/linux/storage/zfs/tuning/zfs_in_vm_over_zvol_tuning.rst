.. _zfs_in_vm_over_zvol_tuning:

================================
在Zvol上部署使用ZFS的虚拟机
================================

.. note::

   这个问题我目前还在思考，实践中需要做反复的性能测试对比非常花费时间，所以本文会在后续的实践中不断更新。

:ref:`zvol` 是一个功能极其丰富的 ``dataset`` ，提供了ZFS dataset的全部特性:

- 校验(checksum)
- 写时复制(CoW)
- 快照(snapshot)
- 克隆(clone)
- 透明加密(encrypt)

由于 ``zvol`` 是一个块设备，可以提供给 :ref:`kvm` 虚拟机使用，例如 :ref:`incus_zfs` 将 ``zvol`` 作为块设备提供给虚拟机使用。这带来了底层块设备和虚拟机内部文件系统如何配合以及性能优化的问题，两者同时启用相同的特性("双重化")会产生性能损耗:

为什么"双重化"会严重影响性能
=============================

- 双重读写缓存(Double Caching)

  - 宿主机: ZFS 有自己的 ARC(自适应更换缓存，占用大量内存)，zvol 也会走 Linux 的 Page Cache。
  - 虚拟机: VM 内部的文件系统(ZFS)也有自己的 ARC 和内存缓存。
  - 后果: 同一份热点数据在宿主机内存和虚拟机内存中会被重复缓存，白白浪费宝贵的物理内存。更糟的是，当发生频繁写入时，两层的缓存驱逐策略可能会互相干扰。

- 双重 CoW 与指数级写放大(Double CoW & Write Amplification)

  - 原理: ZFS 是强 CoW(写时复制)的文件系统。虚拟机内部的 ZFS 修改了一个 ``4KB`` 的小文件，它需要触发内层 ZFS 的 CoW 逻辑(例如写新的 block)，这会变成对虚拟磁盘的一次较大写入(比如 128KB 的 recordsize)。而当这个写入到达底层宿主机的 zvol 时，宿主机的 ZFS 又会触发一次外层的 CoW，再次分配新的块。
  - 后果: 改一个极小的文件，底层物理磁盘可能要进行数倍的数据读、改、写。这会造成严重的磁盘碎片，让 IOPS 表现呈断崖式下跌，特别是对于 SSD，会极大地加速其磨损(Flash Wearout)。

- 双重压缩(Double Compression)

  - 虚拟机内部压缩了一次: 数据写到磁盘时，宿主机的 zvol 又压缩了一次。
  - 影响: 虽然多级压缩对性能的损害不如双重 CoW 和缓存那么致命（因为现代 CPU 处理 LZ4/ZSTD 速度极快），但它毫无意义，纯粹浪费 CPU 周期。

- 双重校验和(Double Checksumming)

  - 内外两层 ZFS 都会计算并校验数据块的 checksum。校验本身消耗 CPU，且会加剧缓存失效。

最佳实践与架构选择
====================

在生产环境中，如果可以避免，强烈建议不要在 zvol 上套娃运行 ZFS。

更好的替代方案:

- 如果虚拟机内部需要 ZFS 的特性（如快照、克隆），应当考虑直接使用 :ref:`incus` 容器( :ref:`container` ) 而不是虚拟机。Incus 容器与宿主机共享内核，直接挂载 ZFS Dataset，零额外开销。
- 如果必须用虚拟机，且虚拟机内需要管理多个文件系统，尽量在 VM 内使用 ext4 / xfs 等非 CoW 文件系统。将快照和备份交由外层的 Incus zvol/ZFS 去做。

不得不"套娃"时的调优配置指南
==============================

因为特定业务需求（例如在 VM 内做复杂的存储实验、或需要内部 ZFS 演练）必须在 zvol 上运行 ZFS，可以通过以下手段进行极限调优，以最大程度地缓解性能衰减:

块大小对齐(Block Size Alignment) -- 最关键的一步
-------------------------------------------------

如上文分析，如果ZFS的内外层块大小不匹配，双重CoW带来的底层物理磁盘数倍的读写会存在严重磁盘碎片和IOPS性能暴跌，导致SSD磨损。解决采用对齐原则: 让内层的每一次块写入，正好对应外层 :ref:`zvol` 的一个完整块，避免"大块拆小块、小块凑大块"带来的双重寻址和读写放大。

- 检查物理主机上 :ref:`zvol` 的 ``volblocksize`` :

.. literalinclude:: zfs_in_vm_over_zvol_tuning/volblocksize
   :caption: 检查物理主机zvol的 ``volblocksize``

输出显示在物理主机上 ``zvol`` 的 ``volblocksize`` 大小是 **16k** :

.. literalinclude:: zfs_in_vm_over_zvol_tuning/volblocksize_output
   :caption: 检查物理主机zvol的 ``volblocksize``

- 检查虚拟机内部的ZFS dataset 的 ``recordsize`` :

.. literalinclude:: zfs_in_vm_over_zvol_tuning/recordsize
   :caption: 检查虚拟机内ZFS的dataset的 ``recordsize``

输出显示虚拟机上 ``dataset`` 的 ``recordsize`` 大小是 **128k** :

.. literalinclude:: zfs_in_vm_over_zvol_tuning/recordsize_output
   :caption: 检查虚拟机内ZFS的dataset的 ``volblocksize``

- 外层 :ref:`zvol` 块大小: 通过ZFS属性调整宿主机的 ``zvol`` 块大小 ``volblocksize``

.. literalinclude:: zfs_in_vm_over_zvol_tuning/set_volblocksize
   :caption: 设置外层zvol的 ``volblocksize``

- 内层 :ref:`zfs` 记录大小: 调整虚拟机内部创建的dataset，将 ``recordsize`` 设置为与外层 ``zvol`` 的 blocksize 完全一致:

.. literalinclude:: zfs_in_vm_over_zvol_tuning/set_recordsize
   :caption: 设置内存虚拟机dataset的 ``recordsize``

关闭内层或外层的重复压缩
-------------------------

- 如果外层(宿主机 ``zvol`` )已经开启了压缩(如默认的 ``lz4`` 或 ``zstd`` )，则强烈建议关闭虚拟机内部ZFS的压缩:

.. literalinclude:: zfs_in_vm_over_zvol_tuning/compression_off
   :caption: 关闭虚拟机内部dataset的压缩

这样既保留了宿主机统一压缩节省物理空间的优势，又避免了 CPU 经历两次无意义的加解压。

调整虚拟机控制器的缓存策略(QEMU/KVM Cache Mode)
--------------------------------------------------

在 Incus/QEMU 层，磁盘的缓存模式对性能有决定性影响，检查或调整虚拟机的磁盘缓存配置（通常在 Incus 的设备配置中）

推荐配置: ``cache=none`` 或 ``cache=writeback`` (需谨慎评估数据安全性)

``cache=none`` : 绕过宿主机的 Page Cache，让虚拟机发出的 IO 直接落到 zvol 的 ARC 中，避免了宿主机 Linux Page Cache 与 ZFS ARC 的双重缓存竞争。

禁用内层的 ZFS Atatime(访问时间更新)
----------------------------------------

关闭 atime 写入，减少不必要的元数据修改(CoW 的罪魁祸首之一):

.. literalinclude:: zfs_in_vm_over_zvol_tuning/atime_off
   :caption: 关闭dataset的 ``atime`` 写入

调整虚拟机内部的文件系统预读与 I/O 调度器
--------------------------------------------

在虚拟机内部的 Linux 系统中，将虚拟磁盘(通常表现为 ``vdX`` 或 ``sdX`` )的 I/O 调度器设置为 ``none`` 或 ``mq-deadline`` 。因为底层宿主机和虚拟化层已经做了调度，虚拟机内部不需要复杂的电梯算法( ``BFQ`` 等)，避免加剧延迟。


参考
======

- gemini
