.. _backup_restore_pi_by_tar:

============================
使用tar备份和恢复树莓派系统
============================

在 :ref:`pi_5_nvme_boot` 设置使用之后，系统的存储性能有了很大提高。但是，我在 :ref:`pi_5` 上使用 :ref:`intel_optane_m10` 遇到一个棘手的问题: 启动时不能稳定识别Optane(傲腾) M10。参考树莓派论坛的帖子，提到了需要回退到使用SD卡启动，仅将Optane作为数据存储。 我推测原因是:

- Optane初始化需要在内核就绪之前进行，当使用 :ref:`nvme` 存储启动时，启动速度极快，此时Optane初始化尚未完成，就导致内核没有扫描到设备。
- 当使用SD卡启动时，由于内核加载启动较慢，此时Optane设备已经完成初始化，就能够被内核识别和使用
- 之所以 :ref:`pi_5_nvme_boot` 有时候能够识别和使用Optane存储是因为这个初始化时间临界点就在NVMe启动内核左右，当有启动时间波动时，有可能成功识别也可能识别失败

.. note::

   经过验证对比，上述推测并不正确，即使改换为使用SD启动，依然不能解决 :ref:`intel_optane_m10` 识别。我最终解决的方法是采用 :ref:`pi_5_overclock`

不过，通过tar备份和恢复树莓派依然是有效的方案，不仅克服了 :ref:`clone_pi_by_dd` 效率较低的问题( ``dd`` 会复制整个磁盘每一bit)，而且适合不同存储容量之间复制树莓派系统。

``tar`` 备份树莓派
======================

- 树莓派操作系统 :ref:`raspberry_pi_os` 默认安装使用了2个分区，磁盘分区依然参照之前 :ref:`raspberry_pi_os` 安装时分区(但是我会调整整个分区大小限制到 ``32GB`` 以空出更多容量用于 :ref:`zfs` 卷的数据存储)，即:

.. literalinclude:: backup_restore_pi_by_tar/fdisk
   :caption: :ref:`pi_5_nvme_boot` 上分区，其中分区1，2是操作系统，也就是复制的源
   :emphasize-lines: 10,11

- 注意当前 :ref:`raspberry_pi_os` 磁盘分区的挂载如下:

.. literalinclude:: backup_restore_pi_by_tar/df
   :caption: 当前 :ref:`raspberry_pi_os` 磁盘分区的挂载
   :emphasize-lines: 4,7

需要备份的是 ``/`` 和 ``/boot/firmware`` ； ``/var/lib/docker`` 是一个 :ref:`zfs` 挂载卷，不需要备份(当 :ref:`docker` 再次启动时会自动初始化，所以只需要确保目标主机上在启动docker之前先构建好 ``zpool-data`` 卷)

- 将TF卡插入USB读卡器然后插入到需要复制的树莓派运行系统中，使用以下命令构建 ``/dev/sdb`` 分区(即TF卡)

.. literalinclude:: backup_restore_pi_by_tar/parted
   :caption: 划分TF卡分区，分区限制到32GB

- 对分区进行格式化，注意第一个分区必须是 ``FAT32``

.. literalinclude:: backup_restore_pi_by_tar/mkfs
   :caption: 对SD卡分区进行格式化

- 参考 :ref:`recover_system_by_tar` 执行以下命令备份(在运行主机上先归档整个操作系统):

.. literalinclude:: backup_restore_pi_by_tar/tar
   :caption: 使用 ``tar`` 命令备份系统

- 挂载TF卡分区:

.. literalinclude:: backup_restore_pi_by_tar/mount
   :caption: 对TF卡分区挂载

- 将归档的操作系统tar文件复制到TF卡挂载分区中，并解压缩

.. literalinclude:: backup_restore_pi_by_tar/restore
   :caption: 恢复系统

- 修订一些配置( :ref:`edge_cloud_infra_2024` ):

  - ``/mnt/etc/hosts``
  - ``/mnt/etc/hostname``
  - ``/mnt/etc/fstab``
  - ``/mnt/etc/NetworkManager/system-connections/eth0.nmconnection``
  - ``/mnt/NetworkManager/system-connections/<wifi_ssid>.nmconnection``

- 现在将恢复好的系统TF卡拿到目标树莓派上，启动新的树莓派，然后验证是否一切正常

- 构建 :ref:`pi_5_nvme_zfs` (用于恢复 :ref:`docker_zfs_driver` ) - 这个步骤是我的特定运行环境需要，如果你没有使用 :ref:`zfs` 可以忽略

.. literalinclude:: backup_restore_pi_by_tar/zfs
   :caption: 在新系统上构建ZFS用于恢复 :ref:`docker_zfs_driver`
