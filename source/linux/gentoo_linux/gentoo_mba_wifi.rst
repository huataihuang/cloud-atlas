.. _gentoo_mba_wifi:

====================================
Gentoo Linux在MacBook Air配置Wifi
====================================

我的 :ref:`mba13_mid_2013` 和 :ref:`mbp15_late_2013` 配置的是完全一样的 ``Boradcom BCM4360`` 蓝牙无线网卡，这款网卡对开源非常不兼容，导致 :ref:`gentoo_mbp_wifi` 实践遇到很多波折。

虽然最终能够通过hack方式使用 ``Boradcom BCM4360`` ，但是性能损失和kernel的特性损失导致得不偿失。所以我分别采用了不同的方法来解决这两台MacBook的无线网络问题:

- :ref:`mbp15_late_2013` 购买了 :ref:`bcm943602cs` 硬件来实现 :ref:`gentoo_brcmfmac_wifi`
- :ref:`mba13_mid_2013` 没有升级硬件，则采用外接USB无线网卡(本文)

待淘宝购买的USB无线网卡到手后实践，待续...
