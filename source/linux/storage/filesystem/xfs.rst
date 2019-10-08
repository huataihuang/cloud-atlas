.. _xfs:

===============
XFS文件系统
===============

安装和修复XFS
--------------

- 安装XFS管理工具 ``xfsprogs`` ::

   sudo pacman -S xfsprogs

- 如果需要修复XFS文件系统，需要先umount之后再修复::

   umount /dev/sda3
   xfs_repair -v /dev/sda3

XFS在线元数据检验(scrub)
---------------------------

.. warning::

   XFS的scrub可以用来检验元数据，但是这是一个试验性质程序。

``xfs_scrub`` 会查询内核有有关XFS文件系统所有元数据独爱想。元数据记录被扫描检查明显损坏值然后交叉应用另一个元数据。目的是通过检查单个元数据记录相对于文件系统中其他元数据的一致性来建立对整个文件系统一致性的合理信心。如果存在完整的冗余数据结构，则可以从其他元数据重建损坏的元数据。

通过启动和激活 ``xfs_scrub_all.timer`` 来周期性检查在线XFS文件系统的元数据。

XFS元数据校验
----------------

xfsprogs 3.2.0引入了一个磁盘格式v5包含了元数据校验和机制，称为"自描述元数据"(Self-Describing Metadata)，基于CRC32，提供了对于元数据的附加保护，避免电源故障时发生意外。从xfsprogs 3.2.3开始默认激活了校验，不过对于比较旧哦内核，可以通过 ``-m crc=0`` 关闭校验::

   mkfs.xfs -m crc=0 /dev/target_partition

XFS性能
-----------

在RAID社别上使用XFS时候，有可能通过使用 ``largeio`` , ``swalloc`` 参数值增加来提高性能。参考:

- `Recommended XFS settings for MarkLogic Server <https://help.marklogic.com/Knowledgebase/Article/View/505/0/recommended-xfs-settings-for-marklogic-server>`_

.. note::

   MarkLogic Server是面向文档的No-SQL数据库，上文提供了XFS优化策略可以参考实践。

XFS条带大小和宽度
-------------------

如果文件系统建立在条代化的RAID之上，通过 ``mkfs.xfs`` 命令参数设置特定条带大小可以显著提升性能。XFS有时能够检查出底层软RAID的分布，但是对于硬件RAID，请参考 `how to calculate the correct sunit,swidth values for optimal performance <http://xfs.org/index.php/XFS_FAQ#Q:_How_to_calculate_the_correct_sunit.2Cswidth_values_for_optimal_performance>`_

参考
======

- `Arch Linux社区文档 - XFS <https://wiki.archlinux.org/index.php/XFS>`_
