.. _btrfs_in_studio:

=======================
Studio环境的Btrfs存储
=======================

.. note::

   Btrfs实践是在Ubuntu和Arch Linux完成，本文在涉及不同操作系统时会指出区别，并综合两者的文档。

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
   
   但是参考Docker官方文档，解决方案有所不同，所以实际操作请参考 :ref:`docker_btrfs` 进行。

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
