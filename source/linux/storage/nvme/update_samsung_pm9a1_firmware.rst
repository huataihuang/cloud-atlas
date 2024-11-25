.. _update_samsung_pm9a1_firmware:

==================================
更新三星PM9A1 NVMe存储firmware
==================================

问题排查
==========

我最初在2021年10月购买了3个 :ref:`samsung_pm9a1` 用于在 :ref:`hpe_dl360_gen9` :ref:`ceph_deploy` ，感觉还不错，所以2022年9月又购买了1个 :ref:`samsung_pm9a1` 用于 :ref:`mbp15_late_2013_update_nvme` ，也很顺利。但是，2024年11月，当我尝试在 :ref:`pi_5` 构建 :ref:`pi_soft_storage_cluster` 遇到了麻烦:

- :ref:`pi_5_pcie_m.2_ssd` 我最初尝试利旧我的 :ref:`samsung_pm9a1` ，但是发现不能识别(使用了从 :ref:`hpe_dl360_gen9` 拆下的 :ref:`samsung_pm9a1` ，这一步骤埋下了问题；不得已又投资了3块 :ref:`kioxia_exceria_g2` ，现在想来都是泪)， :ref:`pi_5` 启动时监测到 :ref:`samsung_pm9a1` 响应超时而无法识别:

.. literalinclude:: update_samsung_pm9a1_firmware/pm9a1_err
   :caption: 树莓派启动时激活 :ref:`samsung_pm9a1` 失败
   :emphasize-lines: 3,4

- 因为最近购买的 :ref:`4_nvme_usb_disk` 准备利旧4个 :ref:`samsung_pm9a1` (3个原先用于 :ref:`hpe_dl360_gen9` ，1个用于 :ref:`mbp15_late_2013_update_nvme` )，我惊奇地发现只能识别出1个 :ref:`samsung_pm9a1` (不管怎么安装槽顺序)。不可能3个NVMe存储同时损坏，我尝试用U盘转接盒，才发现原来当初2021年10月购买的3块 :ref:`samsung_pm9a1` 都无法用于U盘转接盒(不识别)

- 我的 :ref:`mbp15_late_2013_update_nvme` 能够使用NVMe SSD，我把原先用于 :ref:`hpe_dl360_gen9` 的 :ref:`samsung_pm9a1` 替换到 :ref:`mbp15_late_2013_update_nvme` 中。正如所料，居然不能用于笔记本 -- 但是这3块 NVMe 是能够用于服务器 :ref:`hpe_dl360_gen9`

- 我突然想到当初在 :ref:`pi_5` 的 :ref:`pi_5_pcie_m.2_ssd` 验证使用 :ref:`samsung_pm9a1` 失败，其实只测试了 :ref:`hpe_dl360_gen9` 服务器上的 :ref:`samsung_pm9a1` : 当时没有想到两批购买的NVMe存储还有区别。果然，我在 :ref:`pi_5` 上使用 :ref:`mbp15_late_2013_update_nvme` 验证过正常的 :ref:`samsung_pm9a1` ，就是能够正常使用的。

咨询了淘宝卖家，提到了NVMe的firmware升级，有道理!

- 使用 :ref:`nvme-cli` 检查:

.. literalinclude:: nvme-cli/nvme_list
   :caption: 列出系统安装NVMe

看出了差异 -- 以下是正常的 :ref:`samsung_pm9a1` :

.. literalinclude:: update_samsung_pm9a1_firmware/nvme_list_output
   :caption: 工作正常的 :ref:`samsung_pm9a1` ，注意firmware版本 ``GXA7601Q``

而翻看一下不能用于U盘的异常 :ref:`samsung_pm9a1` :

.. literalinclude:: nvme-cli/nvme_list.txt
   :language: bash
   :caption: 不能用于U盘的异常 :ref:`samsung_pm9a1` ，注意firmware版本 ``GXA7401Q``

所以基本可以推测出，至少需要升级 :ref:`samsung_pm9a1` 的firmware到版本 ``GXA7601Q`` 才能解决问题

升级firmware
================

由于 :ref:`samsung_pm9a1` 是OEM版本，三星官方没有直接提供firmware下载，所以我是通过搜索对比发现以下两个方案可能性较高:

- `联想 Critical Firmware Update for Samsung drives - ThinkStation <https://pcsupport.lenovo.com/us/en/products/workstations/thinkstation-p-series-workstations/thinkstation-p340-tiny/solutions/ht516311-critical-firmware-update-for-samsung-drives-thinkstation>`_ 这篇更新文档较为全面，不仅提供了Windows也提供了Linux更新方法。对比方法可以看到，实际上联想的Linux更新方法就是标准的Linux通过LVFS完成更新，考虑到淘宝上联想的OEM SSD很普遍，且更新方法是标准方式，所以我尝试用此方案
- `Samsung SSD PM9A1-00B00 Firmware Update <https://www.reddit.com/r/pcmasterrace/comments/q2o52p/samsung_ssd_pm9a100b00_firmware_update/>`_ 获得升级firmware信息，下载 

Linux提供了一个名为 ``fwupdmgr`` 的客户端工具来管理firmware升级，可以自动、安全、可靠地完成firmware升级，也可以用于Samsung SSD。 ``fwupd`` 服务可以工作在Linux和BSD系统上，是 `LVFS <https://lvfs.readthedocs.io/en/latest/>`_ 的组成部分。

- 检查 `LVFS设备列表 <https://fwupd.org/lvfs/devices/>`_ 看看需要更新的SSD是否提供，例如使用 ``PM9A1`` 搜索，可以看到Dell，HP，Lenovo都提供了firmware
- 使用 ``fwupd`` 更新SSD firmware:

.. literalinclude:: update_samsung_pm9a1_firmware/fwupdmgr_get-devices
   :caption: 获取设备列表

- 执行以下命令从 `LVFS <https://lvfs.readthedocs.io/en/latest/>`_ 服务器下载和刷新 metadata (元数据):

.. literalinclude:: update_samsung_pm9a1_firmware/fwupdmgr_refresh
   :caption: 从LVFS服务器下载刷新metadata

- 最后执行升级:

.. literalinclude:: update_samsung_pm9a1_firmware/fwupdmgr_update
   :caption: 执行firmware升级

参考
=======

- `How To Update Samsung SSD Firmware on Linux <https://www.cyberciti.biz/faq/upgrade-update-samsung-ssd-firmware/>`_ 提供了完整指南，本文升级方法参考此文档
- `Samsung SSD PM9A1-00B00 Firmware Update <https://www.reddit.com/r/pcmasterrace/comments/q2o52p/samsung_ssd_pm9a100b00_firmware_update/>`_ 提供了2023年3月1日的 7801 FW Version for PM9A1: 注意下载链接zip解压缩以后 ``GXA`` 开头bin文件是用于1T规格， ``GXB`` 开头bin文件是用于2T规格 (我理解是通过 :ref:`nvme-cli` 完成)
- `三星存储官网firmware FAQ <https://semiconductor.samsung.com/consumer-storage/support/faqs/internalssd-fw-sw/>`_ 指出 可以从 `www.samsung.com/ssd <https://www.samsung.com/sec/>`_ 或 `www.samsung.com/samsungssd <https://semiconductor.samsung.com/consumer-storage/support/>`_ 下载firmware更新，但是三星官方网站提供的是直接从三星购买的终端用户产品系列，例如 SSD-850 EVO / SSD-850 PRO等；而我购买的 :ref:`samsung_pm9a1` 是OEM产品，需要从不同的厂商下载更新firmware
- `Dell Samsung PM9A1 固态硬盘固件更新 <https://www.dell.com/support/home/zh-cn/drivers/driversdetails?driverid=58wkd>`_ Dell的Samsung PM9A1，不过是Windows版本，发布日期是 2023年7月31日
- `联想 Samsung PM9A1 NVMe Solid State Drive Firmware Update Utility for Windows 10 (64-bit), Windows 11 (64-bit) - Desktops <https://pcsupport.lenovo.com/us/en/products/workstations/thinkstation-p-series-workstations/thinkstation-p340-tiny/downloads/ds561921-samsung-pm9a1-nvme-solid-state-drive-firmware-update-utility-for-windows-10-64-bit-windows-11-64-bit-desktops>`_ 也是Windows版本，发布日期是 2023年5月16日
- `联想 Critical Firmware Update for Samsung drives - ThinkStation <https://pcsupport.lenovo.com/us/en/products/workstations/thinkstation-p-series-workstations/thinkstation-p340-tiny/solutions/ht516311-critical-firmware-update-for-samsung-drives-thinkstation>`_ 这篇更新文档较为全面，不仅提供了Windows也提供了Linux更新方法。对比方法可以看到，实际上联想的Linux更新方法就是标准的Linux通过LVFS完成更新，我理解联想其实就是采用三星官方方法
