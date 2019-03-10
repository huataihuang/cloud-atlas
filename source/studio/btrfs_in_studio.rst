.. _btrfs_in_studio:

=======================
Studio环境的Btrfs存储
=======================

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

安装Btrfs工具 ``btrfs-progs`` （在RHEL/CentOS中名为 ``btrfs-tools`` 软件包)::

   apt install btrfs-progs

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
   Model: ATA APPLE SSD SM0512 (scsi)
   Disk /dev/sda: 500GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name  Flags
    1      1049kB  192MB   191MB   fat32              boot, esp
    2      192MB   51.4GB  51.2GB  ext4

增加分区3::

   mkpart primary 51.4GB 251GB

.. note::

   增加分区3作为btfs，用于直接存储KVM和Docker的镜像

增加分区4::

   mkpart primary 251GB 100%

.. note::

   增加分区4作为LVM卷，将再划分逻辑卷，用于构建Ceph存储的底层块设备，采用BlueStore存储引擎。

对新增分区命名::

   name 3 data
   name 4 ceph

磁盘分区完成后，检查结果::

   (parted) print
   Model: ATA APPLE SSD SM0512 (scsi)
   Disk /dev/sda: 500GB
   Sector size (logical/physical): 512B/4096B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name     Flags
    1      1049kB  192MB   191MB   fat32                 boot, esp
    2      192MB   51.4GB  51.2GB  ext4
    3      51.4GB  251GB   200GB                data
    4      251GB   500GB   249GB                ceph

Btrfs部署
================

- 采用的btrfs非常简单的卷，单盘。首先创建根卷 ``data`` ::

   mkfs.btrfs -L data /dev/sda3

显示输出::

   btrfs-progs v4.16.1
   See http://btrfs.wiki.kernel.org for more information.
   
   Detected a SSD, turning off metadata duplication.  Mkfs with -m dup if you want to force metadata duplication.
   Performing full device TRIM /dev/sda3 (185.90GiB) ...
   Label:              data
   UUID:               3a2963fe-eb55-4160-8f46-a1b3ead72f17
   Node size:          16384
   Sector size:        4096
   Filesystem size:    185.90GiB
   Block group profiles:
     Data:             single            8.00MiB
     Metadata:         single            8.00MiB
     System:           single            4.00MiB
   SSD detected:       yes
   Incompat features:  extref, skinny-metadata
   Number of devices:  1
   Devices:
      ID        SIZE  PATH
       1   185.90GiB  /dev/sda3

- 挂载btrfs的分区

设置 ``/etc/fstab`` ::

   /dev/sda3    /data    btrfs    defaults,compress=zstd   0    1

然后挂载磁盘分区::

   mkdir /data
   mount /data

.. note::

   参考 `Btrfs Zstd Compression Benchmarks On Linux 4.14 <https://www.phoronix.com/scan.php?page=article&item=btrfs-zstd-compress&num=4>`_ 采用 ``Zstd`` 压缩方式挂载btrfs，可以获得性能和压缩率的较好平衡。

- 创建btrfs的子卷，分别对应libvirt和docker

创建子卷::

   btrfs subvolume create /data/libvirt
   btrfs subvolume create /data/docker

检查子卷::

   btrfs subvolume list /data

显示输出::

   ID 257 gen 8 top level 5 path libvirt
   ID 258 gen 9 top level 5 path docker

.. note::

   需要将子卷挂载到 ``/lib/virt`` 下的子目录 ``libvirt`` 和 ``docker`` ，不过，先需要做数据迁移

libvirt和docker数据迁移到btrfs
====================================

.. note::

   详细可以参考 `使用Btrfs部署KVM <https://github.com/huataihuang/cloud-atlas-draft/blob/master/virtual/kvm/startup/in_action/deploy_kvm_using_btrfs.md>`_

- 停止libvirt和docker服务::

   systemctl stop libvirtd
   systemctl stop virtlogd.socket
   systemctl stop virtlogd-admin.socket
   systemctl stop virtlockd-admin.socket
   systemctl stop virtlockd.socket
   # 停止libvirt使用的dnsmasq
   ps aux | grep dnsmasq | grep -v grep | awk '{print $2}' |  sudo xargs kill
   
   systemctl stop docker

.. note::

   在做数据迁移之前，务必确保没有任何进程在访问 ``/var/lib/libvirt`` 和 ``/var/lib/docker`` 目录，以便能够移动和重新挂载这两个目录::

      lsof | grep libvirt
      lsof | grep docker

- 将源目录重命名::

   cd /var/lib
   mv libvirt libvirt.bak
   mv docker docker.bak

注意检查目录的属主和权限::

   drwx--x--x 15 root          root          4.0K 2月  26 22:59 docker.bak
   drwxr-xr-x  7 root          root          4.0K 2月  26 17:38 libvirt.bak

- 将btrfs子卷挂载到目标目录

创建目录::

   mkdir /var/lib/docker
   mkdir /var/lib/libvirt
   chmod 711 /var/lib/docker
   chmod 755 /var/lib/libvirt
   
修改 ``/etc/fstab``  添加::

   /dev/sda3    /var/lib/libvirt   btrfs  subvol=libvirt,defaults,noatime   0   1
   /dev/sda3    /var/lib/docker    btrfs  subvol=docker,defaults,noatime    0   1

挂载目录::

   mount /var/lib/libvirt
   mount /var/lib/docker

.. note::

   按照上述操作步骤，完整的 ``/etc/fstab`` 内容如下::

      /dev/sda3    /data    btrfs    defaults,compress=zstd   0    1
      /dev/sda3    /var/lib/libvirt   btrfs  subvol=libvirt,defaults,noatime   0   1
      /dev/sda3    /var/lib/docker    btrfs  subvol=docker,defaults,noatime    0   1
   
   最后挂载的 btrfs 文件系统内容如下::

      /dev/sda3       186G   17M  185G   1% /data
      /dev/sda3       186G   17M  185G   1% /var/lib/libvirt
      /dev/sda3       186G   17M  185G   1% /var/lib/docker

   可以看到btrfs的最大特点：存储容量是一个完整的"池"被各个存储卷共享，所以不需要担心某些卷预分配过多或锅烧。

- 数据迁移::

   rsync -a /var/lib/libvirt.bak/ /var/lib/libvirt/
   rsync -a /var/lib/docker.bak/ /var/lib/docker/

- 恢复服务::

   systemctl start libvirtd
   systemctl start docker

.. note::

   可以重启一次操作系统验证是否都工作正常。

其他btrfs卷(可选)
===================

由于常用的用户目录会存储较多的文件，也可以考虑迁移到btrfs中。这里把 ``/home`` 目录迁移

- 创建btrfs子卷home::

   btrfs subvolume create /data/home

检查创建的子卷::

   btrfs subvolume list /data

- 将 ``/home`` 目录重命名成 ``/home.bak`` ::

    mv /home /home.bak

- 修改 ``/etc/fstab`` 添加::

   /dev/sda3    /home              btrfs  subvol=home,defaults,noatime      0   1

- 创建并挂载 ``/home`` 目录::

   mkdir /home
   moutn /home

- 同步和恢复 ``/home`` 目录内容::

   rsync -a /home.bak/ /home/

参考
==========

- `ArchLinux Parted <https://wiki.archlinux.org/index.php/Parted>`_
- `ArchLinux Btrfs <https://wiki.archlinux.org/index.php/btrfs>`_
- `Create partition aligned using parted <https://unix.stackexchange.com/questions/38164/create-partition-aligned-using-parted>`_
