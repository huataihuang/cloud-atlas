.. _clone_gentoo:

====================
Clone Gentoo Liinux
====================

我的 :ref:`mba11_late_2010` 已经有十二年历史了，目前有一个比较异常的地方: 启动时键盘失效，准确地说，是无法使用 ``option`` 键来选择启动顺序，无法从U盘启动安装操作系统，也无法激活 :ref:`macos_recovery` 。而且启动时候非常缓慢，启动时有时进入安全模式。我感觉是SSD磁盘坏掉了，所以采用 :ref:`macbook_sata` 来尝试替换。

为了能够在新的SATA磁盘上先安装好Linux，我采用在 :ref:`install_gentoo_on_mbp` ( :ref:`mba13_mid_2013` 上完成 )，然后外接U盘方式进行本文的Clone步骤。目标是完整安装好系统之后，将硬盘再安装到 :ref:`mba11_late_2010` 。

磁盘准备
===========

将安装了 SATA (NGFF) SSD的U盘插入已经完成 :ref:`install_gentoo_on_mbp` 的 :ref:`mba13_mid_2013` ，检查 ``fdisk -l`` 输出可以看到这块空白的磁盘:

.. literalinclude:: clone_gentoo/fdisk
   :caption: ``fdisk -l`` 看到的空白磁盘

- 使用 :ref:`parted` 为这个空白磁盘分区，分区方式同 :ref:`install_gentoo_on_mbp` :

.. literalinclude:: clone_gentoo/parted_sdc
   :caption: 使用 :ref:`parted` 对sdc磁盘分区

.. warning::

   这里我遇到一个问题， :ref:`orico_m2_nvme_sata_udisk` 中安装的SATA磁盘分区总是显示不能对齐，暂时没有找到原因。我怀疑是转接卡的芯片有特定配置导致的，等后续将SATA安装到主机后再验证

磁盘挂载
============

- 挂载文件系统

.. literalinclude:: clone_gentoo/mount_sdc
   :caption: 挂载文件系统

数据同步
==========

由于本机已经完成Gentoo Linux安装，所以通过同步方式复制:

.. literalinclude:: clone_gentoo/tar_clone
   :caption: 通过 ``tar`` 复制系统

这里使用了 ``--one-file-system`` 参数，是为了不包含其他文件系统中的文件，否则会把复制目标的 ``/mnt`` 目录也复制进去，就会死循环。参考 :ref:`recover_system_by_tar`
