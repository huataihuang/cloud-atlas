.. _choice_linux_filesystem:

==================
Linux文件系统选择
==================

概要
======

参考 `XFS vs. Ext4: Which Linux File System Is Better? <https://blog.purestorage.com/purely-educational/xfs-vs-ext4-which-linux-file-system-is-better/>`_ :

- XFS对于大型文件性能更好: 支持大型文件的并发读写操作，例如媒体文件，数据库文件性能更好，适合需要高响应性能的服务器
- EXT4对于海量小型文件性能更优(但不支持并发读写操纵)，所以操作系统根分区建议采用，也适合小型文件共享
- EXT4提供了较好的安全属性设置
- XFS内建了恢复工具，而EXT4则需要使用第三法国恢复工具
- XFS和EXT4都经过了长期的高负载考验，所以通常并没有明显差异，仅在高压力服务器上需要谨慎区分选择

参考
======

- `Linux文件系统的未来 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/storage/filesystem/the_future_of_linux_filesystem.md>`_ 整理了一些文件系统选择的参考信息
- `RHEL8 docs - Managing file system CHAPTER 1. OVERVIEW OF AVAILABLE FILE SYSTEMS <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_file_systems/overview-of-available-file-systems_managing-file-systems>`_
- `XFS vs ext4 performance <https://unix.stackexchange.com/questions/525613/xfs-vs-ext4-performance>`_
- `XFS vs. Ext4: Which Linux File System Is Better? <https://blog.purestorage.com/purely-educational/xfs-vs-ext4-which-linux-file-system-is-better/>`_
