.. _clone_gentoo:

====================
Clone Gentoo Liinux
====================

.. warning::

   实践尚未成功，待更新

我的 :ref:`mba11_late_2010` 已经有十二年历史了，目前有一个比较异常的地方: 启动时键盘失效，准确地说，是无法使用 ``option`` 键来选择启动顺序，无法从U盘启动安装操作系统，也无法激活 :ref:`macos_recovery` 。而且启动时候非常缓慢，启动时有时进入安全模式。我感觉是SSD磁盘坏掉了，所以采用 :ref:`mba11_late_2010_update_sata` 来尝试替换。

为了能够在新的SATA磁盘上先安装好Linux，我采用在 :ref:`install_gentoo_on_mbp` ( :ref:`mba13_early_2014` 上完成 )，然后外接U盘方式进行本文的Clone步骤。目标是完整安装好系统之后，将硬盘再安装到 :ref:`mba11_late_2010` 。

磁盘准备
===========

将安装了 SATA (NGFF) SSD的U盘插入已经完成 :ref:`install_gentoo_on_mbp` 的 :ref:`mba13_early_2014` ，检查 ``fdisk -l`` 输出可以看到这块空白的磁盘:

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

修订配置
==========

需要注意，每次格式化的磁盘UUID和PARTUUID是不同的，所以目标磁盘需要修订

- 执行 ``blkid`` 命令获取 ``/dev/sdc`` 的磁盘 UUID 和 PARTUUID:

.. literalinclude:: clone_gentoo/blkid
   :caption: ``blkid`` 获取 ``/dev/sdc`` 磁盘 UUID 和 PARTUUID 

- 修订 ``/dev/sdc`` 磁盘上的 ``/etc/fstab`` 文件，此时根据磁盘挂载，应该修改 ``/mnt/gentoo/etc/fstab``

.. literalinclude:: clone_gentoo/fstab
   :caption: 修订磁盘上的 ``/etc/fstab``

启动管理器
===============

现在问题来了，怎么能够把要修复的 :ref:`mba11_late_2010` 启动盘指向我新clone的Gentoo Linux呢？

毕竟没法直接在 :ref:`mba11_late_2010` 运行类似 :ref:`install_gentoo_on_mbp` 的 ``efibootmgr`` 

我想到Gentoo Linux 的LiveCD是可以启动的(虽然启动时要按下 ``option`` 键才能选择GRUB启动管理器)，那么我在这个磁盘上安装和配置 ``grub`` 能否让MacBook启动时找到一个启动盘呢？

chroot到 ``/dev/sdc`` 上的gentoo
-----------------------------------

- 挂载文件系统:

.. literalinclude:: install_gentoo_on_mbp/mount_fs
   :language: bash
   :caption: 挂载文件系统

- 进入Gentoo新环境:

.. literalinclude:: install_gentoo_on_mbp/chroot
   :language: bash
   :caption: 进入clone的Gentoo

安装Grub
----------

- 先安装Grub软件，然后执行 ``grub-install`` : 注意，对于EFI系统，需要确保 EFI 系统分区已经挂载好

.. literalinclude:: clone_gentoo/grub
   :caption: 安装grub启动管理器并部署grub (EFI系统)
   :emphasize-lines: 4

执行 ``grub-install --target=x86_64-efi --efi-directory=/boot/efi`` 命令之后，输出信息:

.. literalinclude:: clone_gentoo/grub_output
   :caption: 部署grub (EFI系统)输出信息

此时检查 ``/boot/efi/`` 目录下会增加一个 ``EFI`` 子目录，并且包含 ``gentoo/`` 子目录，最终包含一个 ``grubx64.efi`` 文件:

.. literalinclude:: clone_gentoo/efi
   :caption: 最终安装完成 ``grubx64.efi``
   :emphasize-lines: 3

这里我看来没有真正理解，上述 ``grub-install`` 会使得本机EFI配置变化，这反而使得 :ref:`install_gentoo_on_mbp` 这台中间笔记本的启动破坏(我理解 ``grub-install`` 的EFI命令实际上是修改了efibootmgr的)。那么是不是需要使用传统的 ``grub-install /dev/sdc`` 呢，也就是将grub安装到磁盘的启动分区表

.. warning::

   我的实践还是失败，我准备过一段时间再来重试
