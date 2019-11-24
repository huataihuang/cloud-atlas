.. _virtio-scsi:

=================
virtio-scsi驱动
=================

virtio-scsi 和 virtio 的性能相同，但是 virtio-scsi 提供了更多功能和更具伸缩性。最大的优势是，virtio-scsi可以在一个虚拟机中处理数百个磁盘设备，远超过 virtio-blk 只能处理25个设备的限制(另一个说法是30个设备，需要验证)。

virtio-scsi提供了直接连接SCSI LUN的能力，并且也提供了继承目标设备特性的能力：

通过virtio-scsi控制器连接的虚拟硬盘或CD，可以从host主机通过QEMU scsi-block设备实现物理SCSI设备的直通(pass-through)，这样就可以实现每个guest使用上百个设备，也提供了极高的存储性能。

virtio-scsi从Red Hat Enterprise Linux 6.3进入Technology Preview，并且从RHEL 6.4开始完全支持，而Windows guests也支持最新的virtio-win驱动。

virtio-scsi作为新型的para-virtualized SCSI控制器设备，性能和virtio-blk相当，但是提供了以下增强功能:

- 提高了可伸缩性 - 虚拟机可以连接更多存储设备(通过虚拟化SCSI设备可以处理更多块设备)
- 标准化的命令集 - virtio-scsi使用标准sCSI指令集，简化了新功能添加
- 标准化的设备命名 - virtual-scsi磁盘使用和裸金属系统相同的设备路径，这样可以简化 物理机到虚拟机 (physical-to-virtual) 和 虚拟机到虚拟机 (virtual-to-virtual) 迁移
- SCSI设备直通 - virtio-scsi可以对guest系统使用物理磁盘设备直通

virto-scsi提供了直接连接SCSI LUN的能力，并且比virtio-blk提供了显著的伸缩性增强(支持数百设备连接)。

配置virtio-scsi
======================

- 添加一个镜像磁盘::

   <devices>
    <disk type='file' device='disk'>
     <target dev='sda' bus='scsi'/>
     <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='scsi' index='0' model='virtio-scsi'/>
   </devices>

- 添加一个直通磁盘设备(DirectLUN Disk / lun passthrough) ::

   <devices>
    <disk type='block' device='lun' rawio='no' sgio='unfiltered'>
     <target dev='sda' bus='scsi'/>
     <address type='drive' controller='0' bus='0' target=0' unit='0'/>
    </disk>
    <controller type='scsi' index='0' model='virtio-scsi'/>
   </devices>


参考
=======

- `What is the support status of the virtio-scsi driver?  <https://access.redhat.com/solutions/300563>`_
- `oVirt Virtio-SCSI <https://www.ovirt.org/develop/release-management/features/storage/virtio-scsi.html>`_
- `virtio-blk vs virtio-scsi <https://mpolednik.github.io/2017/01/23/virtio-blk-vs-virtio-scsi/>`_
