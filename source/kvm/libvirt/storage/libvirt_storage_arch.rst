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

参考
======

- `libvirt Storage Management <https://libvirt.org/storage.html>`_
