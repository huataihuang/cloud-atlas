.. _freebsd_root_on_zfs_using_gpt:

==========================================
使用GPT分区在ZFS上构建FreeBSD Root(安装)
==========================================

我在 :ref:`freebsd_on_intel_mac` 采用了默认的自动ZFS安装，发现整个磁盘被自动分配给ZFS，导致抹除了原本安装的Linux。我在后续的实践中，重新部署，计划构建一个FreeBSD/Linux( :ref:`lfs` )双启动系统，以便能够验证不同平台的虚拟化和 :ref:`kubernetes` 模拟。

由于我希望能够自如切换FreeBSD/Linux系统，并且构建跨两种OS公用的数据分区( :ref:`zfs` 文件系统)，所以就需要改进安装过程，控制FreeBSD安装在ZFS上的分区大小。所以就有本文的手工安装ZFS作为FreeBSD Root的实践，这种方式下能够控制ZFS分区大小，并且空出磁盘为后续构建 :ref:`zfs_raidz` 做准备。

.. note::

   我按照 `Installing FreeBSD Root on ZFS using GPT <https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot>`_ 完成，只有少数地方按需修改。该文档非常完备，操作非常顺利。

在ZFS上手工安装FreeBSD
========================

关键步骤是安装过程到了 ``Partition`` 分区步骤时，不能选择Auto ZFS，而是要选择 ``shell`` 选项，此时进入控制台，按照以下步骤操作:

- 检查系统中有哪些磁盘:

.. literalinclude:: freebsd_root_on_zfs_using_gpt/camcontrol
   :caption: 检查系统中磁盘

这里可以看到2块 :ref:`kioxia_exceria_g2` ，我将在 ``nda0`` 上安装FreeBSD:

.. literalinclude:: freebsd_root_on_zfs_using_gpt/camcontrol_output
   :caption: 检查系统中磁盘，安装目标磁盘是 ``nda0``
   :emphasize-lines: 2

- 创建一个全新的分区表( ``警告，会摧毁磁盘上所有数据`` ):

.. literalinclude:: freebsd_root_on_zfs_using_gpt/partition
   :caption: 重建分区表

- 创建包含启动代码的分区(bootcade partition):

**我的实践是创建UEFI Boot**

.. literalinclude:: freebsd_root_on_zfs_using_gpt/uefi_boot
   :caption: 创建UEFI启动分区，注意，该分区是 FAT32 分区

如果是传统BIOS启动(我没有执行):

.. literalinclude:: freebsd_root_on_zfs_using_gpt/bios_boot
   :caption: 创建BIOS启动分区

- 创建分区:

  - ``-a <number>`` : 控制对齐
  - ``-s <size>`` : 设置分区大小，如果没有指定分区大小，就会将磁盘剩余空间全部用掉(我设置指定256GB，因为后面空闲分区我将用于构建独立的ZFS，以便构建 :ref:`ceph` 模拟集群)
    
.. literalinclude:: freebsd_root_on_zfs_using_gpt/zfs
   :caption: 创建swap和zfs分区

- 创建ZFS Pool:

.. literalinclude:: freebsd_root_on_zfs_using_gpt/zpool
   :caption: 创建ZFS Pool

- 现在需要依次创建完整的ZFS文件系统，以便安装程序能够正确分布目录:

.. literalinclude:: freebsd_root_on_zfs_using_gpt/zfs_hierarchy
   :caption: ZFS层次文件系统构建(小心谨慎)

- 配置启动环境

.. literalinclude:: freebsd_root_on_zfs_using_gpt/bootfs
   :caption: 设置启动  

完成安装
==========

- 创建 ``/tmp/bsdinstall_etc/fstab`` :

.. literalinclude:: freebsd_root_on_zfs_using_gpt/fstab
   :caption: 创建fstab

- 现在退出Shell，此时 ``bsdinstall`` 就会继续完成安装(如果上述ZFS分区没有错误的话)

- ``注意`` ，在最后安装步骤，当安装程序提示时候要补充命令，一定要回答 ``yes`` ，并完成以下命令(也就是设置系统默认启动时加载ZFS):

.. literalinclude:: freebsd_root_on_zfs_using_gpt/zfs_load
   :caption: 设置系统启动时加载ZFS

最后检查
=========

- 安装完成后使用 ``df -h`` 检查可以看到初始安装占用空间很小，只需要大约 ``574MB`` :

.. literalinclude:: freebsd_root_on_zfs_using_gpt/df_output
   :caption: 初始安装占用空间极小，只需 ``574MB``
   :emphasize-lines: 2

- 接下来可以完成 :ref:`freebsd_init`

参考
=======

- `Installing FreeBSD Root on ZFS using GPT <https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot>`_
