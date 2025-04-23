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

- 安装完成后使用 ``df -h`` 检查可以看到初始安装占用空间很小，只需要大约 ``574MB`` :

.. literalinclude:: freebsd_root_on_zfs_using_gpt/df_output
   :caption: 初始安装占用空间极小，只需 ``574MB``
   :emphasize-lines: 2

- 接下来可以完成 :ref:`freebsd_init`

参考
=======

- `Installing FreeBSD Root on ZFS using GPT <https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot>`_
