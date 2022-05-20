.. _gpt:

===============
GPT分区表
===============

GPT分区表支持多少分区?
========================

我在 :ref:`hpe_dl360_gen9` 服务器上安装 :ref:`samsung_pm9a1` :ref:`nvme` 存储，构建 :ref:`priv_cloud_infra` 所需要的存储服务。由于硬件设备有限，我计划在3块NVMe的 :ref:`ovmf` 虚拟机构建多种需要高速存储支持的服务: :ref:`ceph` , :ref:`redis` , :ref:`mysql` , :ref:`pgsql` ... 

这就带来一个问题: 如果我不使用 :ref:`linux_lvm` ( :strike:`性能考虑需要降低存储层次` LVM卷管理实际上对性能影响微乎其微，但是给存储管理代理极大便利，所以建议生产环境使用LVM卷管理) 而采用简洁的分区表，那么一块磁盘究竟支持多少(primary)分区?

我从开始学习计算机(第一本启蒙书是 《MS-DOS技术大全》)，就知道DOS的MBR分区只支持最多4个primary partition，即使将第4个分区改成扩展分区，也只能支持有限的26个英文字母命名的(扩展分区之上的)逻辑分区。显然，我不愿使用逻辑分区(一旦逻辑分区出错会毁掉所在扩展分区上所有逻辑分区)，但是4个主分区也不能满足我众多的服务部署要求。

现代操作系统都开始使用GPT分区表，特别是2T以上磁盘只能使用GPT分区表。那么GPT分区表能否解决这个问题，GPT分区表最多直至多少分区呢?

遇事不决问谷歌: 果然在Google搜索中输入 ``how many primary partitions are supported on gpt disks`` (其实是google提示) 赫然给出答案:

``128 partitions``

成了，可以直接使用GPT分区来构建之后多服务的虚拟机存储。不过，对于GPT分区表，我还需要再学习和巩固知识，后续补上...

参考
========

- `wikipedia: GUID Partition Table <https://en.wikipedia.org/wiki/GUID_Partition_Table>`_
- `What’s the Difference Between GPT and MBR When Partitioning a Drive? <https://www.howtogeek.com/193669/whats-the-difference-between-gpt-and-mbr-when-partitioning-a-drive/>`_
- `Midrosoft Windows Manufacture Desktop manufacturing: UEFI/GPT-based hard drive partitions <https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/configure-uefigpt-based-hard-drive-partitions?view=windows-11>`_
- `What Is GPT Disk and How to Manage GPT Disk <https://www.easeus.com/partition-master/partition-gpt-disk.html>`_
