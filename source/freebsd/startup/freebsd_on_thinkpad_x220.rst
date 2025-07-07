.. _freebsd_on_thinkpad_x220:

=====================================
在ThinkPad X220笔记本上运行FreeBSD
=====================================

:ref:`thinkpad_x220` 是2012年的上古设备，由于风扇损坏，其实已经在家里闲置了好几年。2025年，我在学习实践FreeBSD的时候，虽然 :ref:`freebsd_on_intel_mac` 能够很好在 :ref:`mbp15_late_2013` 上运行，但是:

- 我现在需要保留唯一的macOS运行环境 :ref:`mbp15_late_2013` 是目前最好的移动设备了
- :ref:`freebsd_wifi_bcm43602` 实际上是在 :ref:`mbp15_late_2013` 使用Linux虚拟机hack方式使用Broadcom无线网卡，非常膈应

考虑到ThinkPad(对Linux支持)硬件兼容性极佳，想来对FreeBSD也是如此，所以我为了能够在日常桌面转入到FreeBSD，所以改为在ThinkPad X220上安装和运行FreeBSD桌面。也方便我出行时拿着小黑不心疼，毕竟淘宝二手ThinkPad X220也就500RMB。在淘宝上下单了散热风扇，花了一下午吭哧吭哧更换好风扇，终于重新用上了这台X220。

.. note::

   吐槽一下2010年代的ThinkPad，其实内部设计和排线和同时代的MacBook Air/Pro差距还是很大的。虽然ThinkPad一直有皮实耐造的美誉，但是拆机以后看到内部居然有飞线(真电线而且还粘黑胶布封头)以及D面无法拆卸，不得不把整个主板拆卸以后反转换风扇。总之，内部比较拉胯，外表的结实耐用有点名不符实。

安装
=======

由于是通用设备组件，ThinkPad X220的内部无线网卡和有线网卡是直接被FreeBSD识别出来能够在安装过程中使用的，这点比MacBook强太多了，省了很多麻烦。

桌面
=======

- :ref:`freebsd_sway` **放弃**
- :ref:`freebsd_hikari` **放弃**
- :ref:`freebsd_xfce4` 为了能够集中精力，我最后选择易于配置和使用的Xfce桌面
- :ref:`freebsd_chinese`

参考
=======

- `How to Install FreeBSD 14 on a 6th Generation Thinkpad <https://akos.ma/blog/how-to-install-freebsd-14-on-a-6th-generation-thinkpad/>`_
- `FreeBSD on the Lenovo Thinkpad T480 <https://www.davidschlachter.com/misc/t480-freebsd>`_
- `Configuring a usable FreeBSD ThinkPad <https://forums.freebsd.org/threads/configuring-a-usable-freebsd-thinkpad.77795/>`_
