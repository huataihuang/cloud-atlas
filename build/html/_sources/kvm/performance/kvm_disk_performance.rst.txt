.. _kvm_disk_performance:

=======================
KVM虚拟机磁盘性能优化
=======================

:ref:`archlinux_on_mbp` 在物理主机上测试磁盘dd性能::

   time dd if=/dev/zero of=test oflag=direct bs=64k count=16000

磁盘写入性能(nvme)可以达到350MB/s::

   16000+0 records in
   16000+0 records out
   1048576000 bytes (1.0 GB, 1000 MiB) copied, 2.99069 s, 351 MB/s

   real0m2.992s
   user0m0      .022s
   sys0m0.833s  

但是，默认 :ref:`create_vm` (CentOS 8)，即使采用了 ``virtio`` 驱动，同样的测试命令连续写入磁盘显示性能

参考
======

- `Incredibly low KVM disk performance (qcow2 disk files + virtio) <https://serverfault.com/questions/407842/incredibly-low-kvm-disk-performance-qcow2-disk-files-virtio>`_
