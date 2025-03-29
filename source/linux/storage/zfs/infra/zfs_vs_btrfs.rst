.. _zfs_vs_btrfs:

================
ZFS vs. Btrfs
================

在Linux平台，有两个一直相互竞争且功能相似的 ``全面型`` 文件系统，也就是同时具备了卷管理和文件系统功能、并且支持压缩、加密等高级特性。这就是最初发源于 Solaris的ZFS系统和雄心勃勃的 :ref:`btrfs` 。

我个人的感觉:

- ZFS发展历史更长，虽然也背负了历史的包袱(毕竟发明时候还没有SSD/NVMe这样改变存储基础的技术)，但是长期的持续开发也修复了大多数bug，稳定性和可靠性相对Btrfs有较大优势
- ZFS更适合生产环境使用，不论是Solaris这样原本面向服务器领域的UNIX系统还是后续接过ZFS开发的BSD系统，都有非常好的稳定性口碑
- ZFS采用RAM来加速优化的方法(这也是适应早期传统HDD性能不足的解决方案)使得ZFS比Btrfs更消耗资源，但是通过精心的调优，在(内存)资源充足情况下，ZFS可以达到高性能和高稳定性
- ZFS在早期Solaris阶段就已经实现了复杂的RAID架构，不仅有简洁的RAID0/1，也有性价比较高的RAID-Z，而Btrfs一直没有在RAID5达到生产稳定性
- ZFS的不足可能在于最早发源于Solaris，采用CDDL授权，有点类似BSD的授权，即基于ZFS的再开发可以不用开源，所以有可能ZFS的使用范围很难清晰了解

参考
======

- `Btrfs vs OpenZFS <https://linuxhint.com/btrfs_vs_openzfs/>`_
- `Ubuntu is moving to ZFS, but is it really a superior file system for Linux than Btrfs? <https://www.quora.com/Ubuntu-is-moving-to-ZFS-but-is-it-really-a-superior-file-system-for-Linux-than-Btrfs>`_
