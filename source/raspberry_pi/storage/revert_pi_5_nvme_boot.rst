.. _revert_pi_5_nvme_boot:

============================
回滚树莓派5使用nvme存储启动
============================

在 :ref:`pi_5_nvme_boot` 设置使用之后，系统的存储性能有了很大提高。但是，我在 :ref:`pi_5` 上使用 :ref:`intel_optane_m10` 遇到一个棘手的问题: 启动时不能稳定识别Optane(傲腾) M10。参考树莓派论坛的帖子，提到了需要回退到使用SD卡启动，仅将Optane作为数据存储。 我推测原因是:

- Optane初始化需要在内核就绪之前进行，当使用 :ref:`nvme` 存储启动时，启动速度极快，此时Optane初始化尚未完成，就导致内核没有扫描到设备。
- 当使用SD卡启动时，由于内核加载启动较慢，此时Optane设备已经完成初始化，就能够被内核识别和使用
- 之所以 :ref:`pi_5_nvme_boot` 有时候能够识别和使用Optane存储是因为这个初始化时间临界点就在NVMe启动内核左右，当有启动时间波动时，有可能成功识别也可能识别失败

回滚操作
========

- 我的SD卡磁盘分区依然参照之前 :ref:`raspberry_pi_os` 安装时分区(实际就是安装盘，所以分区没有调整修改)，即:

.. literalinclude:: revert_pi_5_nvme_boot/fdisk
   :caption: SD卡磁盘分区
   :emphasize-lines: 9,10

- 对分区进行格式化，注意第一个分区必须是 ``FAT32``

.. literalinclude:: revert_pi_5_nvme_boot/mkfs
   :caption: 对SD卡分区进行格式化

- 挂载分区:

.. literalinclude:: revert_pi_5_nvme_boot/mount
   :caption: 对SD卡分区挂载

- 参考 :ref:`recover_system_by_tar` 执行以下命令备份:

.. literalinclude:: revert_pi_5_nvme_boot/tar
   :caption: 使用 ``tar`` 命令备份系统
