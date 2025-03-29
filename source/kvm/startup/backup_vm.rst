.. _backup_vm:

===============
备份KVM虚拟机
===============

.. note::

   我暂时还没有执行过在线KVM虚拟机备份实践，但是我感觉后续在运维过程中会有这样的需求，后续再实践。

冷备份KVM虚拟机
================

比较简单的虚拟机备份方法是先关闭虚拟机，然后备份xml配置和磁盘文件，举例备份 :ref:`create_vm` 实践中创建的Windows 10虚拟机::

   virsh shutdown win10
   virsh dumpxml win10 > /var/lib/libvirt/images/win10.xml
   cd /var/lib/libvirt/images
   tar cfJ win10.tar.xz win10.xml win10.qcow2

热(Live)备份KVM虚拟机
=======================

待实践...

参考
======

- `Live-disk-backup-with-active-blockcommit <https://wiki.libvirt.org/page/Live-disk-backup-with-active-blockcommit>`_
- `How to Perform a Live Backup on your KVM Virtual Machines <https://www.virtkick.com/docs/how-to-perform-a-live-backup-on-your-kvm-virtual-machines.html>`_
