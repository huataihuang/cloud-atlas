.. _gentoo_brcmfmac_wifi:

========================
Gentoo ``brcmfmac`` 无线
========================

在反复折腾 :ref:`gentoo_mbp_wifi` 失败之后，我转为购买 :ref:`bcm943602cs` 安装到 :ref:`mbp15_late_2013` 来解决Linux开源驱动兼容问题:

- 完全开源的驱动，没有任何二进制对象文件
- 框架支持新芯片，包括 ``mac80211-aware`` 嵌入式芯片
- 不支持使用 SSB 后端平面的古老的 PCI/PCIe 芯片( ``b43`` )
- ``brcmfmac`` 是原生 ``FullMAC`` ； ``brcmsmac`` 是 基于 mac80211的 ``SoftMAC``

硬件
=====

- 外观(淘宝)

- 启动Linux之后执行 ``lspci`` 检查，原来苹果笔记本的 :ref:`bcm943602cs` 配件的Broadcom芯片是 ``BCM43602``

.. literalinclude:: gentoo_brcmfmac_wifi/bcm943602cs
   :caption: ``bcm943602cs`` 网卡实际芯片为 ``BCM43602``

- 执行 ``lspci`` 详细指令过滤出 ``14e4:`` 设备:

.. literalinclude:: gentoo_brcmfmac_wifi/lspci_vnn
   :caption: ``lspci -vvn`` 查看网卡详细信息
   :emphasize-lines: 1-16

``brcm80211``
================

内核包含了两个内建的开源驱动:

- ``brcmfmac`` : 用于原生的 FullMAC
- ``brcmsmac`` : 用于基于 ``mac80211`` 的 SoftMAC

内核驱动会在启动时自动加载

.. note::

   - **brcmfmac** 支持较为新型的芯片，并且支持诸如 AP模式, P2P模式, 或者硬件加密
   - **brcmsmac** 则只支持旧型号芯片，如 BCM4313, BCM43224, BCM43225

内核编译
==========

针对 ``[14e4:43ba]`` 芯片，也就是 ``brcmfmac`` 驱动配置方法:

.. literalinclude:: gentoo_brcmfmac_wifi/kernel_menuconfig
   :caption: 内核配置支持 ``brcmfmac`` 驱动

使用 :ref:`gentoo_genkernel` 完成内核编译和安装之后，重启系统

恢复 :ref:`gentoo_mbp_wifi` 中因为需要安装旧版本 ``wpa_supplicant`` 被 :ref:`gentoo_emerge` 删除的 :ref:`wpa_supplicant` 软件包，按照 :ref:`gentoo_mbp_wifi` 中重新配置 ``wpa_supplicant``

- 创建初始配置:

.. literalinclude:: ../ubuntu_linux/network/wpa_supplicant/init_wpa_supplicant.conf
   :caption: 使用 ``wpa_passphrase`` 初始化一个简单配置

- 通过 :ref:`openrc` 启动 ``wpa_supplicant`` 服务:

.. literalinclude:: gentoo_mbp_wifi/openrc_wpa_supplicant
   :caption: 设置 ``openrc`` 启动 ``wpa_supplicant`` 服务

非常丝滑，这款 MacBook Pro 2015 的无线配件 :ref:`bcm943602cs` 确实非常适合Linux使用，完全适配我的 :ref:`mbp15_late_2013`

问题排查
===============

我遇到一个奇怪的问题，连接到家里的5G wifi路由器总是失败:

- 启动 :ref:`wpa_supplicant` 服务之后，再执行 ``ifconfig`` 观察可以看到无线网卡没有任何进出包
- 但是也不是所有无线连接都有问题，有些无线路由器可以正常连接，连接以后 ``ifconfig`` 可以看到正常的包计数

  - 我的 :ref:`pixel_4` 启用 :ref:`vpn_hotspot` 共享无线是能够正常连接和访问的

- 在外旅行时，连接旅店的无线wifi也是部分正常，部分不能连接(现象相同)

似乎是某些无线AP不能兼容？

所使命令行方式运行 ``wpa_supplicant`` (前台运行)观察输出:

.. literalinclude:: ../ubuntu_linux/network/wpa_supplicant/wpa_supplicant_connect
   :caption: 前台运行 ``wpa_supplicant`` 观察

输出信息

.. literalinclude:: gentoo_brcmfmac_wifi/wpa_supplicant_connect_output
   :caption: 前台运行 ``wpa_supplicant`` 输出的错误信息


参考
=====

- `Broadcom brcmsmac(PCIe) and brcmfmac(SDIO/USB) drivers <https://wireless.wiki.kernel.org/en/users/drivers/brcm80211>`_
- `archlinux wiki: Broadcom wireless#brcm80211 <https://wiki.archlinux.org/title/broadcom_wireless#brcm80211>`_
- `Mac Pro 2015 - Kernel 4.1.15 - Braodcom Wireless <https://forums.gentoo.org/viewtopic-t-1040720-start-0.html>`_ 提供了 MacBook Pro 2015笔记本无线网卡 ``BCM43602`` 编译设置
