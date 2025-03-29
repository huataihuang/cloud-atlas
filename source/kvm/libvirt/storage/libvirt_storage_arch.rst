.. _libvirt_storage_arch:

====================
libvirt存储管理
====================

libvirt存储池和存储卷
=======================

libvirt通过存储池和卷来提供物理主机的存储管理功能:

所谓存储池是站在系统管理员角度来说，也就是使用虚拟机的独立存储的系统管理员。存储池被系统管理员或存储管理划分为不同的存储卷，然后这些存储卷被作为块设备分配给VM。

对于虚拟机里说，存储池和存储卷并不是必须的。存储池和存储卷只是提供了一种libvirt的管理方式，确保了VM能够方便使用存储。有些系统管理员倾向于自己管理存储，不实用任何存储池或存储卷。此时，系统管理员必须确保VM使用存储时，这些虚拟存储设备已经就绪，例如在物理主机的 ``fstab`` 文件中定义好NFS共享卷挂载，以便物理主机启动时就已经挂载好共享卷。

libvirt只是提供了一种管理虚拟机的方式，提供了完整的VM任务管理:

- 分配资源
- 运行虚拟机
- 关闭虚拟机
- 释放资源

这些libvirt任务都不需要管理员使用shell访问或者其他控制，带来了虚拟机管理的便利。

NFS存储卷案例
-----------------

负责维护NFS服务器的存储管理员创建一个虚拟机数据使用的共享存储。系统管理员就可以为虚拟机定义这个共享存储，例如将 ``nfs.example.com:/path/to/share`` 挂载到 ``/vm_data`` 。当存储池启动后，libvirt就可以将这个共享挂载到指定目录，就好像系统管理登陆主机执行了 ``mount nfs.example.com:/path/to/share /vmdata`` 命令。如果这个存储池被配置成自动启动，libvirt会确保libvirt启动时自动挂载这个NFS共享到指定目录。

一旦存储池启动，在这个NFS共享上的文件就被作为一个卷，而存储卷路径可以通过libvirt API查询。这个卷路径可以被复制到VM的XML定义的块设备定义部分。在使用NFS的情况下，使用libvirt API的应用程序可以创建或者删除存储池中的卷(也就是NFS共享中的文件)，直到将整个存储卷空间用完。注意，不是所有的存储卷类型都支持创建和删除卷。

iSCSI存储卷案例
-----------------

在iSCSI存储卷中，存储管理员提供一个iSCSI target来标识运行虚拟机的物理主机上的一个LUN集合。当libvirt被配置成管理iSCSI target作为存储池，libvirt将会确保物理主机正确登陆到iSCSI target并且报告可用个LUN作为存储卷。这些卷的路径可以被查询也可以被VM的XML定义使用，就像上文的NFS案例。这种情况下，LUN是在iSCSI服务器上定义，而libvirt不能创建和删除卷。

.. note::

   也就是libvirt不能管理iSCSI Server，只能先在iSCSI Server上创建好iSCSI target，输出给libvirt管理的物理服务器。这种情况下libvirt只负责登陆iSCSI target以及查询有哪些LUN可以作为存储。这和NFS存储卷不同，NFS存储上的文件作为VM的卷，所以libvirt可以任意创建和删除。

Libvirt支持存储类型
======================

.. note::

   libvirt也支持 :ref:`btrfs` ，但是根据资料，需要关闭 :ref:`btrfs` 的 COW 特性，不能使用checksum，这可能导致Btrfs的优势不再。所以，我可能会放弃在libvirt使用btrfs(具体资料待调研)

Libvirt支持以下存储池类型:

目录存储池
-------------

``dir`` 存储池类型意味着在一个目录中管理虚拟机的存储卷文件。这些文件可以是完全分配的 ``raw`` 文件，或者是稀疏分配的 ``raw`` 文件，或者是稀疏磁盘格式，例如 ``qcow2`` ``vmdk`` 等等可以通过 ``qemu-img`` 程序支持的磁盘文件。如果定义存储池的时候目录不存在， ``build`` 操作可以创建该目录::

   <pool type="dir">
     <name>virtimages</name>
     <target>
       <path>/var/lib/virt/images</path>
     </target>
   </pool>

在目录存储池中支持的文件格式:

- raw: a plain file
- bochs: Bochs disk image format
- cloop: compressed loopback disk image format
- cow: User Mode Linux disk image format
- dmg: Mac disk image format
- iso: CDROM disk image format
- qcow: QEMU v1 disk image format
- qcow2: QEMU v2 disk image format
- qed: QEMU Enhanced Disk image format
- vmdk: VMware disk image format
- vpc: VirtualPC disk image format

文件系统存储池
-----------------

文件系统存储池是目录存储池的变体。这种文件系统存储池并不是在一个已经挂载的文件系统上创建一个目录，而是直接使用一个源块设备，这块设备被挂载到libvirt管理的一个挂载点上。默认情况下，文件系统存储池允许内核自动侦测文件系统，也可以指定文件系统类型::

   <pool type="fs">
     <name>virtimages</name>
     <source>
       <device path="/dev/VolGroup00/VirtImages"/>
     </source>
     <target>
       <path>/var/lib/virt/images</path>
     </target>
   </pool>

文件系统存储池支持的文件系统类型:

- auto - automatically determine format
- ext2
- ext3
- ext4
- ufs
- iso9660
- udf
- gfs
- gfs2
- vfat
- hfs+
- xfs
- ocfs2
- vmfs

网络文件系统存储池
--------------------

网络文件系统存储池是文件系统存储池的变体。在网络文件系统存储池中，不是将一个本地块设备作为源，而是远程主机名以及远程主机输出的目录。libvirt会完成网络文件系统更多挂载，并且管理这个挂载点目录中的文件。网络文件系统存储池默认使用 ``auto`` 作为挂载协议，通常会首先尝试NFS挂载::

   <pool type="netfs">
     <name>virtimages</name>
     <source>
       <host name="nfs.example.com"/>
       <dir path="/var/lib/virt/images"/>
       <format type='nfs'/>
     </source>
     <target>
       <path>/var/lib/virt/images</path>
     </target>
   </pool>

网络文件系统存储池支持的网络文件系统类型有:

- auto - automatically determine format
- nfs
- :ref:`gluster` - 使用glusterfs FUSE文件系统。当前只支持 ``dir`` 指定为gluster的一个卷名作为源，因为gluster不提供子目录作为卷挂载
- cifs - 使用SMB(samba)或CIFS文件系统。这个挂载使用 ``-o guest`` 来匿名挂载目录

逻辑卷存储池
--------------

逻辑卷存储池使用基于一个LVM卷组来构建存储池。对于一个已经定义好的LVM卷卷组(即手工构建 物理卷 ``PV`` 和 逻辑卷组 ``VG`` )，只需要提供这个LVM卷组名就可以；如果要构建一个新的卷组，则提供一系列源设备作为物理卷，则逻辑卷会在这个卷组上切分出卷::

   <pool type="logical">
     <name>HostVG</name>
     <source>
       <device path="/dev/sda1"/>
       <device path="/dev/sdb1"/>
       <device path="/dev/sdc1"/>
     </source>
     <target>
       <path>/dev/HostVG</path>
     </target>
   </pool>

:ref:`libvirt_lvm_pool` 实践 是我在 :ref:`hpe_dl360_gen9` 服务器上部署 :ref:`priv_kvm` 采用的主存储池技术。

磁盘存储池
------------

磁盘存储池是基于物理磁盘的存储池。libvirt在磁盘上创建分区来构建存储卷。磁盘存储池大小是首先的并且被卷所替代。其中的 ``free extens`` 信息是有关这个region剩余可创建新卷的信息。一个卷不能跨越两个不同的 ``free extents`` 。默认在磁盘存储池的源格式使用 ``dos`` 分区表::

   <pool type="disk">
     <name>sda</name>
     <source>
       <device path='/dev/sda'/>
     </source>
     <target>
       <path>/dev</path>
     </target>
   </pool>

在磁盘卷存储池支持的分区表类型有:

- dos
- dvh
- gpt
- mac
- bsd
- pc98
- sun
- lvm2

建议在传统的BIOS系统中使用 ``msdos`` 作为分区表，而UEFI系统使用 ``gpt`` 作为分区表(支持大于2TB磁盘)。另外需要注意，这里 ``lvm2`` 格式指的是物理卷格式(也就是整个磁盘作为一个物理卷，不是通常我们在LVM卷管理中作为物理卷的分区)。

SCSI存储池
-------------

我没有这样的实践环境

Multipath存储池
----------------

我理解Multipath是只多路设备的RAID 1环境，暂时没有找到案例，后续看需求


RBD存储池
------------

RDB存储池是在一个 RADOS 存储池中包含了所有RBD镜像的村池池。RBD(RADOS Block Device)是 :ref:`ceph` 分布式存储的组件。这种RBD存储池后端只支持QEMU with RBD。输出到 ``/dev`` 中作为块设备的内核RBD是 ``不支持`` 的。使用RBD存储池后端创建的RBD镜像可以通过手工配置的内核RBD访问，但是这种后端不能提供镜像的映射。使用这种后端创建的镜像可以添加到已经编译支持RBD的QEMU(也就是从 QEMU 0.14.0 开始)。这种存储后端支持 cephx 认证用于和ceph集群通讯。存储cephx认证密钥是由libvirt secret极致负责。下面的案例中存储池UUID是引用存储密钥的UUID::

   <pool type="rbd">
     <name>myrbdpool</name>
     <source>
       <name>rbdpool</name>
       <host name='1.2.3.4'/>
       <host name='my.ceph.monitor'/>
       <host name='third.ceph.monitor' port='6789'/>
       <auth username='admin' type='ceph'>
         <secret uuid='2ec115d7-3a88-3ceb-bc12-0ac909a6fd87'/>
       </auth>
     </source>
   </pool>

输出的卷案例::

   <volume>
     <name>myvol</name>
     <key>rbd/myvol</key>
     <source>
     </source>
     <capacity unit='bytes'>53687091200</capacity>
     <allocation unit='bytes'>53687091200</allocation>
     <target>
       <path>rbd:rbd/myvol</path>
       <format type='unknown'/>
       <permissions>
         <mode>00</mode>
         <owner>0</owner>
         <group>0</group>
       </permissions>
     </target>
   </volume>

.. note::

   后续我将使用 :ref:`vfio` 将 :ref:`pcie_bifurcation` 切分的 3 个 PCIe NVMe 存储连接到 :ref:`ceph` 虚拟机中构建ceph分布式存储，然后实现一个RBD存储池作为大规模的 :ref:`openstack` 存储后端。

Sheepdog存储池
-----------------

无实践环境

Gluster存储池
-------------------

Gluster存储池提供了原生的Gluster访问。 :ref:`gluster` 是一个分布式文件系统，可以通过FUSE, NFS 或 SMB 输出给用户；不过为了最小化开销，建议通过原生访问(只能用于已经支持 ``libgfapi`` 支持的 QEMU/KVM)。这个集群和存储卷必须是已经运行的，并且建议gluster卷是使用 ``gluster volume set $volname storage.owner-uid=$uid`` 和 ``gluster volume set $volname storage.owner-gid=$gid`` 配置为qemu运行的uid和gid。也有可能需要在glusterd服务上设置 ``rpc-auth-allow-insecure`` ，类似 ``gluster set $volname server.allow-insecure on`` 来允许访问gluster卷。

.. note::

   我计划在 :ref:`hpe_dl360_gen9` 上使用2块HDD构建disk pool，提供给两个虚拟机使用，并使用虚拟机构建一个 :ref:`gluster` 集群，输出给 :ref:`ovirt` 虚拟化集群。这个集群将作为和 :ref:`openstack` 对比的虚拟化解决方案。

- 输入卷案例

一个gluster卷对应了一个libvirt存储池。如果一个gluster卷被挂载成类似 ``mount -t glusterfs localhost:/volname /some/path`` ，这样下面的案例就不需要创建一个本地挂载点。

::

   <pool type="gluster">
     <name>myglusterpool</name>
     <source>
       <name>volname</name>
       <host name='localhost'/>
       <dir path='/'/>
     </source>
   </pool>

- 输出卷案例

libvirt存储卷和一个gluster村池池对应文件就是挂载的gluster卷。这个 ``name`` 是和挂载点相关路径，这里的 ``key`` 是为了唯一标识一个卷::

   <volume>
     <name>myfile</name>
     <key>gluster://localhost/volname/myfile</key>
     <source>
     </source>
     <capacity unit='bytes'>53687091200</capacity>
     <allocation unit='bytes'>53687091200</allocation>
   </volume>

ZFS存储卷
-------------

ZFS存储卷基于一个ZFS文件系统。最初是为FreeBSD开发的，从libvirt 1.3.2 开始实验性支持ZFS on Linux version 0.6.4或更新版本。

ZFS存储池可以手工通过 ``zpool create`` 命令创建，并且它的名字是作为 ``source`` 指定的；不过，从libvirt 1.2.9 开始，可以使用libvirt创建ZFS存储池

- 输入卷案例::

   <pool type="zfs">
     <name>myzfspool</name>
     <source>
       <name>zpoolname</name>
       <device path="/dev/ada1"/>
       <device path="/dev/ada2"/>
     </source>
   </pool>

.. note::

   后续我在虚拟机中研究ZFS时候，再尝试使用ZFS作为libvirt存储卷

Vstorage存储池
-------------------

基于Virtuozzo存储的存储池，这个Virtuozzo存储也是一个高可用分布式存储，不过我不了解，暂时无实践。


参考
======

- `libvirt Storage Management <https://libvirt.org/storage.html>`_
