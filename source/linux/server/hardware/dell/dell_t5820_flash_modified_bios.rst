.. _dell_t5820_flash_modified_bios:

============================
Dell T5820刷入修改过的BIOS
============================

.. _external_eeprom_flasher:

外部EEPROM烧录器
====================

T5820主板BIOS芯片
-------------------

在主板CMOS电池旁边可以找到BIOS芯片，通常是Winbond(华邦), MXIC(旺宏)或Micron(美光)。我在主板CMOS电池旁边找到了芯片 ``winbond 25Q256JVFQ 1829`` :

.. figure:: ../../../../_static/linux/server/hardware/dell/winbond_25Q256JVFQ_1829.jpg

   ``winbond 25Q256JVFQ 1829`` BIOS芯片

- ``25Q256JVFQ`` : ``JV`` 结尾代表 ``3.3V`` ，在淘宝上购买的 **CH341A编辑器+转接板+SOP16夹子线** 默认提供的就是3V，可直接使用(如果芯片是1.8V还需要1.8V适配器)
- 芯片左下角有一个凹陷小圆坑（旁边印着数字 1）， ``SOP16`` 夹子上的红线必须对准这个圆坑所在的引脚
- 芯片引脚表面有一层淡淡的氧化层或助焊剂残留: 在使用SOP16夹子是，需要用酒精擦拭一下 16 个引脚，能极大地提高“识别成功率”

CH341A/B编程器
-----------------

淘宝上可以购买到非常经济实惠的外接EEPROM烧录器(CH341A/B编程器)，需要注意根据自己主板上BIOS芯片的引脚数选购SOP8夹子线或SOP16夹子线(T5820)，只需要24RMB包邮到家。

第一次使用我确实有点惴惴不安，不过我发现 `How to Fix a Corrupted BIOS with a $5 Programmer | CH341A BIOS Flash Tutorial <https://www.youtube.com/watch?v=mSLKlLcOAKM>`_ 视频简短但解析非常清晰，只要你仔细观看步骤就能正确完成 **CH341A/B编程** 的组装: 关键点在于选择正确选择 ``BIOS 25 SPI`` 插槽以及 ``1-2 编程`` 跳线(卖家发货默认就是)，此外确保连线红色线插在1号空就可以了。唯一让我疑惑的是gemini告知我连线红色线对应的SOP16夹子位置应该对着主板芯片的凹陷标记，但是买到的配套夹子正好相反。幸运的是，这个相反标记没有关系，因为如果插反了连线，编程器上的红色指示灯不亮，你就知道线接反了。

.. note::

   我后来看了淘宝买家的评论，原来淘宝卖家就能提供NeoProgrammer软件!!!

   不过我是自己折腾寻找软件，并且最后还是使用Linux平台开源的 :ref:`flashrom` 来完成BIOS烧录的

.. _neoprogrammer:

NeoProgrammer
=================

``NeoProgrammer`` 是一个现代化的社区驱动的CH341A USB编程器软件，特别适合读取、写入和刷新24和25系列flash memory芯片(通常用于BIOS修复)。它提供了一个易用的管理芯片数据和支持大
多数IC的交互界面。

.. warning::

   我发现一个非常糟糕的事情: ``NeoProgrammer`` 并 **不是一个开源软件!!!**

   在网上搜索到的这个软件似乎是很久以前流传在网上的一个执行程序，虽然很好用并且在很多刷机论坛中能找到。但是没有人能保证这个windows软件的安全性，从 `NeoProgrammer infected my laptop #18 <https://github.com/YTEC-info/CH341A-Softwares/issues/18>`_ 讨论可以看到，即使我通过google搜索推荐的这个仓库，也有很多人已经报告这个仓库中提供的Windows版本NeoProgrammer已经感染了病毒!!!

   目前看来只能根据网友反馈信息来判断选择可能较为安全的软件仓库(非开源软件的弊端)

   如果要绝对安全，可以采用 `tomek-o/CH341A-tool <https://github.com/tomek-o/CH341A-tool>`_ 维护发布的 `tomek-o/CH341A-tool Releases <https://github.com/tomek-o/CH341A-tool/releases>`_ 这个仓库的维护者创建的网站 `tomeko.net CH341A tool <https://tomeko.net/software/CH341A_tool/>`_ ，虽然软件比较陈旧(使用Tubo C++ Explorer 2006编译)，也很古旧，但是是一个开源软件，安全性有所保障!!!

.. note::

   请使用 :ref:`winpe` 的只读环境在内存中运行，不要有任何重要数据的主机上运行可疑程序!!!

`How to Fix a Corrupted BIOS with a $5 Programmer | CH341A BIOS Flash Tutorial <https://www.youtube.com/watch?v=mSLKlLcOAKM>`_ 提供了非常简洁清晰的说明，非常专业地提供了NeoProgrammer和CH341A驱动的下载链接:

- `CH341A驱动 <https://www.wch-ic.com/downloads/CH341PAR_EXE.html>`_
- `NeoProgrammer New Update V2.2.0.10 ch341a <https://real4web.com/en/neoprogrammer-new-update-v2-2-0-10/>`_
- 我在Google中也找到 `Download Neoprogrammer for CH341A | Neo Programmer 2.2.0.10 Latest Update <https://real4web.com/en/download-neoprogrammer-for-ch341a-neo-programmer-2-2-0-10-latest-update/>`_

使用 ``NeoProgrammer`` 驱动和软件

- 取出 T5820 CMOS电池，然后按几次主机电源按钮放电，避免影响烧录
- 夹好芯片，在软件里选 ``W25Q256JV``
- 备份，得到 ``32MB`` 的bin文件

.. note::

   我遇到一个问题: 在使用 :ref:`ventoy` 运行 :ref:`winpe` ，但是发现安装 `CH341A驱动 <https://www.wch-ic.com/downloads/CH341PAR_EXE.html>`_ 失败，所以我最后没有使用Windows平台的NeoProgrammer，而是采用下文Linux平台的 ``flashrom`` 完成

.. _flashrom:

flashrom
===========

Linux环境下有一个开源软件 `flashrom <https://flashrom.org/>`_ 在Ubuntu发行版中包含，命令行操作，所以使用可能不如图形界面直观

- 在 :ref:`alpine_linux` 环境下安装 ``flashrom`` :

.. literalinclude:: dell_t5820_flash_modified_bios/install
   :caption: 安装 ``flashrom``

- 在完成了上文 **CH341A/B编程器** 连接之后，执行检测命令，这样能够确认CH341A/B编程器工作正常:

.. literalinclude:: dell_t5820_flash_modified_bios/check
   :caption: 检查确认flashrom工作正常

实际上需要小心的连接CH341A/B编程器，特别是SOP16夹子，我也是尝试了两次调整SOP16夹子才正确读取出BIOS，输出显示检测出两个类型的winbond flash chip:

.. literalinclude:: dell_t5820_flash_modified_bios/check_output
   :caption: flashrom检测出2个型号的winbond flash chip
   :emphasize-lines: 1,2

- 执行两次读取备份，并对比保存两次bin文件的校验码，以确认CH341A/B编程器连接和电气读写正常:

.. literalinclude:: dell_t5820_flash_modified_bios/backup
   :caption: 执行2次备份BIOS

经过对比2次备份BIOS bin文件的哈希值一致，基本说明备份是可信的，这样就能放心修改BIOS文件

.. note::

   Winbond 的 W25Q256 系列有很多子型号（FV, JV, JW 等），它们的 JEDEC ID（芯片内部的身份代码）非常接近。flashrom 识别到了代码，但无法确定是老款的 FV 还是 JV 系列。

   根据之前观察到的芯片丝印 ``25Q256JV`` ，应该选择 ``W25Q256JV_Q`` 。

.. note::

   这里备份得到的 ``bin`` 文件可以解决我之前在 :ref:`dell_t5820_config_aperture_size` 反复尝试都失败没能正确提取的bin文件问题。这是一个完整的包含主机Service Tag等信息的BIOS bin，甚至不会引发Windows授权失效。

- **现在可以开始** :ref:`dell_t5820_rebaruefi`

参考
======

- gemini
- `xCuri0/ReBarUEFI: List of working motherboards #11 <https://github.com/xCuri0/ReBarUEFI/issues/11>`_ 用户 @zhiwoo 提供了 Dell Precision T5810 的实践信息: **External EEPROM flasher required. Dell BIOS flasher would not allow the flashing of modified BIOS.** 这启发了我找寻外部EEPROM烧录器来实现BIOS备份和定制
- `How to Fix a Corrupted BIOS with a $5 Programmer | CH341A BIOS Flash Tutorial <https://www.youtube.com/watch?v=mSLKlLcOAKM>`_ 关于烧录BIOS的简洁视频，推荐
- `Programming a Motherboard's BIOS chip - UEFI Crash Course Part 1  <https://www.youtube.com/watch?v=kB7scNyY8Ck>`_ 一个关于维修硬件的解析视频，很有意思
