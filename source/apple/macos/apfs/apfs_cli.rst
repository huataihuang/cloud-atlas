.. _macos_apfs_cli:

==================
macOS APFS命令行
==================

在构建 :ref:`darwin-jail` 时，可以看到macOS的chroot目录是非常庞大的，如果没有结合 APFS 卷管理进行有效的 ``snapshot`` / ``clone`` ，那么jail的价值就非常低。

APFS的GUI程序Disk Utility缺乏一些特定的功能，需要通过命令行来补充(例如不能仅umount而不弹出)。不过，命令行 ``diskutils`` 实际上也比较复杂，需要仔细归类整理学习。

.. warning::

   我这里的一些案例是我参考学习笔记，针对我自己的笔记本上环境:

   .. literalinclude:: apfs_cli/df
      :caption: 当前系统挂载卷情况
      :emphasize-lines: 11

   你的环境可能不同，需要自行调整。

检查和修复 ``fsck_apfs``
=========================

使用Disk Utiulity的首要目标是使用 ``fsck_apfs`` 修复，不过需要仔细核对确认需要检查卷的设备名，例如 ``disk3s1`` ，并且检查卷是否加密。

.. note::

   ``diskutil apfs unlockVolume`` 是用来解锁一个加密数据卷，这里只是做一个案例演示，我没有加密卷

   如果没有指定解锁路径，就会尝试解锁当前根文件系统的数据卷

   ``-W`` 尝试使用空密码解锁

解锁一个卷并且不挂载卷案例:

.. literalinclude:: apfs_cli/unlockVolume
   :caption: 解锁卷并且不挂载卷

这里我遇到提示是这个卷已经 ``unlock`` 过了，所以实际没有变化:

.. literalinclude:: apfs_cli/unlockVolume_output
   :caption: 解锁卷并且不挂载卷，不过卷已经unlock

对于 ``unlock`` 的卷就可以执行 ``fsck_apfs`` ，有一些常用选项:

- ``-S`` : 跳过检查 :ref:`apfs_snapshots`
- ``-n`` : 只检查不修复
- ``-y`` : 尝试修复所有找到的错误
- ``-q`` : 执行快速检查(quick check)来验证快照和超级块检查点是否正常

.. literalinclude:: apfs_cli/fsck_apfs
   :caption: 检查APFS

``apfs_fsck`` 检查不需要 ``umount`` ，我的实践案例输出类似如下:

.. literalinclude:: apfs_cli/fsck_apfs_output
   :caption: 检查APFS输出案例
   :emphasize-lines: 17

其他的一些案例组合:

.. literalinclude:: apfs_cli/fsck_apfs_examples
   :caption: ``fsck_apfs`` 案例

使用 ``diskutil`` 获取信息
============================

``diskutil`` 提供了获取文件系统信息的功能

- 快速发现设备标识和简短综述:

.. literalinclude:: apfs_cli/diskutil_list
   :caption: 设备列表

输出案例:

.. literalinclude:: apfs_cli/diskutil_list_output
   :caption: 只有 ``disk0`` 是物理存储设备
   :emphasize-lines: 1

- 提供完整的扩展信息列表:

.. literalinclude:: apfs_cli/diskutil_info
   :caption: 输出完整扩展列表

可以看到整个系统完整的磁盘信息:

.. literalinclude:: apfs_cli/diskutil_info_output
   :caption: 输出完整扩展列表
   :emphasize-lines: 4,5,139,140

可以看到:

  - ``disk0`` 是物理介质 ``APPLE SSD AP0256M``
  - ``disk1`` 是 ``APFS Container``

- **非常有用的命令** ``diskutil apfs list`` ( 非常类似 :ref:`zfs` ``zfs list`` )

.. literalinclude:: apfs_cli/diskutil_apfs_list
   :caption: 能够以树状结构展示出整个APFS文件系统分布，非常形象

可以清晰地看出APFS的磁盘分布结构

- 检查所有挂载的卷组:

.. literalinclude:: apfs_cli/diskutil_apfs_listvolumegroups
   :caption: 列出卷组(仅显示containers)

输出类似:

.. literalinclude:: apfs_cli/diskutil_apfs_listvolumegroups_output
   :caption: 列出卷组(仅显示containers)
   :emphasize-lines: 1

- 列出加密(安全Token)用户:

.. literalinclude:: apfs_cli/diskutil_apfs_listusers
   :caption: 列出加密用户

输出

.. literalinclude:: apfs_cli/diskutil_apfs_listusers_output
   :caption: 列出加密用户

``diskutil`` 的主要工具
=======================

``diskutil apfs [verb]`` 提供了一系列功能:

- ``list``
- ``listSnapshots``
- ``listVolumeGroups``
- ``convert`` : 将HFS+转换为APFS
- ``create`` : 创建一个简单卷
- ``createContainer`` : 创建空白容器
- ``deleteContainer``
- ``resizeContainer``
- ``addVolume``
- ``deleteVolume``
- ``deleteVolumeGroup``
- ...

.. note::

   还有很多参数有待后续实践再补充整理

参考
=======

- `APFS: Command tools <https://eclecticlight.co/2024/04/22/apfs-command-tools/>`_
