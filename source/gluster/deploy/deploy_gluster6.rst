.. _deploy_gluster6:

===================
部署Gluster 6
===================

.. note::

   本文是采用6台服务器构建的GlusterFS集群:

   - 存储类型服务器，所以每台服务器配置了12块nvme磁盘
   - 由于GlusterFS 7.x对操作系统要求CentOS 7.5以上，暂不满足，采用GlusterFS 6.x构建部署(不过，如果条件许可，部署建议采用最新版本7.x)

操作系统准备
=============

- 由于应用要求，操作系统版本采用CentOS 7.x，首先升级系统安装可用补丁::

   yum update

磁盘
-----

磁盘存储是Gluster的基础，Gluster是基于操作系统的文件系统构建的，底层需要构建一个文件系统。文件系统可以基于LVM卷管理，未来可能更完善的方案是结合 :ref:`stratis` 来实现一个文件系统技术栈。如果没有快照这样的高级需求，可以简单在 :ref:`xfs` 构建一个架构清晰的GlusterFS系统。

- 服务器硬件通过 ``lspci`` 可以查看NVME设备::

   lspci | grep -i ssd

输出类似::

   5e:00.0 Non-Volatile memory controller: Intel Corporation NVMe Datacenter SSD [3DNAND, Beta Rock Controller]
   5f:00.0 Non-Volatile memory controller: Intel Corporation NVMe Datacenter SSD [3DNAND, Beta Rock Controller]
   ...

每个服务器上有12块NVME磁盘。

- 使用 ``fdisk -l`` 查看磁盘可以看到::

   Disk /dev/nvme4n1: 3840.0 GB, 3840000000512 bytes, 7500000001 sectors
   Units = sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disk label type: gpt
   Disk identifier: 105B8520-79F3-4834-A925-7EC27FC1219B
   ...

- 可以通过手工命令在每台服务器，对每个NVME磁盘进行分区::

   parted -a optimal /dev/nvme0n1 mkpart primary 0% 100%
   parted -a optimal /dev/nvme0n1 name 1 gluster_brick0
   mkfs.xfs -i size=512 /dev/nvme0n1

.. note::

   参数解析：

   - ``-a optimal`` 可以通过 ``parted`` 的自动4k对齐，这个参数非常重要，可以避免4k没有对齐对存储性能的影响
   - ``parted`` 的命令 ``mkpart primary 0% 100%`` 可以将磁盘整个创建一个主分区
   - ``parted`` 的命令 ``name 1 gluster_brick0`` 是将分区命名成gluster相关
   - ``mkfs.xfs -i size=512`` 格式化XFS文件系统

重复以上命令会让人发疯(每台服务器12块磁盘，服务器数量众多)，所以我们应该采用一个简单对脚本来自动完成对12块磁盘进行分区和格式化::

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

- 完成磁盘分区和格式化之后， ``df -h`` 检查磁盘挂载情况如下::

   /dev/nvme0n1p1           3.5T   33M  3.5T   1% /data/brick0
   /dev/nvme1n1p1           3.5T   33M  3.5T   1% /data/brick1
   /dev/nvme2n1p1           3.5T   33M  3.5T   1% /data/brick2
   /dev/nvme3n1p1           3.5T   33M  3.5T   1% /data/brick3
   /dev/nvme4n1p1           3.5T   33M  3.5T   1% /data/brick4
   /dev/nvme5n1p1           3.5T   33M  3.5T   1% /data/brick5
   /dev/nvme6n1p1           3.5T   33M  3.5T   1% /data/brick6
   /dev/nvme7n1p1           3.5T   33M  3.5T   1% /data/brick7
   /dev/nvme8n1p1           3.5T   33M  3.5T   1% /data/brick8
   /dev/nvme9n1p1           3.5T   33M  3.5T   1% /data/brick9
   /dev/nvme10n1p1          3.5T   33M  3.5T   1% /data/brick10
   /dev/nvme11n1p1          3.5T   33M  3.5T   1% /data/brick11

GlusterFS软件安装
===================

- 由于GlusterFS 7版本对操作系统要求很高(CentOS 7.5以上)，为了避免大规模修改操作系统，采用GlusterFS 6.10部署。

- 在CentOS上部署GlusterFS和Ceph存储，是通过 `CentOS Storage Special Interest Group (SIG) <https://wiki.centos.org/SpecialInterestGroup>`_ 统一仓库安装，执行以下命令安装仓库::

   # 检查可安装的软件版本：
   yum search centos-release-gluster
   # 安装指定Gluster 6 packages
   yum install centos-release-gluster6

上述软件仓库安装实际部署了以下2个配置文件：

  - ``/etc/yum.repo.d/CentOS-Gluster-6.repo``
  - ``/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage``

所以，即使安装服务器不 ``yum install centos-release-gluster6`` 也可以将上述两个文件复制到安装服务器上，然后就可以执行安装GlusterFS:

  - 在安装服务器上添加 ``/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage`` 内容如下::

     -----BEGIN PGP PUBLIC KEY BLOCK-----
     Version: GnuPG v2.0.22 (GNU/Linux)
     
     mQENBFTCLWABCADDHh5ktfB+78L6yxcIxwbZgaLKTp0mKvM3i2CjBrbw+xHJ4x9E
     mn39rkTJf2UHOK0PgAp3FftoAFCtrSAXuanNGpEcpSxXDzxNj2QMpAbySZ2r4RpL
     qxNVlB73dHuASXIMlhyV1ASpM6Me0dpaTtyKj38kRPFkWWuIUaiEQzXFgztYx7Kp
     i+we0iUBfSKY47l2rbqyu9qZ8kCeMjuSuLfG5OKw+fj9zwqFJkc+LAz8IPTF4g7p
     48m0m5bUPvKIIa1BfYcyqaTMxfbqjGaF1M37zF1O0TUKGQ+8VddzQmwg7GglQMt3
     FqVer1WJUNPXyEgmZMzfmg7lqdPKKYaQBLk1ABEBAAG0XkNlbnRPUyBTdG9yYWdl
     IFNJRyAoaHR0cDovL3dpa2kuY2VudG9zLm9yZy9TcGVjaWFsSW50ZXJlc3RHcm91
     cC9TdG9yYWdlKSA8c2VjdXJpdHlAY2VudG9zLm9yZz6JATkEEwECACMFAlTCLWAC
     GwMHCwkIBwMCAQYVCAIJCgsEFgIDAQIeAQIXgAAKCRDUouUL5FHltbq9B/93dtpt
     lQG2mVvGik9TFgRdt+p3CPTqT1fwNzhB3iO02yJu5oM6s4FB1XqKRaKlqtvtBzyT
     geAwenu74aU1hFv4uq+uETCanUaSgOvTcCn5WXUpOvlwKJV7TUjLSNRfp2dAG8Ig
     d3euLnfajCE13t5BrqhTAlaMxAbGAqtzr6K9y0hUeT0ogjrscfoQSVptlcLs8d7m
     P+VMR4GUfvUAws65JZxBaal4N7eIIZCWktnJ+B3dE3/tsAksGyXGLaSroPSuY18V
     wksdBuscKVV49Ees0SbhvSrF5JJ07ccUt43SSFun84iNW4nuiWm2QOOKMcd182Sk
     d9SDUTFu/G4s2gx7
     =a0nM
     -----END PGP PUBLIC KEY BLOCK-----

  - 在 ``/etc/yum.repo.d`` 目录下添加配置文件 ``CentOS-Gluster-6.repo`` 内容如下::

     # CentOS-Gluster-6.repo
     #
     # Please see http://wiki.centos.org/SpecialInterestGroup/Storage for more
     # information
     
     [centos-gluster6]
     name=CentOS-$releasever - Gluster 6
     mirrorlist=http://mirrorlist.centos.org?arch=$basearch&release=$releasever&repo=storage-gluster-6
     #baseurl=http://mirror.centos.org/$contentdir/$releasever/storage/$basearch/gluster-6/
     gpgcheck=1
     enabled=1
     gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage
     
     [centos-gluster6-test]
     name=CentOS-$releasever - Gluster 6 Testing
     baseurl=http://buildlogs.centos.org/centos/$releasever/storage/$basearch/gluster-6/
     gpgcheck=0
     enabled=0
     gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Storage

- 执行安装::

   yum install glusterfs-server

- 启动GlusterFS管理服务::

   systemctl enable --now glusterd

- 检查服务状态::

   systemctl status glusterd

配置GlusterFS
===============

- 确保服务器打开正确通讯端口::

   # firewall-cmd --zone=public --add-port=24007-24008/tcp --permanent
   success

   # firewall-cmd --reload
   success

.. note::

   CentOS 7 默认启用了防火墙，上述步骤请务必确认执行成功。否则后续添加 ``peer`` 节点会显示 ``Disconected`` 状态，无法正常工作。

- 在采用分布式卷的配置时，需要确保 ``brick`` 数量是 ``replica`` 数量的整数倍。举例，配置 ``replica 3`` ，则对应 ``bricks`` 必须是 ``3`` / ``6`` / ``9`` 依次类推。

在这个部署案例中，采用了 ``6`` 台服务器，每个服务器 ``12`` 块NVME磁盘，所以我们构建的 ``bricks`` 可以是 ``12*6`` 就是 ``3`` 副本的整数倍。

- 在 ``第一台`` 主机上执行 ``一次`` 节点配对::

   gluster peer probe 192.168.1.2 
   gluster peer probe 192.168.1.3 
   gluster peer probe 192.168.1.4 
   gluster peer probe 192.168.1.5 
   gluster peer probe 192.168.1.6 

配对以后通过 ``gluster peer status`` 检查对端服务器，需要确认状态必须都是 ``Connected`` 并且有 ``5`` 个peers::

   Number of Peers: 5
   
   Hostname: 192.168.1.2
   Uuid: c5fa4b1a-5244-4d1d-9a65-747e452dcfe5
   State: Peer in Cluster (Connected)
   
   Hostname: 192.168.1.3
   Uuid: b0965fc2-7293-4675-a1bd-702a06d18578
   State: Peer in Cluster (Connected)
   ...

配置gluster卷
---------------

- 创建一个简单的脚本 ``create_gluster`` ，方便自己构建一个 ``replica 3`` 的分布式卷::

   volume=$1
   server1=192.168.1.1
   server2=192.168.1.2
   server3=192.168.1.3
   server4=192.168.1.4
   server5=192.168.1.5
   server6=192.168.1.6
   
   gluster volume create ${volume} replica 3 \
           ${server1}:/data/brick0/${volume} \
           ${server2}:/data/brick0/${volume} \
           ${server3}:/data/brick0/${volume} \
           ${server4}:/data/brick0/${volume} \
           ${server5}:/data/brick0/${volume} \
           ${server6}:/data/brick0/${volume} \
           \
           ${server1}:/data/brick1/${volume} \
           ${server2}:/data/brick1/${volume} \
           ${server3}:/data/brick1/${volume} \
           ${server4}:/data/brick1/${volume} \
           ${server5}:/data/brick1/${volume} \
           ${server6}:/data/brick1/${volume} \
           \
           ${server1}:/data/brick2/${volume} \
           ${server2}:/data/brick2/${volume} \
           ${server3}:/data/brick2/${volume} \
           ${server4}:/data/brick2/${volume} \
           ${server5}:/data/brick2/${volume} \
           ${server6}:/data/brick2/${volume} \
           \
           ${server1}:/data/brick3/${volume} \
           ${server2}:/data/brick3/${volume} \
           ${server3}:/data/brick3/${volume} \
           ${server4}:/data/brick3/${volume} \
           ${server5}:/data/brick3/${volume} \
           ${server6}:/data/brick3/${volume} \
           \
           ${server1}:/data/brick4/${volume} \
           ${server2}:/data/brick4/${volume} \
           ${server3}:/data/brick4/${volume} \
           ${server4}:/data/brick4/${volume} \
           ${server5}:/data/brick4/${volume} \
           ${server6}:/data/brick4/${volume} \
           \
           ${server1}:/data/brick5/${volume} \
           ${server2}:/data/brick5/${volume} \
           ${server3}:/data/brick5/${volume} \
           ${server4}:/data/brick5/${volume} \
           ${server5}:/data/brick5/${volume} \
           ${server6}:/data/brick5/${volume} \
           \
           ${server1}:/data/brick6/${volume} \
           ${server2}:/data/brick6/${volume} \
           ${server3}:/data/brick6/${volume} \
           ${server4}:/data/brick6/${volume} \
           ${server5}:/data/brick6/${volume} \
           ${server6}:/data/brick6/${volume} \
           \
           ${server1}:/data/brick7/${volume} \
           ${server2}:/data/brick7/${volume} \
           ${server3}:/data/brick7/${volume} \
           ${server4}:/data/brick7/${volume} \
           ${server5}:/data/brick7/${volume} \
           ${server6}:/data/brick7/${volume} \
           \
           ${server1}:/data/brick8/${volume} \
           ${server2}:/data/brick8/${volume} \
           ${server3}:/data/brick8/${volume} \
           ${server4}:/data/brick8/${volume} \
           ${server5}:/data/brick8/${volume} \
           ${server6}:/data/brick8/${volume} \
           \
           ${server1}:/data/brick9/${volume} \
           ${server2}:/data/brick9/${volume} \
           ${server3}:/data/brick9/${volume} \
           ${server4}:/data/brick9/${volume} \
           ${server5}:/data/brick9/${volume} \
           ${server6}:/data/brick9/${volume} \
           \
           ${server1}:/data/brick10/${volume} \
           ${server2}:/data/brick10/${volume} \
           ${server3}:/data/brick10/${volume} \
           ${server4}:/data/brick10/${volume} \
           ${server5}:/data/brick10/${volume} \
           ${server6}:/data/brick10/${volume} \
           \
           ${server1}:/data/brick11/${volume} \
           ${server2}:/data/brick11/${volume} \
           ${server3}:/data/brick11/${volume} \
           ${server4}:/data/brick11/${volume} \
           ${server5}:/data/brick11/${volume} \
           ${server6}:/data/brick11/${volume}

.. note::

   上述 ``create_gluster`` 脚本会依次在 ``server1`` 到 ``server6`` 均匀分布3个副本文件。

- 将脚本加上执行权限::

   chmod 755 create_gluster

- 然后创建卷，举例是 ``backup`` ::

   volume=backup
   ./create_gluster ${volume}
   gluster volume start ${volume}

如果创建卷错误，也可以很容易删除::

   gluster volume stop ${volume}
   gluster volume delete ${volume}

不过，命令行操作默认会提示是否删除，所以对于脚本化不利。此时可以使用参数 ``--mode=script`` 来直接执行::

   gluster volume stop ${volume} --mode=script
   gluster volume delete ${volume} --mode=script

.. note::

   删除掉的卷在 ``bricks`` 目录下依然残留以卷名为子目录，所以需要进一步清理::

      volume=$1
      for i in {0..11};do
         rm -rf /data/brick${i}/${volume}
      done

- 创建完成后检查::

   gluster volume status ${volume}

挂载gluster卷
-------------

- 在客户端服务器只需要安装 ``gluster-fuse`` 软件包::

   yum install gluster-fuse

- 在客户端服务器上创建挂载目录::

   mkdir -p /data/backup

- 修改 ``/etc/fstab`` 添加如下内容::

   192.168.1.1:/backup  /data/backup  glusterfs    defaults,_netdev,direct-io-mode=enable,backupvolfile-server=192.168.1.2    0    0

- 挂载存储卷::

   mount /data/backup

- 然后检查挂载目录如下::

   df -h

显示::

   192.168.1.1:/backup   84T  859G   83T   2% /data/backup
