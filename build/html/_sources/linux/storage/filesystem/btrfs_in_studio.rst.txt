.. _btrfs_in_studio:

=======================
Studio环境的Btrfs存储
=======================

我的Btrfs使用经验
===================

.. note::

   Btrfs实践是在Ubuntu和Arch Linux完成，本文在涉及不同操作系统时会指出区别，并综合两者的文档。

.. warning::

   我在Arch Linux上实践 :ref:`using_btrfs_in_studio` 遇到运行Windows虚拟机间歇性hang的问题，推测和Btrfs开启了 ``zstd`` 压缩有关。因为之前在Ubuntu上部署btrfs使用了很长时间也没有遇到问题，但是这次系统报错::

      [Tue Oct  1 23:44:37 2019] BTRFS warning (device sda4): csum failed root 257 ino 293 off 15661608960 csum 0x445ced74 expected csum 0x2f7d82ec mirror 1
      [Tue Oct  1 23:44:38 2019] BTRFS warning (device sda4): csum failed root 257 ino 293 off 15661608960 csum 0x445ced74 expected csum 0x2f7d82ec mirror 1

   另外一个现象是在 ``/var/lib/libvirt/images`` 目录下压缩30G大小Windows镜像，压缩非常缓慢远超过1小时，并且压缩文件解压缩以后，Wiondows虚拟机运行时显示磁盘文件系统损坏，自动修复依然失败。
   
   复制报错::

      cp: error reading 'win10.qcow2': Input/output error

   执行vm clone报错::

      ERROR    Couldn't create storage volume 'win10.qcow2': 'internal error: Child process (/usr/bin/qemu-img convert -f qcow2 -O qcow2 -o compat=1.1,lazy_refcounts /data-libvirt/images/win10.qcow2 /var/lib/libvirt/images/win10.qcow2) unexpected exit status 1: qemu-img: error while reading sector 13647872: Input/output error

按照我的实践经验，btrfs的基本功能稳定，但是高级压缩功能可能存在风险。

Btrfs在不同发行版和厂商应用对比
=================================

Red Hat Enterprise Linux
---------------------------

参考 `Red Hat banishes Btrfs from RHEL <https://www.theregister.co.uk/2017/08/16/red_hat_banishes_btrfs_from_rhel>`_ 报道，Red Hat在RHEL 7.4还保持Btrfs上游补丁更新，但之后放弃了Btrfs功能更新。从 RHEL 8 `Considerations in adopting RHEL 8Chapter 12. File systems and storage <https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/considerations_in_adopting_rhel_8/file-systems-and-storage_considerations-in-adopting-rhel-8>`_ 可以看到Red Hat Enterprise Linux 8已经完全移除了Btrfs支持，已经不能在RHEL中创建、挂载和安装Btrfs文件系统。

Red Hat社区Fedora
--------------------

从 `Fedora 33重新引入Btrfs作为默认文件系统 <https://fedoramagazine.org/btrfs-coming-to-fedora-33/>`_ ，可以观察到Red Hat社区开始尝试在桌面系统引入Btrfs，今后有可能进入Red Hat服务器领域的话，则可以作为生产引入验证使用。

SUSE企业版Linux
-------------------

SUSE发行版一直以来都是将 Btrfs 作为服务器版默认文件系统。这应该和各个Linux发行版公司在开发力量投入上有关。

Facebook
--------------

根据网上信息了解，Facebook可能是最积极采用Btrfs的超级互联网公司，并且雇佣了Btrfs的核心开发者，也是能够在生产环境采用Btrfs高级特性并保证稳定性的底气。

Facebook使用Btrfs的快照和镜像来隔离容器，在 `Btrfs at Facebook(facebookmicrosites) <https://facebookmicrosites.github.io/btrfs/docs/btrfs-facebook.html>`_ 透露了F厂应用Btrfs遇到的问题和解决方案。同时在LWN源代码新闻网站， `Btrfs at Facebook(LWN) <https://lwn.net/Articles/824855/>`_ 记录了Btrfs开发 Josef Bacik 在 `2020 Open Source Summit North America <https://events.linuxfoundation.org/open-source-summit-north-america/>`_
演讲，介绍了Facebook利用Btrfs进行快速测试的隔离解决方案。

我的观点
---------

Btrfs和ZFS是目前Linux系统功能最丰富同时也是最具发展潜力的本地文件系统。两者各自有独特的发展历史和技术优势，当前都已经逐步进入稳定生产状态，比早期动辄crash已经不可同日而语。

Btrfs和ZFS需要非常精心的部署和调优，以充分发挥最佳性能，我决定后续做实践对比，进行性能优化和测试，并撰写应用方案。

建议保持持续跟进观察，并不断做性能和稳定性测试，在合适的时候正式采用Btrfs。

.. note::

   以下是我较早的一些实践笔记，不太完善，但是我今后会再次迭代改进。

初始安装操作系统的磁盘
=========================

在初始化安装的Ubuntu操作系统，磁盘分区如下::

   Disk /dev/sda: 465.9 GiB, 500277790720 bytes, 977105060 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 4096 bytes
   I/O size (minimum/optimal): 4096 bytes / 4096 bytes
   Disklabel type: gpt
   Disk identifier: F2FB6986-2DCE-46B4-907F-7F4D7D29E3B4

   Device      Start       End  Sectors  Size Type
   /dev/sda1    2048    374783   372736  182M EFI System
   /dev/sda2  374784 100374527 99999744 47.7G Linux filesystem

.. note::

   - ``/dev/sda1`` 是EFI分区，挂载在 ``/boot/efi`` 目录下，包含分区启动信息
   - ``/dev/sda2`` EXT4文件系统，挂载在 ``/`` 根目录下

   物理主机是500GB的SSD，目前安装操作系统占用了50GB。

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

Arch Linux的软件包同名，安装命令如下::

   pacman -S btrfs-progs

加载btrfs模块::

   modprobe btrfs

磁盘分区
=============

使用 ``parted`` 创建 ``/dev/sda3`` 来构建btrfs::

   parted -a optimal

.. note::

   ``parted`` 提供了4k对齐优化（参考 `Create partition aligned using parted <https://unix.stackexchange.com/questions/38164/create-partition-aligned-using-parted>`_ ），使用参数 ``--align`` 或 ``-a`` 指定优化，一般可以使用 ``optimal`` 由parted自动处理对齐功能。

显示磁盘分区::

   (parted) print
   Model: ATA INTEL SSDSC2KW51 (scsi)
   Disk /dev/sda: 512GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  512MB   511MB   fat16                 boot, esp
    2      512MB   51.7GB  51.2GB  ext4

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
