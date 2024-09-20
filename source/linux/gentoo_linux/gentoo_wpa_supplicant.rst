.. _gentoo_wpa_supplicant:

==========================================
Gentoo使用wpa_supplicant连接无线网络
==========================================

我在很多Linux发行版中使用过 :ref:`wpa_supplicant` 配置无线网络，非常简洁的 ``wpa_supplicant`` 工具提供了诸如 ``wpa_passphase`` 来生成密码配置，使用起来非常顺手，甚至不需要 :ref:`networkmanager` 这样大而全的管理工具。

我在 :ref:`gentoo_mbp_wifi` 实践中折腾了很久，最终通过替换 :ref:`mbp15_late_2013` 无线模块 :ref:`bcm943602cs` 来解决NVIDIA私有无线驱动的问题。硬件升级之后，我发现一个很奇怪的问题，有一部分Wifi始终无法连接:

- 最顺利稳定连接的是我通过 :ref:`vpn_hotspot` 共享Android给运行在 :ref:`mbp15_late_2013` 上的Gentoo使用，可以看到 无线模块 :ref:`bcm943602cs` 工作稳定
- 但是我发现我自己家里新安装的移动公司的宽带Wifi无法连接，并且我发现外出旅行，有些酒店的wifi不能连接，有的酒店wifi却能够正常连接

最初我以为是我的 :ref:`bcm943602cs` 无线模块存在硬件兼容性问题(难道和某些Wifi不兼容?)，但是我发现同一个 :ref:`mbp15_late_2013` 笔记本上安装的双启动 :ref:`macos` 却完全正常工作。这说明硬件是好的，软件存在问题。

我初步估计是配置问题，但是我仔细对比了 ``wpa_supplicant.conf`` 配置，发现这个配置其实不需要复杂配置，只需要通过 ``wpa_passphase`` 自动生成密码配置就可以驱动。一些辅助配置也只是设置是否扫描隐藏AP，是否连接WiFi 5的 ``country`` 设置。

`archlinux: wpa_supplicant <https://wiki.archlinux.org/title/Wpa_supplicant>`_ 介绍了debug方法，给我启发:

.. literalinclude:: gentoo_wpa_supplicant/wpa_supplicant_debug
   :caption: 使用 ``wpa_supplicant`` 的debug ( ``-d`` 参数)

此时就可以看到了关键的报错信息:

.. literalinclude:: gentoo_wpa_supplicant/wpa_supplicant_debug_output
   :caption: 使用 ``wpa_supplicant`` 的debug ( ``-d`` 参数) 输出
   :emphasize-lines: 13

``invalid group cipher 0x8 (000fac02)`` 在Gentoo论坛和bugzilla平台可以找到，对应的是无线路由器使用了 ``TKIP`` 不安全的 ``WPA2-TKIP`` :ref:`wpa` 标准，默认情况下Gentoo编译 ``net-wireless/wpa_supplicant`` 是关闭了 ``tkip`` 这个USE flag导致的。

解决方法很简单: 配置 ``/etc/portage/package.use/wpa_supplicant`` 内容如下:

.. literalinclude:: gentoo_wpa_supplicant/wpa_supplicant_use_flag
   :caption: 配置 ``/etc/portage/package.use/wpa_supplicant`` 激活 ``WPA2-TKIP`` (不安全)无线加密支持

然后重新 :ref:`gentoo_emerge` :

.. literalinclude:: gentoo_wpa_supplicant/emerge_wpa_supplicant
   :caption: 重新emerge wpa_supplicant

这样，只需要保持原有 ``/etc/wpa_supplicant/wpa_supplicant.conf`` 不变:

.. literalinclude:: gentoo_wpa_supplicant/wpa_supplicant.conf
   :caption: 简单的 ``wpa_supplicant.conf``

参考
=====

- `archlinux: wpa_supplicant <https://wiki.archlinux.org/title/Wpa_supplicant>`_
- `Bug 836423 - net-wireless/wpa_supplicant-2.10 no longer connects to my wifi - wpa_parse_wpa_ie_rsn: invalid group cipher 0x8 (000fac02) <https://bugs.gentoo.org/836423>`_
- `Wi-Fi Security: Should You Use WPA2-AES, WPA2-TKIP, or Both? <https://www.howtogeek.com/204697/wi-fi-security-should-you-use-wpa2-aes-wpa2-tkip-or-both/>`_
