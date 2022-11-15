.. _zfs_compression:

========================
ZFS压缩
========================

压缩算法: zstd vs. lz4
=========================

简单来说(以下是我YY):

- ``LZ4`` 压缩功能存储性能最好，在一定应用场景能够提升存储性能，适合对IO性能有极致要求，同时又需要一定的压缩存储节约成本
- ``zstd`` 提供不同级别的压缩率，在数据压缩率上比 ``LZ4`` 要好，但是更消耗计算资源，存储性能下降，但是降低了存储成本

如果是近线(海量)存储，可以选择 ``zstd`` 压缩; 如果是在线服务( :ref:`docker_zfs_driver` )，建议选择 ``lz4`` 压缩

:ref:`zfs_enterprise`
======================

亚马逊AWS `Amazon FSx for OpenZFS <https://aws.amazon.com/fsx/openzfs/>`_ 服务，是基于OpenZFS实现的NFS共享存储，在2022年3月宣布增加 ``LZ4`` 压缩选项( `You can now choose from two different compression options on Amazon FSx for OpenZFS <https://aws.amazon.com/about-aws/whats-new/2022/03/choose-different-compression-options-amazon-fsx-openzfs/>`_ )。AWS作为云计算巨头，推出的 `Amazon FSx for OpenZFS <https://aws.amazon.com/fsx/openzfs/>`_ 为 ``OpenZFS`` 提供了强力的背书，数据压缩选项开放也从侧面证明了OpenZFS的 ``LZ4`` 和 ``Z-Stand`` 两种压缩选项都已经达到了企业级生产应用水准。


参考
=======

- `Zstandard Compression in OpenZFS <https://freebsdfoundation.org/wp-content/uploads/2021/05/Zstandard-Compression-in-OpenZFS.pdf>`_
- `Zstd & LZ4 <https://indico.fnal.gov/event/16264/contributions/36466/attachments/22610/28037/Zstd__LZ4.pdf>`_
- `ZFS(Smart?)Compression <https://openzfs.org/w/images/4/4d/Compression-Saso_Kiselkov.pdf>`_
- `zstd vs lz4 for NVMe SSDs <https://www.reddit.com/r/zfs/comments/orzpuy/zstd_vs_lz4_for_nvme_ssds/>`_
- `ZFS basics: enable or disable compression <https://www.unixtutorial.org/zfs-basics-enable-or-disable-compression/>`_
- `You can now choose from two different compression options on Amazon FSx for OpenZFS <https://aws.amazon.com/about-aws/whats-new/2022/03/choose-different-compression-options-amazon-fsx-openzfs/>`_
