.. _ceph_docker_in_studio:

===============================
Stuido环境Docker容器运行Ceph
===============================

在 :ref:`cloud_atlas` 中，我说过要构建一个 :ref:`introduce_my_studio` ，其中很重要的一个基础设施就是分布式云存储。

分布式存储需要在集群中运行（虽然也有单机版运行demo），比较简单的方法是在host主机运行多个KVM虚拟机或者Virtualbox虚拟机，例如，很多Ceph的手册或书籍，在教学阶段都是建议在虚拟机内部运行Ceph模拟集群。然而，我认为这种方式有以下不足：

- KVM/Virtualbox这样的完全虚拟化对性能消耗较大，原本分布式存储由于复杂的结构性能就不如直连的本地存储，通过虚拟化运行效率更低。由于需要运行集群，累加的虚拟化开销浪费了原本性能有限的笔记本电脑硬件资源。
- KVM/Virtualbox虚拟机启动缓慢，需要非常小心地确保Ceph集群完全就绪之后才能进一步启动使用Ceph存储的KVM虚拟机或OpenStack，非常笨拙。

我需要一种类似直接在物理硬件上运行的分布式存储，（在物理硬件支持范围内）高性能并且运行维护简洁，所以考虑通过Docker运行Ceph：

- 启动迅速，除了资源隔离之外，几乎和纯物理硬件直接运行Ceph相差无几
- 类似物理底层，对于KVM/OpenStack完全透明，可以确保KVM/OpenStack需要分布式存储访问时随时就绪

大多数网上介绍的Ceph+Docker都是指将Ceph在物理服务器上运行服务，在Docker Host主机上在Host OS层挂载Ceph RBD块存储，在Ceph RBD块存储上创建文件系统。然后有两种方式使用Ceph分布式存储：

- 将Docker的 :ref:`docker_storage_driver` 迁移到Ceph块存储上实现Docker容器运行在Ceph分布式存储上，这样可以实现计算节点本地硬盘极小化甚至无盘。
- 将 :ref:`docker_volume` 映射到Ceph块存储的文件系统目录，以便将持久化数据存储到Ceph分布式存储上，这样可以确保Docker容器中的业务数据高可用、高性能。

.. note::

   我采用的方案有些类似 Red Hat Ceph企业存储解决方案中的 `Red Hat Ceph Storage - Container Guide <https://access.redhat.com/documentation/en-us/red_hat_ceph_storage/3/html/container_guide/index>`_ 。不过，Red Hat 的企业级Ceph存储部署需要购买服务才能够安装部署。这份Container Guide文档写得不太清晰，采用Ansible自动部署，屏蔽了底层的细节，但是指明了一种可能的部署模式。

LVM卷
========

由于笔记本电脑只有一块硬盘，要部署Ceph集群，需要模拟出多块磁盘块设备给不同的Docker容器。所以，采用LVM卷管理方式来把磁盘的一个分区划分成5个块设备。

.. note::

   如果要简单化，也可以使用host主机的扩展分区，可以支持多个逻辑分区，同样也能通过 :ref:`docker_run_add_host_device` 方式映射到Docker容器内使用。

   详细的Linux LVM原理和操作请参考 `Linux卷管理 <https://github.com/huataihuang/cloud-atlas-draft/blob/master/os/linux/storage/device-mapper/lvm/linux_lvm.md>`_ 。

- 磁盘分区::

   sudo parted /dev/sda

分区情况如下::

   Partition Table: gpt
   Disk Flags:

   Number  Start   End     Size    File system  Name  Flags
   ...
   4      248GB   500GB   252GB                ceph  lvm

.. note::

   这里磁盘分区在最初 :ref:`btrfs_in_studio` 已经就绪，这里采用 ``parted`` 添加了LVM标签::

      set 4  lvm on

- 创建LVM物理卷::

   sudo pvcreate /dev/sda4

显示输出::

   Physical volume "/dev/sda4" successfully created.

- 检查扫描跨设备::

   sudo lvmdiskscan

显示::

     /dev/sda1 [     243.00 MiB]
     /dev/sda2 [      47.68 GiB]
     /dev/sda3 [    <183.05 GiB]
     /dev/sda4 [     234.95 GiB] LVM physical volume
     0 disks
     3 partitions
     0 LVM physical volume whole disks
     1 LVM physical volume

::

   sudo pvdisplay

显示::

     "/dev/sda4" is a new physical volume of "234.95 GiB"
     --- NEW Physical volume ---
     PV Name               /dev/sda4
     VG Name
     PV Size               234.95 GiB
     Allocatable           NO
     PE Size               0
     Total PE              0
     Free PE               0
     Allocated PE          0
     PV UUID               RIgbUv-4LFM-B0QH-b09T-RGH8-6iK4-zhW6R0

- 创建卷组::

   sudo vgcreate ceph /dev/sda4

显示输出::

     Volume group "ceph" successfully created

检查::

   sudo vgdisplay

输出::

  --- Volume group ---
  VG Name               ceph
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <234.95 GiB
  PE Size               4.00 MiB
  Total PE              60147
  Alloc PE / Size       0 / 0
  Free  PE / Size       60147 / <234.95 GiB
  VG UUID               NiV45E-45BE-c1gC-SobB-okrS-rQPT-dbcEUB

- 创建逻辑卷::

   sudo lvcreate --size 46.98G -n data1 ceph
   sudo lvcreate --size 46.98G -n data2 ceph
   sudo lvcreate --size 46.98G -n data3 ceph
   sudo lvcreate --size 46.98G -n data4 ceph
   sudo lvcreate --size 46.98G -n data5 ceph

使用 ``sudo lvdisplay`` 可以检查上述创建的存储设备，并且可以检查 ``/dev/mapper/`` 目录下构建的LVM块设备::

   ls -lh /dev/mapper/

显示输出::

   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data1 -> ../dm-0
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data2 -> ../dm-1
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data3 -> ../dm-2
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data4 -> ../dm-3
   lrwxrwxrwx 1 root root       7 4月  11 10:00 ceph-data5 -> ../dm-4

.. note::

   以上已经在Host主机上完成了LVM卷的配置，需要将这些LVM卷块设备映射到Docker容器中使用，这样可以直接在Ceph中使用 :ref:`bluestore` 。

Docker容器
=============

.. note

   作为基础服务运行的Docker容器，需要具备如下能力:

   - 即使 docker 服务升级也能保持容器持续运行，这需要设置 :ref:`keep_containers_alive_during_daemon_downtime` 的运行参数 ``live restore``
   - 物理服务器操作系统重启，在Docker服务启动时自动启动容器，以确保基础分布式文件系统可用，这需要设置 :ref:`start_containers_automatically` 的 ``docker run`` 运行参数 ``--restart always``

- 在 ``/etc/docker/daemon.json`` 中添加如下配置::

   {
      ...,
      "live-restore": true
   }

然后重新加载dacker服务 ``sudo systemctl reload docker`` 确保docker升级时容器可以持续运行。

- 参考 :ref:`docker_run_add_host_device` 执行以下指令批量创建5个容器::

   for i in {1..5};do
     docker run -itd --hostname ceph-$i --name ceph-$i -v data:/data \
         --net ceph-net --ip 172.18.0.1$i -p 221$i:22 --restart always \
         --device=/dev/mapper/ceph-data$i:/dev/xvdc local:ubuntu18.04-ssh
   done

.. note::

   启动5个 ``cepn-N`` 虚拟机，在每个虚拟机内部都具备了 ``/dev/xvdc`` 设备::

      brw-rw---- 1 root disk 253, 0 Apr 11 13:56 /dev/xvdc
