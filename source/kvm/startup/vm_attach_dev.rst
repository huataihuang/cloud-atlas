.. _vm_attach_dev:

==================
KVM虚拟机添加设备
==================

KVM虚拟机可以在线(运行时)添加磁盘、CDROM、USB设备，这对在线维护非常有用，可以不停机修改设备。

.. note::

   案例使用的虚拟机名字 ``dev7`` ，添加的磁盘文件命名为 ``dev7-data.qcow2``

添加磁盘文件
==============

- 创建虚拟磁盘文件（qcow2类型）::

   cd /var/lib/libvirt/images
   qemu-img create -f qcow2 dev7-data.qcow2 20G

- 虚拟磁盘文件添加到虚拟机

``qemu`` 可以映射物理存储磁盘(例如 ``/dev/sdb`` )，或者虚拟磁盘文件到KVM虚拟机的虚拟磁盘( ``vdb`` )

::

   virsh attach-disk dev7 --source /var/lib/libvirt/images/dev7-data.qcow2 --target vdb --persistent --drive qemu --subdriver qcow2

.. warning::

   一定要明确使用 ``--driver qemu --subdriver qcow2`` :

   ``libvirtd`` 出于安全因素默认关闭了虚拟磁盘类型自动检测功能，并且默认使用的磁盘格式是 ``raw`` ，如果不指定磁盘驱动类型会导致被识别成 ``raw`` 格式，就会在虚拟机内部看到非常奇怪的极小的磁盘。

添加iso光盘
============

cdrom/floppy 不支持热插拔，所以和上面动态插入一个磁盘设备不同，如果直接使用以下命令插入设备( 虚拟机名字是 ``sles12-sp3`` )映射::

   virsh attach-disk sles12-sp3 SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso --target hdc --type cdrom --mode readonly

会提示错误::

   error: Failed to attach disk
   error: Operation not supported: cdrom/floppy device hotplug isn't supported

- 但是，如果虚拟机定义时候已经定义过cdrom设备，则使用 ``virsh dumpxml sles12-sp3`` 可以看到如下设备::

    <disk type='file' device='cdrom'>
      <driver name='qemu'/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <alias name='sata0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>

则我们可以通过指定将iso文件插入到虚拟机中的 ``sda`` CDROM中::

   virsh attach-disk sles12-sp3 /var/lib/libvirt/images/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso sda --type cdrom --mode readonly

就会提示成功插入::

   Disk attached successfully

- 再次使用 ``virsh dumpxml sles12-sp3`` 可以看到iso文件加载::

    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source file='/var/lib/libvirt/images/SLE-12-SP3-Server-DVD-x86_64-GM-DVD1.iso' index='3'/>
      <backingStore/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <alias name='sata0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>

- 如果要卸载这个iso文件，则创建一个相同结构的xml文件 ``detach_iso.xml`` ，但是保持 ``<source/>`` 行删除::

    <disk type='file' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <backingStore/>
      <target dev='sda' bus='sata'/>
      <readonly/>
      <alias name='sata0-0-0'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>

- 然后执行设备更新::

   virsh update-device sles12-sp3 detach_iso.xml

此时提示::

   Device updated successfully

再检查虚拟机配置，就看到iso文件已经卸载了。

参考
=====

- `UnixArena Linux KVM <http://www.unixarena.com/category/redhat-linux/linux-kvm>`_
- `Attaching and updating a device with virsh <https://docs.fedoraproject.org/en-US/Fedora/18/html/Virtualization_Administration_Guide/sect-Attaching_and_updating_a_device_with_virsh.html>`_
