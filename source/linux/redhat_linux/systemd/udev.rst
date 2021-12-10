.. _udev:

======================
Linux udev管理设备
======================

udev配置块设备属主
====================

我在探索 :ref:`add_ceph_osds_raw` 遇到一个经常在存储集群中会遇到的问题，当服务器重启以后，原先在 ``ceph-volume raw prepare`` 命令中执行的子命令::

   /usr/bin/chown -R ceph:ceph /dev/nvme0n1p1

当操作系统重启以后，磁盘设备会恢复到默认的 ``root`` 用户属主::

   brw-rw---- 1 root disk 259, 1 Nov 30 16:31 /dev/nvme0n1p1

.. note::

   实际最后这个设备文件属性还是通过Ceph OSD自身的内置功能去设置的，并没有使用本文的 ``udev`` 设置方法，不过，本文设置 ``udev`` 方法具有普适性，可作为参考。

这个问题实际上在 Oracle ASM 存储中(作为Oracle RAC集群的存储基础)也有类似要求(重启后要求设备属主属于 ``oinstall`` )，也就是说对于分布式系统，应用进程必须能直接访问存储块设备(raw disk)，具备对应权限。

我的目标就是重启系统以后，能够自动把 ``/dev/nvme0n1p1`` 恢复回 ``ceph`` 属主，所以参考 Oracle ASM的配置方法，对磁盘设备进行如下udev rule设置：

- 检查设备在 ``udev`` 中的固定uuid以及变量命名方法::

   udevadm info --query=all --name=/dev/nvme0n1p1 | grep -i uuid

输出显示::

   S: disk/by-partuuid/f3d76ad0-b809-4951-bcff-25309ed6b366
   E: ID_PART_TABLE_UUID=d0203fa3-097b-48cb-8844-601a33239b3e
   E: ID_PART_ENTRY_UUID=f3d76ad0-b809-4951-bcff-25309ed6b366
   E: DEVLINKS=/dev/disk/by-path/pci-0000:06:00.0-nvme-1-part1 /dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NF0R908202-part1 /dev/disk/by-partuuid/f3d76ad0-b809-4951-bcff-25309ed6b366 /dev/disk/by-partlabel/primary /dev/disk/by-id/nvme-eui.002538b911b37f97-part1

- 创建 ``/etc/udev/rules.d/99-perm.rules`` ::

   ACTION=="add|change", ENV{ID_PART_ENTRY_UUID}=="f3d76ad0-b809-4951-bcff-25309ed6b366", OWNER="ceph", GROUP="ceph"

这里可以看到，根据 ``udevadm info --query=all --name=/dev/nvme0n1p1 | grep -i uuid`` 输出中显示 ``E`` 表示 ``ENV`` ，所以 ``E: ID_PART_ENTRY_UUID`` 在规则中就是 ``ENV{ID_PART_ENTRY_UUID}`` ，填写对应的 ``uuid`` 即可。

- 重新加载规则并触发::

   udevadm control --reload-rules
   udevadm trigger --type=devices --action=change

- 然后检查磁盘属主::

   ls -lh /dev/nvme0n1p1

就可以看到自动修改成 ``ceph`` ::

   brw-rw---- 1 ceph ceph 259, 1 Nov 30 16:31 /dev/nvme0n1p1


参考
=======

- `wikipedia udev <https://en.wikipedia.org/wiki/Udev>`_
- `arch linux udev <https://wiki.archlinux.org/title/Udev>`_
- `Beginners Guide to Udev in Linux <https://www.thegeekdiary.com/beginners-guide-to-udev-in-linux/>`_
- `CentOS / RHEL 7 : How to set udev rules for ASM on multipath disks <https://www.thegeekdiary.com/centos-rhel-7-how-to-set-udev-rules-for-asm-on-multipath-disks/>`_
- `How to Configure Device File owner/group with udev rules <https://www.thegeekdiary.com/how-to-configure-device-file-owner-group-with-udev-rules/>`_
