.. _lvmraid:

=========================
LVM RAID( ``lvmraid`` )
=========================

虽然 :ref:`linux_software_raid` 的 :ref:`mdadm` 使用更为广泛和成熟，我也依然想尝试一下 ``lvmraid`` 部署。 ``lvmraid`` 基于 ``MD`` 驱动实现了RAID功能，是另一种解决方案。不过，从各方面信息来看， ``lvmraid`` 可能不够成熟，存在一些性能问题。具体等实践时候再对比...

参考
=========

- `Configure RAID Logical Volumes on Oracle Linux <https://docs.oracle.com/en/learn/ol-lvmraid/>`_
- `Create RAID with LVM <https://blog.programster.org/create-raid-with-lvm>`_
- `Raid1 with LVM from scratch <https://wiki.gentoo.org/wiki/Raid1_with_LVM_from_scratch>`_
- `How to Create a RAID 5 System With LVM Tool and Recover Data After Failures <https://hetmanrecovery.com/recovery_news/how-to-create-software-raid-5-with-lvm.htm>`_
- `RAIDing with LVM vs MDRAID - pros and cons? <https://unix.stackexchange.com/questions/150644/raiding-with-lvm-vs-mdraid-pros-and-cons>`_ 回答中包含了一个完整的指南
