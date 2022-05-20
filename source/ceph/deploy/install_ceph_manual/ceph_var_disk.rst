.. _ceph_var_disk:

================================
``/var/lib/ceph`` 目录独立存储
================================

我在运维了一段时间Ceph存储，发现 :ref:`warn_mon_disk_low` 线上Ceph ``MON_DISK_LOW`` 。这个问题在于虚拟机初始分配存储空间极小(为了节约磁盘)，而Ceph在运行时需要确保 ``/var/lib/ceph`` 运行目录有足够空间，所以会不断检测该目录所在磁盘剩余空间百分比。如果没有特别配置， ``/var/lib/ceph``
实际上占用的是根文件系统空间，初始配置根磁盘空间不足就会带来上述告警。

在部署 :ref:`zdata_ceph` ，运行 :ref:`kvm` 虚拟机采用的是物理主机 :ref:`hpe_dl360_gen9` 的系统磁盘 ``/dev/sda`` 上划分 :ref:`linux_lvm` 实现的 :ref:`libvirt_lvm_pool` 。所以，要为虚拟机添加一个独立磁盘，就可以将上述 ``/var/lib/ceph`` 完整迁移过去

虚拟机独立磁盘添加
======================

- 首先检查 ``zcloud`` 物理主机上已经构建的虚拟机存储卷::

   lvs

注意，是部分基础虚拟机(也就是物理服务器一起动就必须运行的虚拟机，如提供其他虚拟机作为存储使用的 ceph 存储服务器 ``z-b-data-X`` )使用了物理服务器 ``zcloud`` 上的 :ref:`linux_lvm` ::

   LV         VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   z-b-data-1 vg-libvirt -wi-ao----  6.00g
   z-b-data-2 vg-libvirt -wi-ao----  6.00g
   z-b-data-3 vg-libvirt -wi-ao----  6.00g
   z-b-mon-1  vg-libvirt -wi-ao----  6.00g
   z-b-mon-2  vg-libvirt -wi-ao----  6.00g
   z-dev      vg-libvirt -wi-ao---- 16.00g
   z-fedora35 vg-libvirt -wi-a-----  6.00g
   z-iommu-2  vg-libvirt -wi-a-----  6.00g
   z-ubuntu20 vg-libvirt -wi-a-----  6.00g
   z-udev     vg-libvirt -wi-ao---- 16.00g
   z-vgpu     vg-libvirt -wi-a-----  6.00g 

- 在 :ref:`libvirt_lvm_pool` 上为每个 ``z-b-data-X`` 添加一个对应LVM卷，例如 ``z-b-data-1`` 添加 ``z-b-data-1_ceph`` ， ``z-b-data-2`` 添加 ``z-b-data-2_ceph`` 以此类推。注意，这个lvm卷采用 ``virsh`` 的内置命令 ``vol-create-as`` 来构建，而不是直接使用LVM的 ``lvcrete`` 创建，这样可以省却导入libvirt存储池的繁琐步骤::

   virsh vol-create-as images_lvm z-b-data-1_ceph 2G

再次使用 ``lvs`` 命令检查可以看到::

   LV              VG         Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
   z-b-data-1      vg-libvirt -wi-ao----  6.00g
   z-b-data-1_ceph vg-libvirt -wi-a-----  2.00g
   ...

- 创建虚拟机磁盘设备XML文件

.. literalinclude:: ceph_var_disk/z-b-data-1-disk.xml
   :language: xml
   :linenos:
   :caption: z-b-data-1虚拟机的磁盘XML文件

- 执行以下命令添加磁盘::

   virsh attach-device z-b-data-1 z-b-data-1-disk.xml --live --config

如果添加磁盘时出现报错 ``error: internal error: No more available PCI slots`` 则参考 :ref:`libvirt_network_pool_sr-iov` 去掉 ``--live`` 参数，采用只修改配置，然后重启虚拟机生效

- 由于我有多个虚拟机需要按照上述方法配置，所以我采用了 :ref:`prepare_z-k8s` 相似的脚本来实现创建数据磁盘，并添加到对应的虚拟机中:

.. literalinclude:: ceph_var_disk/vm-disk.sh
   :language: bash
   :linenos:
   :caption: 创建VM的数据磁盘并添加到虚拟机

这样就只需要简单运行3次命令就完成整个操作::

   ./vm-disk.sh z-b-data-1
   ./vm-disk.sh z-b-data-2
   ./vm-disk.sh z-b-data-3

Ceph的var目录迁移
==================

重启虚拟机之后，可以看到每个Ceph虚拟机都有一个 ``vdb`` 虚拟磁盘 ``fdisk -l`` ::

   Disk /dev/vdb: 2 GiB, 2147483648 bytes, 4194304 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes

.. warning::

   以下操作需要停止Ceph工作节点的ceph相关服务，并且迁移 ``/var/lib/ceph`` 目录，所以务必顺序操作，即完成一台服务器改造之后，恢复服务，确保 Ceph 集群运行正常。然后才可以操作下一个节点。这是通过Ceph分布式存储的容灾特性完成节点轮转维护，但是不可同时对多个节点操作，否则会导致数据故障。


.. note::

   以下操作在每台Ceph节点进行，操作步骤一致

- 对 ``/dev/vdb`` 进行 :ref:`parted` 分区和 采用 :ref:`xfs_startup` 相同方式格式化::

   parted -s /dev/vdb mklabel gpt
   parted -s -a optimal /dev/vdb mkpart primary 0% 100%

   mkfs.xfs /dev/vdb1

检查磁盘::

   lsblk

可以看到::

   ...
   vdb             252:16   0     2G  0 disk
   └─vdb1          252:17   0     2G  0 part

::

   blkid /dev/vdb1

显示::

   /dev/vdb1: UUID="19e78fd8-b59e-4d7b-850e-c75c95d3480a" TYPE="xfs" PARTLABEL="primary" PARTUUID="336ab957-8755-49b5-b877-ba42121bff2a"

- 停止 ``mds/osd/mgr/mon`` 服务进程 以及 ``crash`` 服务(搜集crash dump)::

   sudo systemctl stop ceph-crash
   sudo systemctl stop ceph-mds@`hostname`
   sudo systemctl stop ceph-osd@`hostname`
   sudo systemctl stop ceph-mgr@`hostname`
   sudo systemctl stop ceph-mon@`hostname`

- 检查进程::

   ps aux | grep ceph

发现还有一个osd进程存在::

   ceph         614  6.0  5.2 1839792 858080 ?      Ssl  00:18  15:17 /usr/bin/ceph-osd -f --cluster ceph --id 0 --setuser ceph --setgroup ceph

杀掉该进程::

   kill 614

- 检查集群::

   ceph status

此时显示有一个节点宕机::

   cluster:
     id:     0e6c8b6f-0d32-4cdb-a45d-85f8c7997c17
     health: HEALTH_WARN
             no active mgr
             1/3 mons down, quorum z-b-data-2,z-b-data-3
             1 osds down
             1 host (1 osds) down

   services:
     mon: 3 daemons, quorum z-b-data-2,z-b-data-3 (age 2m), out of quorum: z-b-data-1
     mgr: no daemons active (since 2m)
     mds:  2 up:standby
     osd: 3 osds: 2 up (since 90s), 3 in (since 5M)

   data:
     pools:   2 pools, 33 pgs
     objects: 19.70k objects, 76 GiB
     usage:   226 GiB used, 1.1 TiB / 1.4 TiB avail
     pgs:     33 active+clean

   io:
     client:   0 B/s rd, 221 KiB/s wr, 0 op/s rd, 48 op/s wr

- 检查确认没有任何访问 ``/var/lib/ceph`` 的进程::

   lsof | grep ceph

- 不过，既然是分布式系统，单个节点宕机不影响系统。我们可以通过检查 :ref:`zdata_ceph_rbd_libvirt` 确认所有虚拟机都运行正常 - 例如，在一台虚拟机内部运行 ``apt upgrade`` 更新系统，确认所有工作都正常

- 将 ``/var/lib/ceph`` 目录重命名为 ``/var/lib/ceph.bak`` ::

   sudo mv /var/lib/ceph /var/lib/ceph.bak

需要注意， ``/var/lib/ceph`` 目录的原始属主特性::

   drwxr-x--- 14 ceph ceph 207 Dec  1 15:57 ceph

- 创建 ``/var/lib/ceph`` 目录，然后将前面格式化过的 ``/dev/vdb`` 挂载到该目录::

   sudo mkdir /var/lib/ceph

   vdbid=`blkid /dev/vdb1 | awk '{print $2}'`
   echo "$vdbid /var/lib/ceph    xfs    defaults   0 0" >> /etc/fstab
   mount /var/lib/ceph

   sudo chmod 750 /var/lib/ceph
   sudo chown ceph:ceph /var/lib/ceph

- 将完整的 ``/var/lib/ceph`` 恢复::

   (cd /var/lib/ceph.bak && tar cf - .)|(cd /var/lib/ceph && tar xf -)

- 恢复服务::
   
   sudo systemctl start ceph-mon@`hostname`
   sudo systemctl start ceph-mgr@`hostname`
   sudo systemctl start ceph-osd@`hostname`
   sudo systemctl start ceph-mds@`hostname`
   sudo systemctl start ceph-crash

我在启动 ``ceph-osd@`hostname``` 遇到报错::

   Active: failed (Result: exit-code) since Fri 2022-05-20 05:31:45 CST; 2min 3s ago
   Process: 2000 ExecStartPre=/usr/lib/ceph/ceph-osd-prestart.sh --cluster ${CLUSTER} --id z-b-data-1 (code=exited, status=1/FAILURE)

检查发现，原来之前虽然 ``kill 614`` 杀死了 ``osd`` 进程，但是，osd的 ``tmpfs`` 依然挂载(已经被移动到 ``/var/lib/ceph.bak`` ，所以 ``df -h`` 显示::

   tmpfs           7.9G   28K  7.9G   1% /var/lib/ceph.bak/osd/ceph-0

最终我采用重启系统恢复
