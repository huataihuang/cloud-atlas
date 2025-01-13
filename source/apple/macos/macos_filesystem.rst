.. _macos_filesystem:

=====================
macOS 文件系统
=====================

.. _apfs:

APFS
========

现代macOS 从 10.14 版本开始，默认使用 ``APFS`` (Apple File System)。这个现代文件系统是从 macOS High Sierra 10.13 (2017年) 阿开始引入，现在已经广泛用于Apple的产品，包括 Macs, iPhone, iPad, Apple Watches 和 Apple TV。

APFS是针对闪存和固态驱动器设计的文件系统，并针对 ``HFS+`` 文件系统做了改进，提供了很多数据一致性和存储空间节约的功能:

- 使用了 Copy-on-Write(CoW, 写时复制)技术，极大降低了数据损坏的风险
- APFS使用 ``容器`` (Container) 作为存储数据的关键要素(principal element):

  - 一个单一容器可以保存多个卷(文件系统)并共享存储空间
  - 有关容器的块数量，块大小等信息被保存在Container Superblock，也就是作为每个卷的入口点
  - 通过一个公共的位图(Bitmap)来帮助跟踪整个容器中块的分配

- 与此同时，卷也有自己的卷超级块(Volume Superblocks)以及存储数据和元数据的独立结构:

  - 所有文件和目录都被一个二进制搜索树结构所管理，也就是文件和目录的 ``B-Trees`` (类似 :ref:`btrfs` ?)
  - 树的节点(nodes)存储键和值(keys and values)

.. note::

   `GitHub: linux-apfs/linux-apfs-rw <https://github.com/linux-apfs/linux-apfs-rw>`_ 提供了在Linux环境试验性的APFS读写支持，在主要发行版有集成，或许APFS可以作为共享文件系统来使用。

   `GitHub: libyal/libfsapfs <https://github.com/libyal/libfsapfs>`_ 提供了对APFS v2的只读支持

   `GitHub: sgan81/apfs-fuse <https://github.com/sgan81/apfs-fuse>`_ 提供AFPFS只读FUSE驱动，在主流发行版可以获得安装

   `Paragon Software <https://www.paragon-software.com/>`_ 在 4-Clause BSD License 提供了一个SDK支持只读方式访问APFS驱动器。此外这家公司提供一个Windows上的商业软件Paragon's APFS for Windows可以读写APFS。



.. _hfs+:

HFS+
=========

HFS+ (Hierarchical File System Plus) 也称为 Mac OS 扩展文件系统，是Mac OS 8.1 发布的默认文件系统。不过从 macOS High Sierra 10.13开始被APFS取代。

HFS+文件系统采用了日志机制来防止结构损坏:

- 所有文件系统修改都记录在日志区域，这样在发生意外(如断电)时可以立即恢复
- HFS+的核心结构式卷标头(Volume Header)，也就是在HFS+卷开头，包含了一般FS参数以及其他关键元素的位置

  - 大多数服务信息被组织成特殊文件
  - 这些特殊文件可以在卷的不同部分找到，摒弃主要由B树表示

- HFS+的整个存储空间被分成相等的分配块，每个分配块的状态都记录在类似位图的分配文件中
- 文件的块会分配到连续的组以降低碎片

参考
=====

- `The file systems of macOS <https://www.ufsexplorer.com/articles/macos-file-systems/>`_
- `Wikipedia: Apple File System <https://en.wikipedia.org/wiki/Apple_File_System>`_
