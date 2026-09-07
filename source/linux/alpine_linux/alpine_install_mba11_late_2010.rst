.. _alpine_install_mba11_late_2010:

===========================================
MacBook Air 11" Late 2010安装Alpine Linux
===========================================

我在尝试复活 :ref:`mavericks_mba11_late_2010` 还是遇到系统陈旧存在效率低下的问题。但是我不甘心，因为 :ref:`mba11_late_2010` 实在太小巧了，而且能够用十六年前复古的设备，想想还是很酷的。

想到我一直考虑采用 :ref:`sunshine` / :ref:`moonlight` 以及 :ref:`rdp` 远程使用 :ref:`hackintosh` ，我忽然想到最轻量级的 :ref:`alpine_linux` 或许可以帮助我实现一个非常巧妙的移动工作的方案:

- Alpine Linux作为始终持续开发和进步的Linux发行版，能够用最先进的技术来充分发掘我这台古老设备的能力: 没错， :ref:`moonlight-embedded` 能够用服务器端部署端 :ref:`linux` , :ref:`macos` 和 :ref:`windows` 来运行高负载极度复杂端软件，相当于我通过类似 ``chromebook`` 调用超级计算机或集群。
- 本地只运行轻量级的 :ref:`vim` 配合纯C+ :ref:`python` 开发，以及良好配置的文本编辑能力，让我能够随时编辑 :ref:`devops_docs` 并通过CI/CD推送自动部署

启动
======

:ref:`mba11_late_2010` 对于现代的 ``iso-hybrid`` 镜像直接 ``dd`` 创建的启动U盘，会触发BUG导致屏幕完全灰色卡死( :ref:`alpine_install_mba11_late_2010_detail` )，所以我最终采用 :ref:`linux_apple_usb_superdrive` 刻录标准CD-ROM来启动安装。

初始设置
==========

通过光盘启动Alpine Linux安装，首先执行 ``setup-alpine`` 命令设置环境

.. literalinclude:: alpine_install_mba11_late_2010/setup-alpine
   :caption: 设置安装环境

磁盘分区
==========

请注意，我已经 :ref:`mavericks_mba11_late_2010` ，所以在安装alpine linux之前，磁盘分区如下:

.. literalinclude:: alpine_install_mba11_late_2010/fdisk_macos
   :caption: 已经安装了Mavericks系统的磁盘分区

如上所述，为了workround :ref:`mba11_late_2010` EFI启动第三方64位efi死机问题，我在alpine linux分区采用了传统CSM分区，也就是整个磁盘混合了 "GPT + CSM分区"，以便 ``rEFInd`` 能够根据分区标记 ``bios_grub`` 来启动Linux所使用的Grub:

.. note::

   在标准的 UEFI 机器上，将 ESP 分区（ ``/dev/sda1`` ， **FAT32** ）挂载到 ``/mnt/boot`` 或 ``/mnt/boot/efi`` ，然后运行 ``setup-disk -m sys /mnt`` ，Alpine 的自动化脚本会自动调用 ``grub-install --target=x86_64-efi`` ，将 **64 位** 纯 UEFI 版的 GRUB ( ``grubx64.efi`` ) 直接写入 ESP 分区。

   但是，Alpine 自动化脚本 ( ``setup-disk -m sys`` ) 默认安装的是 UEFI 模式的 GRUB，而不是 Legacy CSM 模式的 GRUB: ``setup-disk`` 探测到系统处于 **64 位 EFI 环境** ，会自动安装 ``x86_64-efi`` 版本的 GRUB 到 ``/dev/sda1`` 。

   触发 GPU 致命 Bug：一旦通过 ``/dev/sda1`` 里的 ``grubx64.efi`` 启动，Apple 固件就会以 **纯 64 位 EFI 模式** 初始化 NVIDIA 320M 显卡，就会遇到启动直接灰屏死机。

.. warning::

   为解决 :ref:`mba11_late_2010` 兼容问题，在执行 ``setup-disk`` 指令前指定 ``BOOTLOADER=none`` 来禁止自动安装GRUB，并采用手工方式安装 ``i386-pc`` （BIOS/CSM）模式的 GRUB 到 MBR。

.. csv-table:: GPT + CSM 分区方案
   :file: alpine_install_mba11_late_2010/csm_partitions.csv
   :widths: 20,10,20,10,40
   :header-rows: 1

.. literalinclude:: alpine_install_mba11_late_2010/parted
   :caption: 分区

完成分区以后，执行 ``doas parted /dev/sda print`` 检查确认分区:

.. literalinclude:: alpine_install_mba11_late_2010/parted_print
   :caption: 分区检查
   :emphasize-lines: 11-13

这里有一个异常显示 ``/dev/sda4`` 显示为 ``xfs`` ，这是因为之前我创建过一个 ``/dev/sda4`` 分区并格式化成xfs。虽然在这里分区之前删除了旧分区，但是旧文件系统签名还在，这会导致后续GRUB写入该分区裸代码时导致引导工具混淆。所以需要擦除旧签名！

- 使用 ``wipefs`` 工具检查和清理签名:

.. literalinclude:: alpine_install_mba11_late_2010/wipefs
   :caption: 检查sda4额文件系统签名

输出显示:

.. literalinclude:: alpine_install_mba11_late_2010/wipefs_output
   :caption: 检查sda4额文件系统签名显示残留了xfs签名

彻底擦除签名:

.. literalinclude:: alpine_install_mba11_late_2010/wipefs_clean
   :caption: 擦除xfs签名

- 安装磁盘工具

.. literalinclude:: alpine_install_mba11_late_2010/install_mkfs
   :caption: 安装 mkfs.ext4 和 mkfs.xf

- 格式化磁盘分区:

.. literalinclude:: alpine_install_mba11_late_2010/mkfs
   :caption: 将sda5格式化为ext4, sda6格式化为xfs

- 最后再次检查 ``parted`` 输出:

.. literalinclude:: alpine_install_mba11_late_2010/parted_print_finish
   :caption: 最终的磁盘分区和文件系统
   :emphasize-lines: 11-13

- 挂载文件系统:

.. literalinclude:: alpine_install_mba11_late_2010/mount
   :caption: 挂载文件系统

完成以后，执行 ``df -h`` 可以看到文件系统挂载如下:

.. literalinclude:: alpine_install_mba11_late_2010/df
   :caption: 最后完成的磁盘挂载
   :emphasize-lines: 8,9

安装alpine
===========

- 运行 Alpine 安装 (跳过默认 bootloader)

.. literalinclude:: alpine_install_mba11_late_2010/setup-disk
   :caption: 安装Alpine

请注意，我采用了 ``BOOTLOADER=none`` ，跳过了bootloader安装，这是因为我需要解决 :ref:`mba11_late_2010` 的UEFI缺陷，需要采用手工方式安装grub的CSM兼容模式。

安装grub
===========

由于 :ref:`mba11_late_2010` 对现代纯EFI启动支持存在缺陷，所以通过设置传统BIOS引导让 ``rEFInd`` 能够根据激活分区来查找启动项:

.. literalinclude:: alpine_install_mba11_late_2010/grub
   :caption: 安装grub
