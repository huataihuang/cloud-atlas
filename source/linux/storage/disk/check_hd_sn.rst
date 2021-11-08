.. _check_hd_sn:

====================
检查硬盘SN
====================

我在实践 :ref:`pcie_bifurcation` 时候，需要在NVMe扩展卡上安装多个NVMe SSD磁盘。启动服务器之后，识别出2个NVMe SSD，需要确认是识别了哪2个NVMe SSD。

有不少Linux工具可以获得硬盘信息，例如 :ref:`hwinfo` ，但是并不是所有工具能够获得硬盘SN，而且随着存储技术发展，传统的机械磁盘逐渐被SSD或者 :ref:`nvme` SSD 替代，一些原本维护HDD的工具并不能兼容新的固态硬盘检查维护。

smartctl(推荐)
==================

``smartctl`` 是 ``smatmontools`` 工具包的组件，提供了 :ref:`smart_monitor` 功能。这是一个非常适合检查服务器存储的工具，而且对SSD和NVMe SSD的兼容也非常好。这个工具是我实践下来可以检查NVMe SSD的最佳程序。

- 安装 ``smartmontools`` ::

   sudo apt install smartmontools

- 检查NVMe::

   sudo smartctl -i /dev/nvme0n1

同理检查不同的NVMe磁盘，分别输出如下:

.. literalinclude:: check_hd_sn/smartctl_nvme.txt
   :language: bash

- ``smartctl`` 还支持对SSD硬盘检查::

   sudo smartctl -i /dev/sda

输出类似:

.. literalinclude:: check_hd_sn/smartctl_ssd.txt
   :language: bash

- 使用 ``smartctl`` 检查机械硬盘::


   sudo smartctl -i /dev/sdb

目前服务器上有3个机械硬盘，输入如下:

.. literalinclude:: check_hd_sn/smartctl_hdd.txt
   :language: bash

lshw
===========

``lshw`` 类似 :ref:`hwinfo` 工具，支持DMI(只用于x86和IA-64)，OpenFirmware设备树(PowerPC), PCI/AGP, CPUID(x86),IDE/ATA/ATAPI, PCMCIA,SCSI和USB。

- 使用 ``lshw`` 检查磁盘::

   sudo lshw -class disk

实际上 ``lshw`` 对传统HDD支持较好，但是不能完整展示NVMe SSD信息::

     *-namespace               
          description: NVMe namespace
          physical id: 1
          logical name: /dev/nvme0n1
          size: 953GiB (1024GB)
          configuration: logicalsectorsize=512 sectorsize=512
   ...
     *-disk
          description: ATA Disk
          product: INTEL SSDSC2KW51
          physical id: 0.0.0
          bus info: scsi@0:0.0.0
          logical name: /dev/sda
          version: 002C
          serial: BTLA7513037S512DGN
          size: 476GiB (512GB)
          capabilities: gpt-1.00 partitioned partitioned:gpt
          configuration: ansiversion=5 guid=3cdb3a71-60d4-41f2-884f-c347b9dcae21 logicalsectorsize=512 sectorsize=512

hdparm
============

``hdparm`` 也是传统的HDD检测工具，适合机械硬盘和SSD，但是不支持NVMe SSD设备::

   sudo hdparm -i /dev/nvme0n1

提示错误::

   /dev/nvme0n1:
    HDIO_DRIVE_CMD(identify) failed: Inappropriate ioctl for device
    HDIO_GET_IDENTITY failed: Inappropriate ioctl for device

- ``hdparm`` 支持SATA接口的SSD::

   sudo hdparm -i /dev/sda

显示::

   /dev/sda:
   
    Model=INTEL SSDSC2KW512G8, FwRev=LHF002C, SerialNo=BTLA7513037S512DGN
    Config={ Fixed }
    RawCHS=16383/16/63, TrkSize=0, SectSize=0, ECCbytes=0
    BuffType=unknown, BuffSize=unknown, MaxMultSect=16, MultSect=off
    CurCHS=16383/16/63, CurSects=16514064, LBA=yes, LBAsects=1000215216
    IORDY=on/off, tPIO={min:120,w/IORDY:120}, tDMA={min:120,rec:120}
    PIO modes:  pio0 pio3 pio4 
    DMA modes:  mdma0 mdma1 mdma2 
    UDMA modes: udma0 udma1 udma2 udma3 udma4 udma5 *udma6 
    AdvancedPM=yes: unknown setting WriteCache=disabled
    Drive conforms to: unknown:  ATA/ATAPI-2,3,4,5,6,7
   
    * signifies the current active mode

- ``hdparm`` 也支持SATA的HDD::

   sudo hdparm -i /dev/sdb

输出::

   /dev/sdb:
   
    Model=ST9500420AS, FwRev=0001BSM2, SerialNo=5VJ9R32K
    Config={ HardSect NotMFM HdSw>15uSec Fixed DTR>10Mbs RotSpdTol>.5% }
    RawCHS=16383/16/63, TrkSize=0, SectSize=0, ECCbytes=4
    BuffType=unknown, BuffSize=16384kB, MaxMultSect=16, MultSect=16
    CurCHS=16383/16/63, CurSects=16514064, LBA=yes, LBAsects=976773168
    IORDY=on/off, tPIO={min:120,w/IORDY:120}, tDMA={min:120,rec:120}
    PIO modes:  pio0 pio1 pio2 pio3 pio4 
    DMA modes:  mdma0 mdma1 mdma2 
    UDMA modes: udma0 udma1 udma2 udma3 udma4 udma5 *udma6 
    AdvancedPM=yes: unknown setting WriteCache=disabled
    Drive conforms to: unknown:  ATA/ATAPI-4,5,6,7
   
    * signifies the current active mode


参考
======

- `How to Check the Hard Disk Serial Number in Linux <https://www.bettertechtips.com/linux/check-hard-disk-serial-number-linux/>`_
