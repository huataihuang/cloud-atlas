.. _initramfs:

=======================
initramfs
=======================

``initramfs`` 是 :ref:`ramfs` 类型的启动初始文件系统，提供了Linux系统 ``init`` 进程运行前系统的预备性工作。

initramfs通常会处理挂载重要文件系统的工作(通过加载必要内核模块和驱动)，例如 ``/usr`` 或 ``/var`` 以及 ``/dev`` 。如果用户需要加密文件系统，也需要在 ``initramfs`` 提示中输入密码以挂载问系统。当文件系统挂载之后，控制权就被转给 ``init`` ，这样init进程就处理服务启动以及整个系统其他的启动过程。

Linux启动过程解析
=====================

当Linux内核开始控制系统(通过boot loader加载)，此时内核会准备内存结构和驱动。然后内核就会将控制权转给 ``init`` 应用，这个 ``init`` 将负责系统就绪准备，最后启动所有运行服务的进程。 ``init`` 将启动必要服务，以及 ``udev`` 服务来加载准备系统检测到的设备。当 ``udev`` 加载后，此时系统剩余的文件系统可能还没有挂载好。

初始化root磁盘(initrd)
-------------------------

为了解决文件系统尚未就绪，但是内核需要访问未挂载文件系统中文件的问题，需要使用 ``initr`` ，也就是一种内存磁盘结构体( ``in-memory disk structure`` , ramdisk )，包含必要的工具以及脚本，这样就能够在 ``init`` 程序可以接管前处理挂载必要的文件系统。

Linux内核负责触发这个位于根磁盘上的设置脚本(通常命名为 ``linuxrc`` 不过实际名字不是强制的)，这个脚本负责系统准备，然后就能够切换到真实的根文件系统，并且调用 ``init`` 。

虽然 ``initrd`` 方式能够解决问题，但是存在如下缺点:

- ``initrd`` 是一个成熟的(full-fledged)块设备，需要整个文件系统开销
- ``initrd`` 是一个固定大小块设备，所以:

  - 选择initrd不能太小，否则无法容纳所有需要的脚本
  - 但是选择太大的initrd会浪费内存

由于 ``initrd`` 是一个真正的静态设备，它会消耗Linux内核中的缓存内存，并且容易受到所使用的内存和文件管理方法（例如分页）的影响，这使得initrd的内存消耗更大。

为了解决上述问题而创建了 ``initramfs``

初始化ram文件系统
====================

initramfs 是基于 tmpfs（一种大小灵活的内存轻量级文件系统）的初始 ram 文件系统:

- 没哟使用单独的块设备(因此没有进行缓存，也就没有上述 ``initrd`` 的开销)
- 和 ``initrd`` 一样， ``initramfs`` 包哈了init挂载文件系统的所有工具和脚本
- initramfs的内容是通过创建 cpio 归档来制作的:

  - cpio是类似tar的文件归档程序，选择cpio的原因是cpio更容易实现，并且支持tar当时不支持的设备文件。
  - 所有文件、工具、库、配置文件都放入cpio归档中，然后使用gzip压缩后与内核一起存储
  - 引导加载程序在引导时会把initrafms的上述归档文件传递给内核，此时Linux内核就会创建一个 ``tmpfs`` 文件系统，并提取 ``initramfs`` 归档内容，然后启动位于该tmpfs文件系统根目录中的 ``init`` 脚本
  - 最后该脚本会挂载真正的根文件系统(通过加载附加模块以及加密抽象层等)以及重要的其他文件系统(如 /usr 和 /var)
  - 一旦安装了根文件系统和其他重要文件系统， ``initramfs`` 中的 ``init`` 脚本就会将根切换到真正的根文件系统，并最终调用该系统上的 ``/sbin/init`` 二进制文件以便继续引导过程。

创建initramfs
================

**创建initramfs之前，需要了解哪些是启动系统必要的驱动，脚本以及工具。**

举例，如果系统使用了 :ref:`linux_lvm` ，就需要在 ``initramfs`` 中添加 ``LVM`` 工具；如果系统使用了 :ref:`linux_software_raid` ，就应该在 ``initramfs`` 中加入 ``mdadm`` 工具；依次类推，对于 :ref:`zfs` 和 :ref:`btrfs` 也需要对应的工具。

一些自动化工具可以帮助创建 ``initramfs`` ，通常可以使用 :ref:`dracut` 和 :ref:`gentoo_genkernel` 。

在创建了 ``initramfs`` 镜像之后，需要修订 GRUB ( :ref:`gentoo_grub` / :ref:`ubuntu_grub` / :ref:`grubby` )，通知内核使用 ``initramfs`` ，配置举例如下:

.. literalinclude:: ../../linux/gentoo_linux/gentoo_grub/grub.cfg
   :caption: Gentoo Linux ``mkconfig`` 生成配置片段举例
   :emphasize-lines: 12,14

使用genkernel
--------------------

:ref:`gentoo_genkernel` 是 :ref:`gentoo_linux` 发行版特有的内核构建工具，可以使用 :ref:`genkernel_initramfs` :

.. literalinclude:: ../../linux/gentoo_linux/gentoo_genkernel/genkernel_initramfs
   :caption: 使用 ``genkernel`` 工具构建 :ref:`initramfs`

:ref:`gentoo_genkernel` 工具默认是期望内核和 ``initramfs`` 都由 ``genkernel`` 工具生成，所以不建议采用内核由其他方法构建，而 ``initramfs`` 由 ``genkernel`` 构建(虽然也可能工作)。

此外 ``genkernel`` 提供了一些参数可以增加一些驱动支持到 ``initramfs`` :

- ``--firmware`` 添加系统中找到的firmware
- ``--gpg`` 添加GnuPG支持
- ``--iscsi`` 添加iSCSI支持
- ``--lvm`` 添加 :ref:`linux_lvm` 支持
- ``--mdadm`` 添加 :ref:`linux_software_raid` 支持
- ``--multipath`` 添加用于SAN存储的multiple I/O访问支持
- ``-zfs`` 添加 :ref:`zfs` 支持

使用dracut
==============

:ref:`dracut` 工具是用于管理 ``initramfs`` 文件常用软件:



.. _lsinitramfs:

lsinitramfs
==============


参考
=====

- `gentoo linux wiki: initramfs <https://wiki.gentoo.org/wiki/Initramfs>`_
- `gentoo linux wiki: Initramfs - make your own <https://wiki.gentoo.org/wiki/Initramfs_-_make_your_own>`_
- `gentoo linux wiki: Initramfs/Guide <https://wiki.gentoo.org/wiki/Initramfs/Guide>`_
- `Debian Linux Kernel Handbook / Chapter 7. Managing the initial ramfs (initramfs) archive <https://kernel-team.pages.debian.net/kernel-handbook/ch-initramfs.html>`_
- `What’s the Difference Between initrd and initramfs? <https://www.baeldung.com/linux/initrd-vs-initramfs>`_
- `How to uncompress and list an initramfs content on Linux <https://linuxconfig.org/how-to-uncompress-and-list-an-initramfs-content-on-linux>`_
- `Ramfs, rootfs and initramfs <https://www.kernel.org/doc/html/latest/filesystems/ramfs-rootfs-initramfs.html>`_
