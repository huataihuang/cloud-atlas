.. _dl360_bios_upgrade:

=====================
HPE DL360 BIOS升级
=====================

HP服务器的驱动升级以及各种软件包下载都需要购买HPE服务，这对个人购买的二手服务器显然不合适。

.. note::

   在eBay上有 ``HPE Service Pack ProLiant SPP HP Latest G7 G8 G9 G10 Servers - Direct Download`` 销售，SSP包括了HPE不同型号服务器的升级包，售价约50美金。

我购买的二手 :ref:`hpe_dl360_gen9` 服务器是 2015年8月8日 的BIOS版本，所以我想能够升级到最新的BIOS以便增加稳定性和性能。

下载
=========

Reddit的帖子 `HPE DL380 Gen 9 Firmware/Bios update <https://www.reddit.com/r/homelab/comments/k037h2/hpe_dl380_gen_9_firmwarebios_update/>`_ 提供了线索: 根据 ``SPP for G9 and G10`` 关键字在Google搜索，果然可以找到下载资源::

   Gen9/Gen10 Production SPP:
   Link: P35938_001_spp-2021.05.0-SPP2021050.2021_0504.129.iso
   Size: 9.99 GB
   MD5: 2a869e4138e2ac0e1cd09cd73c8faf70
   SHA1: 73fbd4f4c97c4928944cd9330132764a09d49de2
   SHA256: b98c578bf96e4ebed8645236a70d5df4d104d37238e5d17d59387888db5ae106

.. note::

   下载建议使用 :ref:`axel` 加速

下载(更新)
===========

后来我发现，实际上完全可以根据HP官方的支持网站提供的BIOS更新文件名，通过google搜索找到下载文件，例如最新的BIOS更新文件是 ``P89_2.90_04_29_2021.signed.flash``

- `reddit: HPE DL360/DL380 gen9 firmware updates out of warranty r/homelab <https://www.reddit.com/user/redvex2460/>`_ 提供了下载资源对应的是 `* RECOMMENDED * Online ROM Flash Component for VMware - HPE ProLiant DL380 Gen9/DL360 Gen9 (P89) Servers <https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX-d65122cec6514a5d8d6eb7c386#tab2>`_ 

解压缩 ``CP047834.zip`` 文件后，获得的一个文件 ``CP047834.vmfile`` 其实包含了 ``P89_2.90_04_29_2021.signed.flash`` ，但是解压缩比较繁琐，需要通过 ``7zip`` 解压缩::

   7zz x CP047834.vmfile

此时会生成一个临时文件 ``scexe_tmp6469`` ，通过 ``file scexe_tmp6469`` 可以看到这个文件是标准tar::

   scexe_tmp6469: POSIX tar archive (GNU)

再解包::
 
   tar xf scexe_tmp6469

就可以获得最终文件 ``P89_2.90_04_29_2021.signed.flash`` ，请根据HPE官方下载页面 `System ROM Flash Binary - HPE ProLiant DL380 Gen9/DL360 Gen9 (P89) <https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_68f3978e0a8e4e56b66a1d3a09#tab2>`_ 提供的checksum值进行校验::

   sha256sum P89_2.90_04_29_2021.signed.flash

输出应该是::

   5c5aa4afce91fac98cd61ddaa6b86827af94de6f5dfae5afbe6a27868099dce0  P89_2.90_04_29_2021.signed.flash

升级准备
==========

.. note::

   请注意，虽然我下载了 SPP ISO 文件，但是我发现还不是最终最新版本，所以我采用了上文通过google找到的 ``P89_2.90_04_29_2021.signed.flash`` 来更新BIOS

- 挂载下载的iso文件::

   sudo mount -o loop P35938_001_spp-2021.05.0-SPP2021050.2021_0504.129.iso /media

- 为了方便浏览信息，可以本地启动一个简单的http服务器::

   python3 -m http.server 8080

在 ``README.html`` 说明:

Service Pack for ProLiant 集合了固件以及系统软件元件，均经过测试管理，并且用来一块部署。该套件包含了服务器跟其附件设备所需要的驱动程序、代理程序、 实用程序以及固件元件。 SUM 是用来部署这些固件以及系统软件的工具。

如要在Windows底下启动SUM：

双击文档::

   launch_sum.bat

如要在Linux底下启动SUM::

   ./launch_sum.sh

如需更进一步的 Service Pack for ProLiant 信息，可以访问这个网站： https://www.hpe.com/servers/spp

.. note::

   ``launch_sum.sh`` 脚本实际上执行的是 ``packages/smartupdate`` ，该脚本只支持在 ``redhat`` 和 ``SuSE`` 平台运行

通过iLO WEB更新firmware
==========================

`How to Update the System BIOS & Firmware in an HP Proliant Servers <https://www.youtube.com/watch?v=MTjY5xzUkIk>`_ 是YouTube 上一个操作视频，可以参考。

rpm包升级(未完成)
--------------------

需要找到服务器对应的BIOS firmware文件名，可以根据HPE支持网站搜索看到 `* RECOMMENDED * Online ROM Flash Component for Linux - HPE ProLiant DL380 Gen9/DL360 Gen9 (P89) Servers <https://support.hpe.com/hpesc/public/swd/detail?swItemId=MTX_75e3e6e7f3484a39a8bf19fa24>`_ 文件名是::

   firmware-system-p89-2.90_2021_04_29-1.1.i386.rpm (6.1 MB)

所以在SPP光盘中对应搜索 P89 (也就是服务器 DL360 gen9) 的软件包::

   ls *.rpm | grep firmware | grep p89

可以看到是::

   firmware-system-p89-2.80_2020_10_16-1.1.i386.rpm

好吧，版本稍微旧一些

此外::

   firmware-ilo4-2.78-1.1.i386.rpm (13 MB)

.flash文件升级
------------------

通过BIOS工具升级
==================

按照官方文档说明，还可以通过系统工具来完成BIOS升级:

- Copy the binary file to a USB media or iLO virtual media.
- Attach the media to the server.
- In POST, press F9 to enter System Utilities and select Embedded Applications.
- Select “Firmware Update” and then “System ROM”.
- Choose “Select Firmware File”, and then select the device and the flash file.   
- Select “Start Firmware Update” and allow running to completion.

升级前后性能对比
==================

使用 :ref:`sysbench` 进行BIOS升级前后性能对比

参考
=======

- `HPE DL380 Gen 9 Firmware/Bios update <https://www.reddit.com/r/homelab/comments/k037h2/hpe_dl380_gen_9_firmwarebios_update/>`_
