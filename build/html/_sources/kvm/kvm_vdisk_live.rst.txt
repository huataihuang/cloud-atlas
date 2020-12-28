.. _kvm_vdisk_live:

================================
KVM虚拟机动态添加、调整磁盘
================================

.. note::

   通过组合合适的VM文件系统功能（例如支持在线resize的XFS文件系统）和QEMU底层 ``virsh qemu-monitor-command`` 指令可以实现在线动态调整虚拟机磁盘容量，无需停机，对维护在线应用非常方便。不过，这里虚拟机磁盘扩容（resize）部分步骤需要在VM内部使用操作系统命令，所以适合自建自用的测试环境。
   
   生产环境reize虚拟机磁盘系统，可采用 `libguestfs <http://libguestfs.org/>`_ 来修改虚拟机磁盘镜像。 ``libguestfs`` 可以查看和编辑guest内部文件，脚本化修改VM，监控磁盘使用和空闲状态，以及创建虚拟机，P2V,V2V，以及备份，clone虚拟机，构建虚拟机，格式化磁盘，resize磁盘等等。详细请参考 :ref:`kvm_vdisk_live`

创建虚拟机磁盘
====================

.. note::

   我的这个案例实践是为了在 :ref:`suse_linux` 完成 :ref:`build_gluser_suse` ：由于生产环境使用了非常古老的SLES 12 SP3，需要构建一个虚拟机环境来编译GlusterFS。由于编译环境需要安装SDK等iso环境软件包，我采用为虚拟机挂载一块独立磁盘来存储iso镜像。

   磁盘初始化时候设置5G，显然这不够存储多个iso镜像。我在这里会演示如何动态扩展虚拟机磁盘。

- 创建虚拟机磁盘(qcow2类型)::

   cd /var/lib/libvirt/images
   qemu-img create -f qcow2 sles12_data.qcow2 5G

提示信息::

   Formatting 'sles12_data.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=5368709120 lazy_refcounts=off refcount_bits=16

可以看到qcow2格式化磁盘是zlib压缩，并且一闪而过完成。此时使用 ``ls -lh`` 检查可以看到磁盘仅仅占用数百K::

   -rw-r--r-- 1 root   root 193K Dec 27 17:12 sles12_data.qcow2

- 登陆到 ``sles12-sp3`` 虚拟机( 这个虚拟机采用了 :ref:`libvirt_bridged_network` 分配了 :ref:`studio_ip` ``192.168.6.201`` )，在虚拟机内部执行以下命令检查磁盘设备::

   lsblk

输出可以看到，当前仅有一块虚拟磁盘::

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sr0     11:0    1 1024M  0 rom
   vda    253:0    0   16G  0 disk
   ├─vda1 253:1    0    2G  0 part [SWAP]
   └─vda2 253:2    0   14G  0 part /var/cache

.. note::

   :ref:`suse_linux` 默认使用了 :ref:`btrfs` ，这是一种非常先进的集成了卷管理和文件系统的存储。在FaceBook公司内部得到广泛使用。

- 虚拟机支持磁盘文件动态添加，不需要停止虚拟机或者重启::

   virsh attach-disk sles12-sp3 --source /var/lib/libvirt/images/sles12_data.qcow2 --target vdb --persistent --driver qemu --subdriver qcow2

.. note::

   由于 ``libvirtd`` 出于安全因素默认关闭了虚拟磁盘类型自动检测功能，并且默认使用的 ``raw`` 磁盘格式，所以如果不指定磁盘驱动类型会导致添加的虚拟磁盘被是被成 ``raw`` 格式，就会在虚拟机内部看到非常奇怪的极小容量的磁盘。为了避免这个问题，所以一定要明确指定 ``--driver qemu --subdriver qcow2`` 。

如果虚拟磁盘插入正确，可以看到终端返回信息 ``Disk attached successfully`` ，此时在虚拟机内部再次使用 ``lsblk`` 命令检查输出如下::

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   sr0     11:0    1 1024M  0 rom
   vda    253:0    0   16G  0 disk
   ├─vda1 253:1    0    2G  0 part [SWAP]
   └─vda2 253:2    0   14G  0 part /var/cache
   vdb    253:16   0    5G  0 disk

可以看到虚拟机新增加了一块 ``vdb`` 磁盘。

动态扩容
===========

- 在虚拟机 ``sles12-sp3`` 中格式化并挂载XFS文件系统::

   mkfs.xfs /dev/vdb
   mkdir /data
   echo "/dev/vdb /data xfs defaults 0 0" >> /etc/fstab
   mount /data

- 完成上述挂载之后，复制iso文件到虚拟机的 ``/data/iso`` 目录下 ``ls -lh /data/iso/`` ::

   -rwxr-xr-x 1 huatai users 3.6G Dec 27 17:47 SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso 

此时，刚才5G空间的 ``/dev/vdb`` 挂载目录 ``/data`` 显示空间已使用73%，仅剩下1.4G空间，不足以复制SDK的iso镜像。所以，我们下一步开始在线扩容。

- 在物理主机(host主机)上使用使用 ``qemu-img resize`` 命令调整虚拟机磁盘大小::

   qemu-img resize /var/lib/libvirt/images/sles12_data.qcow2 +10G

但是 ``qemu-img`` 命令显然不能在线调整磁盘大小(虚拟关闭则可以执行)，出现报错::

   qemu-img: Could not open '/var/lib/libvirt/images/sles12_data.qcow2': Failed to get "write" lock
   Is another process using the image [/var/lib/libvirt/images/sles12_data.qcow2]?

- 检查虚拟机的块设备列表::

   virsh domblklist

显示输出::

    Target   Source
   -----------------------------------------------------
    vda      /var/lib/libvirt/images/sles12-sp3.qcow2
    vdb      /var/lib/libvirt/images/sles12_data.qcow2
    sda      -

- ``virsh blockresize`` 命令支持在线调整虚拟镜像，实际是通过底层 :ref:`qemu_monitor` 指令实现::

   virsh blockresize sles12-sp3 vdb --size 15G

提示信息::

   Block device 'vdb' is resized

- 此时在虚拟机 ``sles12-sp3`` 内部执行 ``lsblk`` 命令可以看到原先5G磁盘改成了15G::

   NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
   ...
   vdb    253:16   0   15G  0 disk /data

注意，此时文件系统显示挂载的磁盘还是5G空间::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   /dev/vdb        5.0G  3.7G  1.4G  73% /data

.. note::

   对于最新的Guest内核， ``virtio-blk`` 设备大小是自动更新的，所以会马上看到容量改变。对于旧内核需要重启guest系统。对于SCSI设备，需要在guest操作系统中触发一次扫描::

      echo > /sys/class/scsi_device/0:0:0:0/device/rescan

   对于IDE设备，则需要重启一次guest操作系统才能刷新。

- XFS文件系统支持在线调整::

   xfs_growfs /data

输出信息::

   meta-data=/dev/vdb               isize=256    agcount=4, agsize=327680 blks
            =                       sectsz=512   attr=2, projid32bit=1
            =                       crc=0        finobt=0 spinodes=0
   data     =                       bsize=4096   blocks=1310720, imaxpct=25
            =                       sunit=0      swidth=0 blks
   naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
   log      =internal               bsize=4096   blocks=2560, version=2
            =                       sectsz=512   sunit=0 blks, lazy-count=1
   realtime =none                   extsz=4096   blocks=0, rtextents=0
   data blocks changed from 1310720 to 3932160

可以看到最后一行信息显示XFS文件系统块增长。

通过 ``df -h`` 可以验证文件系统已经增大到15G::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   /dev/vdb         15G  3.7G   12G  25% /data

- 并且我们可以验证在文件系统挂载目录 ``/data/iso`` 目录下原文件依然存在，并且可以复制新的文件到扩容后的文件系统中。
