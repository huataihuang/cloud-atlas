.. _mdadm_partion_vs_disk:

=============================================
mdadm构建RAID时应该使用分区还是直接使用磁盘?
=============================================

在使用 :ref:`mdadm` 构建Linux 软RAID的时候，有一个问题一直困扰我，我应该直接使用整个磁盘(不划分分区)还是在磁盘上划分一个分区(整个磁盘一个分区)？

通常我们用来构建RAID的磁盘都是整块使用的，除非是实验环境(要模拟多种磁盘存储才会划分分区或者 :ref:`linux_lvm` 来模拟多个磁盘块设备)。否则为避免磁盘读写竞争以及避免一块磁盘损坏影响多个分区(可能属于不同raid或同一个raid)，总是会把整块磁盘容量都分给一个RAID。问题是，我们有没有必要在磁盘上划分一个full完整分区再来构建RAID:

参考 `What's the difference between creating mdadm array using partitions or the whole disks directly <https://unix.stackexchange.com/questions/320103/whats-the-difference-between-creating-mdadm-array-using-partitions-or-the-whole>`_ ，简单来说，还是建议先划分分区(占满整个磁盘的单独分区)，然后再使用不同磁盘的分区来构建RAID:

- 在RAID中，我们会使用不同厂商或同一厂商不同批次的磁盘，即使物理磁盘规格看起来一样，实际上整块磁盘还是会略有差异，使用分区可以统一构建物理块设备大小

  - 如果直接使用整个磁盘，则在磁盘故障后必须使用完全相同尺寸的型号进行替换，即使大几MB，由于制造商不同或工艺变化等原因，也会导致磁盘替换失败
  - 随着时间推移，磁盘总会陆续损坏，此时替换的磁盘往往不是最初供应商磁盘或批次或规格，使用分区可以依然保持原有块设备大小
  - 新设备容量大于老设备容量非常常见，当不断替换最终都换成新规格新磁盘后，可以再做容量分区的扩展，实现一个RAID磁盘无缝扩展(嘿嘿，还没有机会实践)
  - 通常厂商的磁盘都有使用寿命，在磁盘出现故障前主动更换磁盘是IDC运维确保数据的关键(使用SMART技术)

    - 对于IDC这种均衡大量读写，通常同一批厂商磁盘的使用寿命相近(前后可能差6个月)
    - 使用上述分区方法可以轮转替换成新规格的磁盘(例如逐步将2TB磁盘替换为4TB磁盘)

- 有报导( `Some Linux Users Are Reporting Software RAID Issues With ASRock Motherboards <https://www.phoronix.com/news/Linux-Software-RAID-ASRock>`_ )主板BIOS可能不能识别磁盘上的MD RAID元数据导致破会RAID(可能UEFI以为在尝试修复GPT分区表)，所以直接使用整个磁盘构建RAID的技术没有得到厂商的兼容测试导致意外

  - 使用分区似乎是社区常规的操作，所以使用的人众多，各个方案验证充分，不容易出现上述冲突损坏
  - 根据他人经验，直接使用整块设备创建RAID，即使在 ``mdadm.conf`` 中保存配置，重启系统也可鞥不会重新组装RAID，并且主板固件可能会覆盖或删除RAID超级块(其实应该就是主板BUG，见上述)


参考
======

- `What's the difference between creating mdadm array using partitions or the whole disks directly <https://unix.stackexchange.com/questions/320103/whats-the-difference-between-creating-mdadm-array-using-partitions-or-the-whole>`_
