.. _deploy_simple_gluster:

=====================
部署简单GlusterFS集群
=====================

正如 :ref:`gluster_vs_ceph` 辨析，GlusterFS是在文件系统之上构建的分布式文件系统，所以 :ref:`linux_filesystem` 的构建会给GlusterFS带来更多的特性和功能。例如，结合卷管理可以实现快照。本文实践是快速部署一个简化版本的GlusterFS集群，在文件系统存储层采用直接基于磁盘设备创建XFS文件系统。这种简洁的文件系统虽然灵活性受到限制，但是架构简洁也使得出现错误的可能性降低。

服务器准备
=============

- 至少需要3台服务器组建稳定的GlusterFS集群(2台虽然也能构建，但是缺乏quotum容易导致脑裂)，在我的这个演示案例中，我采用6个KVM虚拟机(最初我以为奇数服务器可以构建更为稳定，但是参考 :ref:`gluster_split_brain_deal` 修正了方案)，目的是构建分布式多副本集群
- 每个虚拟机使用一个附加的 `/dev/vdb` 设备(见下文磁盘分区和文件系统构建)

环境准备
-----------

- 所有服务器节点的时间必须同步，所以，请安装并运行ntp客户端，当前主流推荐采用 chrony - `CentOS / RHEL 7 : Chrony V/s NTP (Differences Between ntpd and chronyd) <https://www.thegeekdiary.com/centos-rhel-7-chrony-vs-ntp-differences-between-ntpd-and-chronyd/>`_

- 所有服务器需要彼此能够DNS解析，所以建议采用统一的DNS服务器进行维护主机名解析，比较简化的方法是所有服务器采用一致的 ``/etc/hosts`` 提供静态主机名解析。

磁盘分区
-----------

- 使用 ``parted`` 对磁盘进行分区，分区vdb1占用250G(没有使用这个vdb是因为我还准备用vdb构建复杂的 :ref:`stratis` )::

   parted -a optimal /dev/vdb
   mklabel gpt
   unit GB
   mkpart primary 0 250
   name 1 gluster_brick1
   print

如果磁盘之前已经有分区表，但是分区表没有对齐，你没有执行 ``mklabel gpt`` 就执行 ``mkpart`` 就可能会提示磁盘分区从0开始对齐需要接近扇区，这个警告需要通过使用 ``-a optimal`` 参数来修正::

   Warning: You requested a partition from 0.00GB to 3840GB (sectors 0..7500000000).
   The closest location we can manage is 0.00GB to 0.00GB (sectors 34..2047).
   Is this still acceptable to you?
   Yes/No?

对于原先有分区的磁盘，覆盖原先的分区表，默认是会提示WARNING的，对于脚本执行命令，需要关闭提示，则使用参数 ``-s`` 表示 ``--script`` 就不会有提示了。举例::

   parted -s -a optimal /dev/vdb mklabel gpt
   parted -s -a optimal /dev/vdb mkpart primary 0% 100%
   parted -s -a optimal /dev/vdb name 1 gluster_brick1
   mkfs.xfs -f -i size=512 /dev/vdb1

此时显示分区信息::

   Model: Virtio Block Device (virtblk)
   Disk /dev/vdb: 537GB
   Sector size (logical/physical): 512B/512B
   Partition Table: gpt
   Disk Flags:

   Number  Start   End    Size   File system  Name           Flags
    1      0.00GB  250GB  250GB               gluster_brick1

退出parted::

   quit

- 使用lsblk检查磁盘设备::

   lsblk

输出显示::

   NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
   vda    253:0    0    40G  0 disk
   `-vda1 253:1    0    40G  0 part /
   vdb    253:16   0   500G  0 disk
   `-vdb1 253:17   0 232.9G  0 part

XFS文件系统
-------------

.. note::

   GlusterFS底层的XFS'文件系统根据不同的硬件(RAID条带化)或者存储的内容不同，可以采用不同的优化策略。我准备在 :ref:`xfs_performance` 做详细的测试和对比。这里仅做简化的配置，采用比较通用的参数。

   GlusterFS可以使用任何支持扩展属性的文件系统，例如XFS或者Ext4。

- 格式化bricks并挂载::

   mkfs.xfs -i size=512 /dev/vdb1
   mkdir -p /data/brick1
   echo '/dev/vdb1 /data/brick1 xfs defaults 1 2' >> /etc/fstab
   mount -a && mount

.. note::

   挂载XFS的参数建议: ``rw,inode64,noatime,nouuid`` 所以上述命令可以修改::

      echo '/dev/vdb1 /data/brick1 xfs rw,inode64,noatime,nouuid 1 2' >> /etc/fstab

   我对比了默认的 ``defaults`` 参数，实际上就是 ``rw,relatime,attr2,inode64,noquota`` ，则上述 ``rw,inode64,noatime,nouuid`` 实际效果仅仅是将默认的 ``relatime`` 修改成了 ``noatime``

此时可以看到 vdb1 挂载到 ``/data/brick1`` ::

   /dev/vdb1 on /data/brick1 type xfs (rw,relatime,attr2,inode64,noquota)

批量创建文件系统脚本
----------------------

服务器有多块nvme磁盘，从 ``/dev/nvme0n1`` 到 ``/dev/nvme11n1`` 共计12块磁盘，则采用如下脚本快速完成格式化挂载::

   for i in {0..11};do
       if [ ! -d /data/brick${i} ];then mkdir -p /data/brick${i};fi
       parted -s -a optimal /dev/nvme${i}n1 mklabel gpt
       parted -s -a optimal /dev/nvme${i}n1 mkpart primary xfs 0% 100%
       parted -s -a optimal /dev/nvme${i}n1 name 1 gluster_brick${i}
       sleep 1
       mkfs.xfs -f -i size=512 /dev/nvme${i}n1p1
       fstab_line=`grep "/dev/nvme${i}n1p1" /etc/fstab`
       if [ ! -n "$fstab_line"  ];then echo "/dev/nvme${i}n1p1 /data/brick${i} xfs rw,inode64,noatime,nouuid 1 2" >> /etc/fstab;fi
       mount /data/brick${i}
   done

安装GlusterFS
================

.. note::

   以前安装GlusterFS的方法是先下载repo仓库配置文件，例如 `glusterfs-rhel8.repo <https://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-rhel8.repo>`_ ::

      wget -P /etc/yum.repos.d  https://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-rhel8.repo

   也可以通过dnf命令管理::

      dnf config-manager --add-repo https://download.gluster.org/pub/gluster/glusterfs/LATEST/CentOS/glusterfs-rhel8.repo

- 现在CentOS已经把开源的多个存储项目集中到一个统一的 `CentOS Storage Special Interest Group (SIG) <https://wiki.centos.org/SpecialInterestGroup>`_ ，所以安装对应存储软件的软件仓库非常简单::

   yum install centos-release-gluster

- 激活PowerTools repo - 必须激活PowerTools软件仓库，否则安装 ``glusterfs-server`` 会提示报错 ``python3-pyxattr is needed by glusterfs-srver which is provded by powertools repo from centOS 8 so this also needs to be enabled`` ::

   dnf config-manager --set-enabled PowerTools

.. note::

   可以通过 ``dnf repolist all`` 检查可用的repo，并且通过上述命令激活需要的仓库。

- 安装GlusterFS::

   dnf install glusterfs-server

- 启动GlusterFS管理服务::

   systemctl start glusterd

- 检查服务状态::

   systemctl status glusterd

在CentOS 7上安装GlusterFS
---------------------------

如果在标准的CentOS 7上，当前也是可以直接使用 SIG Yum Repos进行安装的::

   yum install centos-release-gluster

然后安装方式同上。

不过，如果你的CentOS安装没有升级到最新版本，或者是采用了CentOS的自制版本，则需要独立分发仓库配置文件 ``/etc/yum.repos.d/CentOS-Gluster-7.repo`` 和软件包签名证书文件 ``/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage`` ，这两个文件分别是通过如下rpm包可以通过CentOS的发行版extras仓库获得::

   yum install http://mirrors.163.com/centos/7.8.2003/extras/x86_64/Packages/centos-release-gluster7-1.0-2.el7.centos.noarch.rpm
   yum install http://mirrors.163.com/centos/7.8.2003/extras/x86_64/Packages/centos-release-storage-common-2-2.el7.centos.noarch.rpm

.. note::

   centos-release-gluster7-1.0-2.el7.centos.noarch 要求 centos-release >= 7-5.1804.el7.centos.2


配置GlusterFS
=================

- 在第一台服务器上执行以下命令配置信任存储池，将7台服务器组成一个信任存储池::

   gluster peer probe worker2
   gluster peer probe worker3
   ...
   gluster peer probe worker7 #这里多加了一台服务器，实际应该剔除

- 然后检查peer status::

   gluster peer status

输出显示类似::

   Number of Peers: 6
   
   Hostname: worker2
   Uuid: 48350a85-3c2c-43f3-aca7-b99c7043d7af
   State: Peer in Cluster (Connected)
   
   Hostname: worker3
   Uuid: 96a821b3-6232-4b8b-99a6-830b4fd17110
   State: Peer in Cluster (Connected)
   ...
   Hostname: worker7
   Uuid: c9262857-7f56-4500-a2d4-5c81767a27cf
   State: Peer in Cluster (Connected)

设置GlusterFS卷
-----------------

- 在 **所有服务器** 上执行以下命令创建一个GlusterFS卷::

   mkdir -p /data/brick1/gv0

- 然后在 **任意一台服务器** 上执行创建卷命令::

   gluster volume create gv0 replica 3 \
      worker1:/data/brick1/gv0 \
      worker2:/data/brick1/gv0 \
      worker3:/data/brick1/gv0 \
      worker4:/data/brick1/gv0 \
      worker5:/data/brick1/gv0 \
      worker6:/data/brick1/gv0 \
      worker7:/data/brick1/gv0

这里报错::

   number of bricks is not a multiple of replica count

   Usage:
   volume create <NEW-VOLNAME> [stripe <COUNT>] [[replica <COUNT> [arbiter <COUNT>]]|[replica 2 thin-arbiter 1]] [disperse [<COUNT>]] [disperse-data <COUNT>] [redundancy <COUNT>] [transport <tcp|rdma|tcp,rdma>] <NEW-BRICK> <TA-BRICK>... [force]   

也就是说，要求bricks数量必须是replica数量的整数倍。

.. note::

   请参考 :ref:`gluster_split_brain_deal` 的实现原理：对于稳定的分布式文件系统，需要采用3副本(3 replicas)或者2副本+1个仲裁卷来确保客户端写入时能够根据quorum来判断集群的可用性，避免脑裂。

   不管怎样，每个文件的存储都需要3个卷来负责，所以构建brick的数量必须是3的倍数。

   如果你的资金有限(需要节约存储空间)，则可以采用2个数据卷+1个仲裁卷(仲裁卷可以大幅节约存储空间)；但是对于数据安全性要求较高的场景，依然建议采用3副本数据卷方案。

但是，需要注意需要把一个文件的多个副本存放到不同服务器上，就需要特别注意 **brick的顺序** 。正确的方式是首先依次列出所有服务器的第一个brick，然后再列出所有服务器的第二个brick，依次类推。这样GlusterFS才能正确把文件的副本存放到不同的服务器上。

.. note::

   如果你使用的是非常高端的多存储设备服务器，尤其需要在构建glusterfs时采用正确的gluster brick顺序，避免多副本数据都集中到少数服务器上导致无法容灾。

由于这里采用了错误的bricks数量(必须是3的整数倍)，所以我这里修订，剔除掉 ``worker7`` 节点::

   gluster peer detach worker7

此时提示::

   All clients mounted through the peer which is getting detached need to be remounted using one of the other active peers in the trusted storage pool to ensure client gets notification on any changes done on the gluster configuration and if the same has been done do you want to proceed? (y/n)

输入 ``y`` 剔除掉节点 ``worker7`` ，这样集群中只保留6个服务器节点，每个节点有一个 ``brick1`` 。

- 然后重新构建存储卷::

   gluster volume create gv0 replica 3 \
      worker1:/data/brick1/gv0 \
      worker2:/data/brick1/gv0 \
      worker3:/data/brick1/gv0 \
      worker4:/data/brick1/gv0 \
      worker5:/data/brick1/gv0 \
      worker6:/data/brick1/gv0

此时提示数据卷建立::

   volume create: gv0: success: please start the volume to access data

- 启动存储卷::

   gluster volume start gv0

提示信息::

   volume start: gv0: success

- 现在可以检查卷状态::

   gluster volume info

输出信息::

   Volume Name: gv0
   Type: Distributed-Replicate
   Volume ID: 5842afec-f6c9-4530-bc90-7f92705d3bdd
   Status: Started
   Snapshot Count: 0
   Number of Bricks: 2 x 3 = 6
   Transport-type: tcp
   Bricks:
   Brick1: worker1:/data/brick1/gv0
   Brick2: worker2:/data/brick1/gv0
   Brick3: worker3:/data/brick1/gv0
   Brick4: worker4:/data/brick1/gv0
   Brick5: worker5:/data/brick1/gv0
   Brick6: worker6:/data/brick1/gv0
   Options Reconfigured:
   transport.address-family: inet
   storage.fips-mode-rchecksum: on
   nfs.disable: on
   performance.client-io-threads: off

注意上述卷信息中需要显示状态 ``Status: Started`` ，如果状态不是启动状态，则需要检查 ``/var/log/glusterfs/glusterd.log`` 排查。

- 启动存储卷::

   gluster volume start gv0

提示信息::

   volume start: gv0: success

- 现在可以检查卷状态::

   gluster volume info

输出信息::

   Volume Name: gv0
   Type: Distributed-Replicate
   Volume ID: 5842afec-f6c9-4530-bc90-7f92705d3bdd
   Status: Started
   Snapshot Count: 0
   Number of Bricks: 2 x 3 = 6
   Transport-type: tcp
   Bricks:
   Brick1: worker1:/data/brick1/gv0
   Brick2: worker2:/data/brick1/gv0
   Brick3: worker3:/data/brick1/gv0
   Brick4: worker4:/data/brick1/gv0
   Brick5: worker5:/data/brick1/gv0
   Brick6: worker6:/data/brick1/gv0
   Options Reconfigured:
   transport.address-family: inet
   storage.fips-mode-rchecksum: on
   nfs.disable: on
   performance.client-io-threads: off

注意上述卷信息中需要显示状态 ``Status: Started`` ，如果状态不是启动状态，则需要检查 ``/var/log/glusterfs/glusterd.log`` 排查。

- 启动存储卷::

   gluster volume start gv0

提示信息::

   volume start: gv0: success

- 现在可以检查卷状态::

   gluster volume info

输出信息::

   Volume Name: gv0
   Type: Distributed-Replicate
   Volume ID: 5842afec-f6c9-4530-bc90-7f92705d3bdd
   Status: Started
   Snapshot Count: 0
   Number of Bricks: 2 x 3 = 6
   Transport-type: tcp
   Bricks:
   Brick1: worker1:/data/brick1/gv0
   Brick2: worker2:/data/brick1/gv0
   Brick3: worker3:/data/brick1/gv0
   Brick4: worker4:/data/brick1/gv0
   Brick5: worker5:/data/brick1/gv0
   Brick6: worker6:/data/brick1/gv0
   Options Reconfigured:
   transport.address-family: inet
   storage.fips-mode-rchecksum: on
   nfs.disable: on
   performance.client-io-threads: off

注意上述卷信息中需要显示状态 ``Status: Started`` ，如果状态不是启动状态，则需要检查 ``/var/log/glusterfs/glusterd.log`` 排查。

.. note::

   GlusterFS支持多种 :ref:`gluster_volume` ，通常对于生产环境，建议使用数据高可用的 ``Replicated`` 卷，或者 ``Distributed Replicated`` 卷。

   这里的案例指定 ``replica 3`` 也就是多副本卷，但是由于同时提供了多个3x数量的brick，所以就自然形成了分布式多副本卷( ``Distributed Replicated`` )。这种场景非常适合大规模的海量存储。

使用GlusterFS卷
================

通常为了结构清晰和便于维护，GlusterFS客户端和服务器是采用分离部署的。这里我们把刚才剔除掉的 ``worker7`` 作为客户端来测试刚才构建的数据卷。当然，客户端和服务器端部署在相同服务器上也是可以的，但是需要确保GlusterFS服务端比客户端先启动并就绪，否则可能会导致客户端异常。

客户端GlusterFS软件安装
--------------------------

在客户端不需要安装完整的glusterfs软件包，只需要安装 ``gluster-fuse`` 软件包::

   dnf install glusterfs-fuse

客户端挂载GlusterFS卷
-----------------------

- 在 ``worker7`` 上创建挂载目录::

   mkdir -p /data/gv0

- 使用 ``glusterfs`` 类型挂载存储卷::

   mount -t glusterfs worker1:/gv0 /data/gv0

- 检查挂载::

   df -h

可以看到输出::

   Filesystem      Size  Used Avail Use% Mounted on
   ...
   worker1:/gv0    466G  8.0G  458G   2% /data/gv0

- 检查挂载::

   mount | grep gv0

显示输出::

   worker1:/gv0 on /data/gv0 type fuse.glusterfs (rw,relatime,user_id=0,group_id=0,default_permissions,allow_other,max_read=131072)

.. note::

   在实际生产环境，可以采用DNS轮询的方式，通过DNS解析到多个服务器节点，这样挂载时即使有服务器节点故障，依然可以通过正常工作的服务器节点获得glusterfs的挂载信息配置。实际上 ``worker1`` 只是提供客户端下载GlusterFS卷配置信息的服务器节点，客户端实际上是和集群的所有服务器进行通讯和读写数据。

- 测试文件存储::

   for i in `seq -w 1 100`; do cp -rp /var/log/messages /data/gv0/copy-test-$i;done

我估算了一下，12秒钟复制了 27MB*100 = 2.7GB 数据，大约写入速度是 245MB/s (连续大文件写入)

GlusterFS文件分布
--------------------

上述6个brick，按照顺序排列，可以在 ``worker1`` 节点 ``/data/brick1/gv0`` 目录下看到文件::

   copy-test-001
   copy-test-004
   copy-test-006
   copy-test-008
   ...

``worker2`` 对应目录::

   copy-test-001
   copy-test-004
   copy-test-006
   copy-test-008
   ...

``worker3`` 对应目录::

   copy-test-001
   copy-test-004
   copy-test-006
   copy-test-008
   ...
   
从 ``worker4`` 对应目录开始分布第二个文件::

   copy-test-002
   copy-test-003
   copy-test-005
   copy-test-007
   ...

``worker5`` ::

   copy-test-002
   copy-test-003
   copy-test-005
   copy-test-007
   ...

``worker6`` ::

   copy-test-002
   copy-test-003
   copy-test-005
   copy-test-007
   ...
   
可以看到文件分布是按照文件名进行hash后存放到对应brick上，每个brick是一个完整的文件，所以如果出现某些异常情况，是可以通过直接复制brick中文件来恢复的。

这种 ``replica`` 卷中存储的文件是每个原始文件的完整副本，所以比较容易恢复。如果是采用 ``dispersed`` 卷(纠错卷)(dispersed英文原意是色散)，则基于ErasureCodes（纠错码），类似RAID5/6。通过配置Redundancy（冗余）级别提高可靠性，在保证较高的可靠性同时，可以提升物理存储空间的利用率。

.. note::

   参考 `GlusterFS Dispersed Volume(纠错卷)总结 <https://blog.csdn.net/xdgouzongmei/article/details/52748812>`_

参考
=======

- `Getting started with GlusterFS - Quick Start Guide <https://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/>`_
- `Creating and Resizing XFS Partitions <https://linuxhint.com/creating-and-resizing-xfs-partitions/>`_
- `Install & configure glusterfs distributed volume RHEL/CentOS 8 <https://www.golinuxcloud.com/glusterfs-distributed-volume-centos-rhel-8/>`_
