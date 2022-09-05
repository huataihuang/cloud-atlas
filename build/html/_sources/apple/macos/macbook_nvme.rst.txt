.. _macbook_nvme:

============================
NvMe硬盘升级MacBook Pro SSD
============================

我在撰写 :ref:`cloud_atlas` 的实践中，采用的是 :ref:`mbp15_late_2013` 。不过，在2021年初尝试重装macOS时发现安装自检程序已经扫描出存储SMART报错，拒绝安装。

.. warning::

   在出现 SMART 报错的磁盘上保存数据是非常危险的，没有特殊原因，务必替换成良好的磁盘硬件。

   `How to Install OSX 10.6 onto a HDD with "S.M.A.R.T failures" --Macbook A1181 <https://www.techsupportforum.com/threads/how-to-install-osx-10-6-onto-a-hdd-with-s-m-a-r-t-failures-macbook-a1181.583692/>`_ 介绍了如何忽略SMART报错安装操作系统的方法。仅供参考

由于2015年MacBook Pro已经使用了 PCIe 2.0x2 存储接口，并且随着macOS升级，已经支持了NVMe存储。所以目前2021年，已经可以采购MVMe存储通过转接卡安装到MacBook中，提升存储性能。

需要注意，苹果的2013-2014年主机和2015年以及之后主机对待休眠方式不同，如果使用NVMe硬盘，早期设备需要防止电脑进入待机状态::

   sudo pmset -a standby 0

设置之后电脑依然可以休眠，但是不会进入Hibernate模式，也就是不会把电脑状态存储到硬盘，完全缓存在内存中。这种模式下电池需要持续供电，所以会缩短电池寿命，并且待机可持续时间也相对较短。不过，对于2015年以及以后的主机不需要这样修改，也就没有这个困扰。

我怀疑休眠其实还是和苹果对NVME设备的兼容性，我仔细查看了NVMe转接卡的淘宝买家评论，发现有人提到三星的NVMe能够正常休眠。所以我最终还是选购了 :ref:`samsung_pm9a1` (也就是我构建 :ref:`priv_cloud_infra` 所用二手服务器的存储)。实践证明，这个选择是明智的， :ref:`samsung_pm9a1` 在我的 :ref:`mbp15_late_2013` 完美运行，不仅读写速度飞快(应该远高于原先的SATA SSD)，而且安装能够支持最高版本 macOS Big Sur 也能完美支持休眠，和原装没有任何差异。

转接卡
========

对于MacBook设备，需要使用 Sintech NGFF转M.2 NVMe适配器

在淘宝上能够找到 ``Acasis m.2 NVME SSD转接头`` 售价20元:

- 适合 ``2013~2017`` 款苹果笔记本(这一阶段笔记本存储没有焊接死在主板上，可以升级)
- 安装前先对macOS做TimeMachine备份
- 必须使用 ``NVMe M.2 SSD`` 才能识别使用，不能使用SATA协议的M.2 NGFF硬盘
- 笔记本之前必须安装过 macOS 10.13.6 版本或更高版本，因为从 macOS 10.13.6开始的firmware(操作系统安装升级时会更新firmware)才包含NVMe支持，此时安装系统才能成功
- 硬盘分区必须是GPT分区格式，否则安装时不能识别
- 不能使用网络恢复方式安装系统，必须制作一个 10.13.6 或更高版本macOS安装U盘来安装
- 安装完成后，可以从TimeMachine备份中恢复数据

.. note::

   2022年9月，我终于购买了 :ref:`samsung_pm9a1` ，毫无阻碍地完成了系统安装，证明第三方NVMe可以完美升级 :ref:`mbp15_late_2013`

虚拟化解决方案(瞎想想,未实践)
==============================

虽然我很想省钱，但是迁移iCloud账号， :ref:`transfer_icloud_photos` 需要本地电脑有巨大的转存空间，以便能够将iCloud中的照片原生文件下载下来。当前能够使用的MacBook笔记本只有250GB数据，不够存储原先旧账号的所有数据。难道我不得不购买 NVMe 存储来替换存在SMART报错的SSD磁盘么？(以便安装macOS)

``贫穷拓展了我的想象`` :

- 使用 :ref:`osx_kvm` : 这样可以利用我现有的 :ref:`hpe_dl360_gen9` 二手服务器加上采用3块 :ref:`samsung_pm9a1` 构建运行在 :ref:`ovmf` 上的 :ref:`ceph` 存储，可以为macOS虚拟分配 512GB 存储
- 通过挑战macOS虚拟机，实现一种虚拟化加速运行的远程macOS开发环境，为后续开发工作打基础
- 验证 :ref:`iommu` 的性能以及 :ref:`nvidia_vgpu` 技术

此外，探索在虚拟化环境中运行Windows虚拟机

参考
=====

- `教程：如何使用NVMe硬盘升级旧款Mac的SSD <https://www.sohu.com/a/414599050_99956743>`_
