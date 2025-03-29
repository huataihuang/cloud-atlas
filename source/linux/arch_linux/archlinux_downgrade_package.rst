.. _archlinux_downgrade_package:

=======================
arch linux降级软件包
=======================

我在 :ref:`archlinux_zfs-dkms_arm` 遇到一个麻烦: :ref:`asahi_linux` 11月22日发布新版本内核 ``6.1rc6`` 已经超出了 :ref:`zfs` 支持的最高版本 ``6.0`` ，导致 :ref:`dkms` 编译时候出现异常(但是我感觉很可能是版本编号的支持问题)，所以我准备等 :ref:`asahi_linux` 出正式内核版本时再做尝试。目前先把内核版本回滚到之前的 ``5.19`` 。

回滚内核
=========

- 在 ``/var/cache/pacman/pkg`` 目录下有缓存的软件包( asahi linux 官方下载仓库已经没有提供就版本 )，采用如下命令回滚:

.. literalinclude:: archlinux_downgrade_package/archlinux_downgrade_kernel
   :language: bash
   :caption: 降级arch linux内核版本到5.19

失败实践记录
--------------

但是很不幸，我在 :ref:`asahi_linux` 上仅仅回滚 ``linux-asahi`` 内核包，重启会出现无法加载broadcom无线网卡firmware报错::

   [Wed Nov 23 20:55:46 2022] hci_bcm4377 0000:01:00.1: Adding to iommu group 2
   [Wed Nov 23 20:55:46 2022] hci_bcm4377 0000:01:00.1: enabling device (0000 -> 0002)
   [Wed Nov 23 20:55:46 2022] hci_bcm4377 0000:01:00.1: Unable to load firmware; tried 'brcm/brcmbt4387c2-apple,madagascar-u.bin' and 'brcm/brcmbt4387c2-apple,madagascar.bin'
   [Wed Nov 23 20:55:46 2022] hci_bcm4377 0000:01:00.1: Failed to load firmware
   [Wed Nov 23 20:55:46 2022] hci_bcm4377: probe of 0000:01:00.1 failed with error -2

在 :ref:`asahi_linux` 系统的 ``/boot/efi/vendorfw/manifest.txt`` 列出了所有firmware信息。 但是, ``pacman -Qo xxx`` 却查不到这个文件属于哪个软件包。

我最终没有解决内核降级后的 broadcom无线网卡firmware 加载。

考虑到苹果芯片需要非常新的内核支持，所以我不再尝试降级内核，而是放弃在 :ref:`asahi_linux` 上使用 :ref:`zfs` 。因为OpenZFS目前只支持 v6.0 内核，无法跟上 :ref:`asahi_linux` 的快速内核迭代。在 :ref:`asahi_linux` 我改为同样前沿的 :ref:`btrfs` ，而在X86 MacBook Pro 2013笔记本上实践 :ref:`zfs` 。


参考
=======

- `arch linux: Downgrading packages <https://wiki.archlinux.org/title/downgrading_packages>`_
