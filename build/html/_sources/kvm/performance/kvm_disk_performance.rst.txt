.. _kvm_disk_performance:

=======================
KVM虚拟机磁盘性能优化
=======================

:ref:`archlinux_on_mbp` 在物理主机上测试磁盘dd性能::

   time (dd if=/dev/zero of=testdisk oflag=direct bs=64k count=16000;sync)

磁盘写入性能(nvme)可以达到300MB/s::

   16000+0 records in
   16000+0 records out
   1048576000 bytes (1.0 GB, 1000 MiB) copied, 3.47852 s, 301 MB/s
   
   real	0m4.078s
   user	0m0.035s
   sys	0m0.990s

但是，默认 :ref:`create_vm` (CentOS 8)，即使采用了 ``virtio`` 驱动，同样的测试命令连续写入磁盘显示性能只达到100MB/s多一点::

   16000+0 records in
   16000+0 records out
   1048576000 bytes (1.0 GB, 1000 MiB) copied, 9.63737 s, 109 MB/s
   
   real	0m9.667s
   user	0m0.047s
   sys	0m1.270s

virtio磁盘设置io='native'
=========================

qcow2磁盘的aio支持两种模式 ``native`` 和 ``threads`` :

The optional io attribute controls specific policies on I/O; qemu guests support "threads" and "native". Since 0.8.8

- 修改虚拟机配置::

    <disk type='file' device='disk'>
      <!-- driver name='qemu' type='qcow2' cache='none'/-->
      <driver name='qemu' type='qcow2' cache='none' io='native'/>
      <source file='/var/lib/libvirt/images/centos8.qcow2'/>
      <backingStore/>
      <target dev='vda' bus='virtio'/>
      <alias name='virtio-disk0'/>
      <address type='pci' domain='0x0000' bus='0x04' slot='0x00' function='0x0'/>
    </disk>

其中: ``<driver name='qemu' type='qcow2' cache='none'/>`` 修改成 ``<driver name='qemu' type='qcow2' cache='none' io='native'/>`` 

- 同样磁盘测试性能，大约提高50%，吞吐量达到物理主机性能的55%，即 166MB/s ::

   16000+0 records in
   16000+0 records out
   1048576000 bytes (1.0 GB, 1000 MiB) copied, 6.305 s, 166 MB/s
   
   real	0m6.327s
   user	0m0.054s
   sys	0m1.118s

进一步优化参考
=================

后续准备参考 `KVM / Xen <https://wiki.mikejung.biz/KVM_/_Xen>`_ 做进一步实践

参考
======

- `Incredibly low KVM disk performance (qcow2 disk files + virtio) <https://serverfault.com/questions/407842/incredibly-low-kvm-disk-performance-qcow2-disk-files-virtio>`_
- `aio=native or aio=threads – Intro <https://turlucode.com/qemu-disk-io-performance-comparison-native-or-threads-windows-10-version/#1528572626148-2b30f3e4-f00f>`_
- `KVM / Xen <https://wiki.mikejung.biz/KVM_/_Xen>`_
