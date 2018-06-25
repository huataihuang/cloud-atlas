=======================================
4.8 调整虚拟机磁盘大小
=======================================

.. note::

    通过组合合适的VM文件系统功能（例如支持在线resize的XFS文件系统）和QEMU底层 ``virsh qemu-monitor-command`` 指令可以实现在线动态调整虚拟机磁盘容量，无需停机，对维护在线应用非常方便。

--------------------------------
在线添加虚拟机磁盘
--------------------------------

现在我们有一个运行中的 ``ubuntu18`` 虚拟机，需要在线添加磁盘（不重启虚拟机操作系统）

* 在物理服务器上创建虚拟磁盘文件（qcow2类型）

::

    cd /var/lib/libvirt/images
    qemu-img create -f qcow2 ubuntu18-data.qcow2 20G

* 虚拟磁盘文件添加到虚拟机

``qemu`` 可以映射物理存储磁盘（ 如物理服务器的 ``/dev/sdb`` ）或虚拟磁盘文件到KVM虚拟机 ``ubuntu18`` 的虚拟磁盘( ``vdb`` )，方法如下：

::

    virsh attach-disk ubuntu18 --source /var/lib/libvirt/images/ubuntu18-data.qcow2 \
    --target vdb --persistent --driver qemu --subdriver qcow2

.. note::

    注意：这里一定要指定 ``--driver qemu --subdriver qcow2`` ，因为 ``libvirtd`` 出于安全因素默认关闭了虚拟磁盘类型自动检测功能，并且默认使用的磁盘格式是``raw`` 。
    
    如果不指定磁盘驱动类型会导致被识别成 ``raw`` 格式，就会在虚拟机内部看到非常奇怪的极小的磁盘（ ``0 MB, 197120 bytes, 385 sectors`` ），即如果使用的是如下命令

    ::

        virsh attach-disk ubuntu18 --source /var/lib/libvirt/images/ubuntu18-data.qcow2 --target vdb --persistent
    
    
    则此时在虚拟机内部检查 ``/dev/vdb`` 磁盘会看到只有 ``0MB`` ：

    ::

        Disk /dev/vdb: 0 MB, 197120 bytes, 385 sectors
        Units = sectors of 1 * 512 = 512 bytes
        Sector size (logical/physical): 512 bytes / 512 bytes
        I/O size (minimum/optimal): 512 bytes / 512 bytes

    不过，在物理主机上，对于 ``qcow2`` 类型磁盘是能够正确识别20G大小的。但是对比 ``virsh dumpxml ubuntu18`` 可以看到没有指定磁盘设备类型，被默认添加成 ``raw`` 类型

    ::

        <disk type='file' device='disk'>
          <driver name='qemu' type='raw'/>
          <source file='/var/lib/libvirt/images/ubuntu18-data.qcow2'/>
          <target dev='vdb' bus='virtio'/>
          <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
        </disk>        


此时在虚拟机内部使用命令 ``fdisk -l`` 可以看到增加了一块20G磁盘。我们先格式化成 ``XFS`` 格式并挂载，然后来演示如何在线动态扩展磁盘。

> 当前只有部分文件系统，如 XFS 可以支持在线扩展。

::

    mkfs.xfs /dev/vdb
    mkdir /data
    echo "/dev/vdb                /data                   xfs     defaults        0 0" >> /etc/fstab
    mount /data

此时在虚拟机 ``ubuntu18`` 内部执行 ``df -h /data`` 可以看到这块挂载的磁盘空间是20G

::

    Filesystem      Size  Used Avail Use% Mounted on
    /dev/vdb         20G   33M   20G   1% /data

* 在物理主机上检查设备详情

::

    virsh qemu-monitor-command ubuntu18 --hmp "info block"

输出显示虚拟磁盘 ``ubuntu18-data.qcow2`` 对应块设备信息

::

    drive-virtio-disk1: removable=0 io-status=ok file=/var/lib/libvirt/images/ubuntu18-data.qcow2 ro=0 drv=qcow2 encrypted=0 bps=0 bps_rd=0 bps_wr=0 iops=0 iops_rd=0 iops_wr=0

--------------------------------
在线修改虚拟机磁盘
--------------------------------

.. note::

    只有 ``raw`` 格式支持双向resize（扩大或缩小）， ``qcow2`` 版本2或 ``qcow2`` 版本3的镜像只支持扩大(grown)不支持缩小(shrunk)

* 首先使用 ``qemu-img`` 命令 ``resize`` 虚拟磁盘大小

::

    qemu-img resize filename [+|-]size[K|M|G|T]

举例：

::

    qemu-img resize /var/lib/libvirt/images/ubuntu18-data.qcow2 30G

.. note::

    使用 ``qemu-img info /var/lib/libvirt/images/ubuntu18-data.qcow2`` 可以查看调整后虚拟磁盘 virtual size 是 30G ，不过其 disk size 依然不变（因为实际无数据变化）。

* 然后使用 ``qemu-monitor-command`` 的 ``block_resize`` 指令通知 ``qemu`` 虚拟机磁盘的大小已经修改成 30G 。注意，这里设备名是块设备名 ``drive-virtio-disk1`` ，调整为 30G 大小：

::

    virsh qemu-monitor-command dev7 --hmp "block_resize drive-virtio-disk1 30G"

* 此时在虚拟机内部检查

在 ``ubuntu18`` 虚拟机内部使用命令 ``fdisk -l /dev/vbd`` 可以看到磁盘设备已经增长到30G

* 在虚拟机 ``ubuntu18`` 内部调整文件系统（XFS可以在线调整挂载磁盘的文件系统大小）

::

    xfs_growfs /data/

此时在 ``ubuntu18`` 虚拟机内部 ``df -h /data`` 可以看到输出信息显示磁盘30G

::

    Filesystem      Size  Used Avail Use% Mounted on
    /dev/vdb         30G   33M   30G   1% /data

.. note::

    Windows虚拟机磁盘添加和扩展方法类似，但需要注意处理 ``virtio`` 驱动以及磁盘resize后需要重启VM操作系统才能识别。

--------------------------------
附录：磁盘格式的差异
--------------------------------

* ``raw`` 格式
  * ``raw`` 格式是性能最快的磁盘文件格式。
  * ``raw`` 格式只支持最基本特性 - 例如， ``raw`` 格式不支持快照
  * ``raw`` 格式支持双向 resize （扩大或缩小）
* ``qcow2`` 格式
  * ``qcow2`` 格式只支持扩大不支持缩小
  * ``qcow2`` 格式支持快照

--------------------------------
参考
--------------------------------

* `Supported qemu-img Formats <https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/7/html/Virtualization_Deployment_and_Administration_Guide/sect-Using_qemu_img-Supported_qemu_img_formats.html>`_
* 