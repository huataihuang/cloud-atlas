.. _update_intel_545s_ssd_firmware:

============================
升级Intel 545s SSD firmware
============================

我的二手 :ref:`hpe_dl360_gen9` 服务器使用了一块我很久以前购买的Intel 545s Series SSD磁盘，不过这块SSD时不时在系统日志中留下触目惊心的Err记录:

.. literalinclude:: smart_monitor/dmesg_ssd_error
   :caption: ``dmesg`` 中SSD磁盘错误日志

找了一下资料，感觉有两种可能:

- SATA连接线存在电气问题
- Firmware存在bug

我感觉Firmware存在bug可能性较大

- 通过 ``smartctl info`` 检查磁盘设备可以看到SN以及firmware版本:

.. literalinclude:: smart_monitor/smartctl_info
   :caption: ``smartctl -i`` 检查磁盘info信息

.. literalinclude:: smart_monitor/smartctl_info_intel
   :caption: ``smartctl -i`` 检查Intel SSD磁盘info信息
   :emphasize-lines: 6

根据 `Latest Firmware For Solidigm™ (Formerly Intel®) Solid State Drives <https://www.solidigmtech.com.cn/support-page/product-doc-cert/ka-00099.html>`_ ``545s系列`` 最新版本是 ``004C`` ，比我目前的 ``002C`` 要高2个版本

关于更新，我有点疑惑，主要是Intel的SSD业务已经卖给了 SK海力士 ( `Solidigm正式宣布成立，成为NAND闪存技术市场领导者 <https://www.businesswire.com/news/home/20211229005332/zh-CN/>`_ 目前在Solidigm网站也能查询到Intel SSD产品信息。Intel官方网站文档 `How to Update the Firmware of an Intel® SSD with the Intel® Memory and Storage Tool <https://www.intel.com/content/www/us/en/support/articles/000056611/memory-and-storage.html>`_ 是针对内存和SSD的混合管理工具。

Intel DC系列SSD升级
====================

`Upgrading the firmware of Intel DC series SSDs in Linux (Debian) <https://carll.medium.com/upgrading-the-firmware-of-intel-dc-series-ssds-in-linux-debian-458a704c087a>`_ 和 `How to update Intel SSD firmware - CentOS <https://advantech-ncg.zendesk.com/hc/en-us/articles/360020806651-How-to-update-Intel-SSD-firmware-CentOS>`_ 分别介绍了在Ubuntu和CentOS上如何升级 **Intel DC系列SSD** (数据中心SSD存储):

- 安装 Intel SSD Data Center Tool (Intel SSD DCT)，也就是 ``isdct`` 工具

- 检查是否有新版本firmware:

.. literalinclude:: update_intel_545s_ssd_firmware/isdct_show_intelssd
   :caption: 使用 ``isdct`` 检查是否有新版Intel SSD firmware

- 执行以下命令升级:

.. literalinclude:: update_intel_545s_ssd_firmware/isdct_load_intelssd
   :caption: 使用 ``isdct`` 升级新版Intel SSD firmware

Intel MAS升级SSD
==================

`Do I need to update firmware with Intel® SSD Firmware Update Tool for intel 535 SSD when using Ubuntu 16.04? [closed] <https://askubuntu.com/questions/798171/do-i-need-to-update-firmware-with-intel-ssd-firmware-update-tool-for-intel-535>`_ 提到使用 `Intel® SSD Firmware Update Tool <https://www.intel.com/content/www/us/en/download/17903/intel-ssd-firmware-update-tool.html?>`_ 是OS无关的工具 ，应该可以升级个人版SSD

下载
==========

- 下载 Intel SSD Firmware Update Tool 4.1:

.. literalinclude:: update_intel_545s_ssd_firmware/Intel_SSD_FUT_4.1
   :caption: 下载 Intel SSD Firmware Update Tool 4.1

解压缩以后可以看到包含了手册和 iso 文件::

   -rw-r--r-- 1 huatai dialout 1.3M Dec 12  2022  322570_Intel_SSD_Firmware_Update_Tool_User_Guide_Rev016US.pdf
   -rw-r--r-- 1 huatai dialout 236K Dec  7  2022  328292_Intel_SSD_Firmware_Update_Tool_Release_Notes_Rev037US.pdf
   -rw-r--r-- 1 huatai dialout  79M Dec 14  2022  issdfut_64_4.1.17.iso
   -rw-r--r-- 1 huatai dialout  14K Dec 14  2022  SHA512__Hash.docx
   -rw-r--r-- 1 huatai dialout  60K Oct 21  2021 'SoftwareLicenseAgreement_Commercial Use.pdf'

我准备周末将硬盘拆机到线下笔记本电脑上，通过笔记本U盘启动来进行更新(服务器重启实在太麻烦了，不利于升级)

参考
======

- `SSD's hard resetting link CentOS 7 <https://unix.stackexchange.com/questions/507383/ssds-hard-resetting-link-centos-7>`_
- `HDD & SSD Linux: Hard resetting link <https://superuser.com/questions/464642/hdd-ssd-linux-hard-resetting-link>`_
- `Latest Firmware For Solidigm™ (Formerly Intel®) Solid State Drives <https://www.solidigmtech.com.cn/support-page/product-doc-cert/ka-00099.html>`_
- `Do I need to update firmware with Intel® SSD Firmware Update Tool for intel 535 SSD when using Ubuntu 16.04? [closed] <https://askubuntu.com/questions/798171/do-i-need-to-update-firmware-with-intel-ssd-firmware-update-tool-for-intel-535>`_
