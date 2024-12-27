.. _freebsd_wifi_bcm43602:

==========================
FreeBSD无线网络BCM43602
==========================

.. note::

   本文实践在 :ref:`mbp15_late_2013` 进行，最初该笔记本原装无线网卡芯片是 Broadcom BCM4360 。这个无线芯片可以在Linux上工作(其实也很难支持)，但是FreeBSD目前无法支持。

   我在最近一次部署 :ref:`gentoo_mbp_wifi` 将 :ref:`mbp15_late_2013` 无线网卡模块换成了 :ref:`bcm943602cs` 来避免折腾NVIDIA私有驱动，所以现在我在 :ref:`mbp15_late_2013` 部署FreeBSD时候，将针对 :ref:`bcm943602cs` 配置无线网络。理论上 ``BCM43602`` 无线模块对开源驱动较为友好，可能可以在FreeBSD中驱动。

检查硬件
=========

- 执行 ``pciconf`` (类似Linux平台的 ``lspci`` )命令检查硬件:

.. literalinclude:: freebsd_wifi_bcm43602/pciconf
   :caption: ``pciconf`` 检查硬件

显示:

.. literalinclude:: freebsd_wifi_bcm43602/pciconf_output
   :caption: ``pciconf`` 检查硬件显示 BCM43602
   :emphasize-lines: 3

博通（broadcom）网卡驱动
==========================

`FreeBSD Broadcom Wi-Fi Improvements <https://www.landonf.org/code/freebsd/Broadcom_WiFi_Improvements.20180122.html>`_ 提供了Broadcom无线网卡支持列表，但是没有 BCM43602

我在 `reddit帖子: Support for BCM4360 (2014 Mac Mini) Trying to move from Linux/windows. <https://www.reddit.com/r/freebsd/comments/1ekuffr/support_for_bcm4360_2014_mac_mini_trying_to_move/>`_ 看到有提到虽然FreeBSD列表中没有支持，但是OpenBSD显示支持 ``BCM43602`` 但不支持BCM4360。看起来我的 ``BCM43602`` 还是有希望的...

非常幸运， `Project FreeBSD Wifibox <https://github.com/pgj/freebsd-wifibox>`_ 项目在FreeBSD上通过使用Linux来驱动无线网卡(神奇啊!!!)

.. note::

   FreeBSD不支持 ``BCM43602`` 的原因是License和技术原因(这块Broadcom无线网卡需要闭源驱动)，所以FreeBSD官方是永远不会支持该网卡的。

`Project FreeBSD Wifibox <https://github.com/pgj/freebsd-wifibox>`_ 通过在FreeBSD的 :ref:`bhyve` 运行 :ref:`alpine_linux` 虚拟机，将物理主机的无线网卡从FreeBSD主机中直接透传给guest虚拟机，来实现在Linux VM中使用wifi驱动。

参考
======

- `FreeBSD中文社区 「FreeBSD从入门到跑路」:第 14.2 节 WiFi <https://book.bsdcn.org/di-14-zhang-wang-luo-guan-li/di-14.2-jie-wifi>`_ 提供了概要，但是具体到BCM43602芯片依然需要其他支持
- `Project FreeBSD Wifibox <https://github.com/pgj/freebsd-wifibox>`_ 巧妙地将Linux驱动用于FreeBSD，终于能够在FreeBSD上使用Broadcom无线网卡了(毕竟很多厂商为Linux提供了驱动但是无法顾及BSD系统)
- 其他一些参考资料:

  - `A Full Guide: FreeBSD 13.3 on a MacBook Pro 11.4 (Mid 2015) (A1398) <https://joshua.hu/FreeBSD-on-MacbookPro-114-A1398>`_ 虽然我的笔记本 :ref:`mbp15_late_2013` 是2013年版本，比博客中使用的2015年版本旧，但是我在二手市场上购买了 ``BCM43602`` 无线网卡模块就是 ``MacBook Pro 2015`` 所使用的，所以经验可以借鉴
  - `Can't get working with Broadcom BCM43602 (Macbook Pro 2015) #65 <https://github.com/pgj/freebsd-wifibox/issues/65>`_ freebsd-wifibox项目issue中讨论了如何使用BCM43602
  - `Hardware for BSD网站: Device 'Broadcom BCM43602 802.11ac Wireless LAN SoC' <https://bsd-hardware.info/?id=pci:14e4-43ba-106b-0133&dev_class=02-80&dev_type=net%2Fwireless&dev_vendor=Broadcom&dev_name=BCM43602+802.11ac+Wireless+LAN+SoC&dev_ident=602f5>`_ 提供信息指出 ``BCM43602`` 在 OpenBSD 7.2 和 7.4 都得到了支持，但是FreeBSD 13/14 都没有支持这块网卡
