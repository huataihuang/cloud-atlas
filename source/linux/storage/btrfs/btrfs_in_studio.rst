.. _btrfs_in_studio:

=======================
Studio环境的Btrfs存储
=======================

我的Btrfs使用经验
===================

.. note::

   Btrfs实践是在Ubuntu和Arch Linux完成，本文在涉及不同操作系统时会指出区别，并综合两者的文档。

.. note::

   2019年，我在Arch Linux上实践 :ref:`using_btrfs_in_studio` 遇到运行Windows虚拟机间歇性hang的问题，推测和Btrfs开启了 ``zstd`` 压缩有关。因为之前在Ubuntu上部署btrfs使用了很长时间也没有遇到问题，但是这次系统报错::

      [Tue Oct  1 23:44:37 2019] BTRFS warning (device sda4): csum failed root 257 ino 293 off 15661608960 csum 0x445ced74 expected csum 0x2f7d82ec mirror 1
      [Tue Oct  1 23:44:38 2019] BTRFS warning (device sda4): csum failed root 257 ino 293 off 15661608960 csum 0x445ced74 expected csum 0x2f7d82ec mirror 1

   另外一个现象是在 ``/var/lib/libvirt/images`` 目录下压缩30G大小Windows镜像，压缩非常缓慢远超过1小时，并且压缩文件解压缩以后，Wiondows虚拟机运行时显示磁盘文件系统损坏，自动修复依然失败。
   
   复制报错::

      cp: error reading 'win10.qcow2': Input/output error

   执行vm clone报错::

      ERROR    Couldn't create storage volume 'win10.qcow2': 'internal error: Child process (/usr/bin/qemu-img convert -f qcow2 -O qcow2 -o compat=1.1,lazy_refcounts /data-libvirt/images/win10.qcow2 /var/lib/libvirt/images/win10.qcow2) unexpected exit status 1: qemu-img: error while reading sector 13647872: Input/output error

   我当时以为是Btrfs的软件缺陷，但是我现在回顾 :ref:`btrfs_facebook` ，原文提到btrfs对系统负载较大，容易暴露CPU问题。对比之下，回想起来感觉当时是存储硬件故障的可能性比较大。

   因为我在2022年初时候尝试将闲置许久的这台笔记本重装macOS，就发现macOS安装时存储SMART检测无法通过，macOS拒绝安装操作系统。这说明当初 ``btrfs`` 报错可能已经是MacBook笔记本存储逐渐出现硬件劣化的征兆了。所以上文对压缩算法的评估，我现在认为很可能是不准确的。

Btrfs的多次实践
================

我在2019年10月1日的btrfs系统中发现了异常虚拟机hang以及btrfs读写错误(推测是硬件隐患故障)，转眼已过去2年。2021年，我重新在 :ref:`hpe_dl360_gen9` 上部署了 :ref:`ubuntu_linux` 来运行虚拟化 :ref:`kvm` ，存储再次选择 Btrfs 。我期望能够验证和充分发挥系统性能

2022年11月，我在 :ref:`mobile_cloud` 选择 :ref:`asahi_linux` ，:ref:`archlinux_zfs-dkms_arm` 遇到内核版本和zfs不兼容问题，所以再次采用 :ref:`btrfs_mobile_cloud` 。

初始安装操作系统的磁盘
=========================

在初始化安装的Ubuntu操作系统，磁盘分区如下::

   Disk /dev/sda: 476.96 GiB, 512110190592 bytes, 1000215216 sectors
   Disk model: INTEL SSDSC2KW51
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: gpt
   Disk identifier: 9AA02658-A444-4DE6-8DEE-8978DA2F02B6
   
   Device     Start      End  Sectors Size Type
   /dev/sda1   2048     4095     2048   1M BIOS boot
   /dev/sda2   4096 67112959 67108864  32G Linux filesystem

物理主机是500GB的SSD，目前划分给操作系统占用32GB。

由于物理主机将同时运行KVM和Docker，所以需要给 ``/var/lib/libvirt`` 和 ``/var/lib/docker`` 巨大的容量空间以存储虚拟机和容器镜像。

在Linux平台，具有伸缩性的文件系统，我选择采用btrfs：

- 结合了LVM和上层文件系统，实现了类似ZFS的功能
- 每个卷只是逻辑划分，所以整体上共享整个磁盘空间，这样就不需要为每个卷折腾空间大小规划了

.. warning::

   `Btrfs <https://btrfs.wiki.kernel.org/index.php/Main_Page>`_ 是现代的copy-on-write的文件系统，提供了很多针对失效容忍、修复和易于管理的高级特性。但是，btrfs的稳定性需要关注 `btrfs status <https://btrfs.wiki.kernel.org/index.php/Status>`_ ，确保采用符合自己需求和稳定性的功能。

Btrfs工具
=============

- Ubuntu安装Btrfs工具 ``btrfs-progs`` （在RHEL/CentOS中名为 ``btrfs-tools`` 软件包)::

   apt install btrfs-progs

- Arch Linux的软件包同名，安装命令如下::

   pacman -S btrfs-progs

加载btrfs模块::

   modprobe btrfs

- 在 Ubuntu 20.04.3 LTS 服务器版本，默认已经安装了 ``btrfs-progs`` 并且加载了内核模块::

   lsmod | grep btrfs

可以看到内核加载了 ``zstd_compress`` ::

   btrfs                1257472  0
   zstd_compress         167936  1 btrfs
   xor                    24576  2 async_xor,btrfs
   raid6_pq              114688  4 async_pq,btrfs,raid456,async_raid6_recov
   libcrc32c              16384  4 nf_conntrack,nf_nat,btrfs,raid456

磁盘分区
=============

.. note::

   当前 :ref:`hpe_dl360_gen9` 只安装了一块 SATA SSD磁盘，由于 :ref:`docker_btrfs_driver` 要求独立的块设备，所以我分别为 :ref:`docker` 划分一个分区:

   - ``/dev/sda3`` 挂载为docker使用的 ``/var/lib/docker``

   需要注意，libvirt官方并不支持使用 Btrfs 作为存储池，虽然我在实践中也采用过 Btrfs 的子卷存储镜像，但是我参考了一些资料，发现这个方式存在缺陷，详见 :ref:`introduce_btrfs`

使用 ``parted`` 创建 ``/dev/sda3`` 来构建btrfs::

   parted -a optimal /dev/sda

.. note::

   ``parted`` 提供了4k对齐优化（参考 `Create partition aligned using parted <https://unix.stackexchange.com/questions/38164/create-partition-aligned-using-parted>`_ ），使用参数 ``--align`` 或 ``-a`` 指定优化，一般可以使用 ``optimal`` 由parted自动处理对齐功能。

显示磁盘分区::

   GNU Parted 3.3
   Using /dev/sda
   Welcome to GNU Parted! Type 'help' to view a list of commands.
   (parted) print
   Model: ATA INTEL SSDSC2KW51 (scsi)
   Disk /dev/sda: 512GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:
   
   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  2097kB  1049kB                     bios_grub
    2      2097kB  34.4GB  34.4GB  ext4

增加分区3::

   mkpart primary btrfs 51.4GB 251GB

.. note::

   parted 命令格式 ``mkpart part-type fs-type start end``

   ``part-type`` 可以是 ``primary`` ``extended`` 或 ``logical`` ，但是这种分区类型只对MBR分区表有效。所以如果是GPT分区表，则使用 ``primary`` 只会将分区名字设置为 ``primary`` 类似如下::

      Number  Start   End     Size    File system  Name     Flags
       3      51.7GB  352GB   300GB   btrfs        primary

.. note::

   增加分区3作为btfs，用于存储Docker的镜像

.. note::

   最初我采用的 :ref:`using_btrfs_in_studio` 方式，将一个btrfs文件系统划分多个子卷分别提供给KVM，Docker和home存储。
   
   但是参考Docker官方文档，解决方案有所不同，所以实际操作请参考 :ref:`docker_btrfs_driver` 进行。

   现在本文是在 :ref:`thinkpad_x220` 的再次实践，结合了用于 Docker 的独立btrfs分区和用于数据存储/KVM虚拟机的btrfs分区。

增加分区4::

   mkpart primary btrfs 352GB 100%

.. note::

   在 分区4作为LVM卷，将再划分逻辑卷，用于构建Ceph存储的底层块设备()，采用BlueStore存储引擎。

对新增分区命名::

   name 3 docker
   name 4 data

.. note::

   上述2个新增分区是在 :ref:`archlinux_on_thinkpad_x220` 中使用docker(docker分区)和livirt+数据存储(data分区)。对于 :ref:`ubuntu_on_mbp` 则会将数据分区构建成LVM分区，以便实现 :ref:`ceph_docker_in_studio` 方案中采用LVM设备模拟docker中的存储设备，就可以单机运行基于 :ref:`bluestore` 的Ceph模拟集群。

磁盘分区完成后，检查结果::

   (parted) print
   Model: ATA INTEL SSDSC2KW51 (scsi)
   Disk /dev/sda: 512GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags: 
   
   Number  Start   End     Size    File system  Name    Flags
    1      1049kB  512MB   511MB   fat16                boot, esp
    2      512MB   51.7GB  51.2GB  ext4
    3      51.7GB  352GB   300GB   btrfs        docker
    4      352GB   512GB   160GB   btrfs        data

在初步完成了磁盘分区规划之后，我们现在有了可以用于btrfs的磁盘分区 ``/dev/sda3`` ，请参考 :ref:`configure_docker_btrfs` 完成Docker的btrfs存储引擎设置。如果你需要多种用途混合使用btrfs，也可以参考 :ref:`using_btrfs_in_studio` 。

参考
==========

- `ArchLinux Parted <https://wiki.archlinux.org/index.php/Parted>`_
- `ArchLinux Btrfs <https://wiki.archlinux.org/index.php/btrfs>`_
- `Create partition aligned using parted <https://unix.stackexchange.com/questions/38164/create-partition-aligned-using-parted>`_
