.. _gentoo_mbp_wifi:

===================================
Gentoo Linux在MacBook Pro配置Wifi
===================================

.. note::

   ``broadcom-sta`` 私有驱动非常难以安装，对内核互斥选项很多，实际上 ``ebuild`` 的维护者也说这个驱动已经不再维护，建议直接购买内核 ``brcmfmac`` 驱动支持的兼容无线网卡 ``BCM943602CS`` ，在二手市场上只需要20美金。

   - :strike:`我准备最后再折腾一下 broadcom-sta 私有驱动安装` **最终通过回退 wpa_supplicant 版本2.8 解决无线网卡无流量问题** 非常 ``ugly`` ，我准备改为采用兼容无线网卡避免新版本内核的退化  

     - 目前最有希望的方案是参考 `Broadcom Wireless Drivers <https://jimbob88.github.io/gentoo/broadcom_wifi_drivers.html>`_ ，该文档是最新的 5.16.11 内核实践，提供了很多修复异常报错的方法
     - 我目前实在没有精力来折腾，所以准备购买Linux兼容的无线网卡来绕过这个问题 **为了使用闭源broadcom-sta导致很多新内核特性无法使用实在觉得得不偿失** ，这个闭源驱动从2015年以后就没有更新，所以在最新的内核中需要很多hack才能使用，代价很大

   - :ref:`mbp15_late_2013` 我在淘宝上花50元换一块 :ref:`bcm943602cs` 省的以后再折腾这种私有驱动了
   - :ref:`mba13_early_2014` 找不到内置兼容的无线网卡模块，太古老低端设备，我通过购买外接USB无线网卡来解决

Broadcom WiFi
===============

早期MacBook Air 11" 2011版
----------------------------

我曾经使用过MacBook Air 11" 2011版，这款笔记本使用的是Broadcom B43xx系列，是可以使用 ``b43-firmware`` 驱动的，装 ``b43`` 驱动即可:

.. literalinclude:: gentoo_mbp_wifi/macbook_air11_2011_b43
   :language: bash
   :caption: MacBook Air 11" 2011版可以使用 ``b43`` 驱动

Broadcom BCM4360
-------------------

到 :ref:`mbp15_late_2013` 以及我另外一台 :ref:`mba13_early_2014`  ，采用是 Broadcom BCM4360 。这款无线芯片对开源支持不佳，参考 `Linux wireless b43文档 <https://wireless.wiki.kernel.org/en/users/drivers/b43>`_ 可以看到 ``b43`` 驱动不支持BCM4360，建议使用 ``wl`` 驱动 ``broadcom-sta``

也就是需要使用闭源的Broadcom驱动( `Apple Macbook Pro Retina - Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina#Closed_source_Broadcom_driver>`_ )

.. literalinclude:: gentoo_mbp_wifi/lspci_k
   :caption: lspci -k 输出硬件信息

内核
========

IEEE 802.11
-------------

至少需要激活 ``cfg80211`` (CONFIG_CFG80211) 和 ``mac80211`` (CONFIG_MAC80211)

.. literalinclude:: gentoo_mbp_wifi/kernel_80211
   :caption: 内核激活 ``cfg80211`` (CONFIG_CFG80211) 和 ``mac80211`` (CONFIG_MAC80211)

.. note::

   由于需要加载firmware，所以 wireless configuration API (CONFIG_CFG80211) 需要配置成模块方式而不是直接buildin

.. note::

   对于私有驱动， **似乎** 需要关闭 ``mac80211`` (CONFIG_MAC80211)

WEXT
-------

``cfg80211 wireless extensions compatibility`` 选项( ``WEXT`` )可以支持传统的 ``wireless-tools`` 和 ``iwconfig`` :

.. literalinclude:: gentoo_mbp_wifi/kernel_wext
   :caption: 内核激活  ``cfg80211 wireless extensions compatibility`` 选项( ``WEXT``  )

.. note::

   我在 Kernel 6.1.12 未找到这个配置项

设备驱动
-----------

注意，建议将驱动编译为内核模块，因为WiFi驱动通常需要firmware，只有作为模块加载时才能使用firmware:

.. literalinclude:: gentoo_mbp_wifi/kernel_wifi_drivers
   :caption: 内核激活相应的驱动内核模块

.. note::

   ``b43`` 可以在内核源码中激活模块方式编译，但是Broadcom4360需要私有驱动 `net-wireless/broadcom-sta <https://packages.gentoo.org/packages/net-wireless/broadcom-sta>`_ 没有编译选项

   对于安装私有驱动，上述设备驱动我全关闭了

   但是参考 `Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)#Closed_source_Broadcom_driver>`_ 采用激活Intel PRO/Wireless 2100网卡驱动来输出内核的 LIB80211 ::

      Device Drivers
         -> Network device support
            -> Wireless LAN
               -> <*>   Intel PRO/Wireless 2100 Network Connection

LED支持
---------

笔记本内置WiFi没有LED，可忽略

.. literalinclude:: gentoo_mbp_wifi/kernel_wifi_led
   :caption: 内核WiFi的LED支持(数据包收发LED triggers)

Firmware
==========

根据 `gentoo linux wiki: WiFi <https://wiki.gentoo.org/wiki/Wifi>`_ 文档，除了内核模块编译支持之外，WiFi芯片还需要对应firmware:

.. csv-table:: Broadcom无线网卡驱动及firmware
   :file: gentoo_mbp_wifi/broadcom_wifi_driver_firmware.csv
   :widths: 30,20,20,30
   :header-rows: 1

快速起步: Broadcom BCM4360驱动和Firmware
============================================

.. note::

   上文的絮絮叨叨，实际上你要快速解决问题的话，只有一个步骤: 见这里

综上所述，对于 Broadcom BCM4360 实际上就只有安装私有驱动和firmware了，几乎连内核驱动模块都省了:

- 安装 ``wl`` 驱动和firmware:

.. literalinclude:: gentoo_mbp_wifi/broadcom_bcm4360_driver_firmware
   :caption: 安装Broadcom BCM4360的私有驱动和firmware

.. note::

   ``net-wireless/broadcom-sta`` 同时包含了驱动和firmware

``broadcom-sta`` 编译时会检查当前内核编译配置，如果有冲突选项会提示，按提示调整内核编译配置，例如我遇到以下内核配置需要关闭::

   X86_INTEL_LPSS  #位于 "Processor type and features ==> Intel Low Power Subsystem Support"
   PREEMPT_RCU 不能设置为 Preemptible Kernel 的 Preemption Model  #位于General setup ==> RCU Subsystem

经验总结
-----------

- 实际上最好的内核参数校验(是否满足 ``wl`` 正常运行)就是安装 ``net-wireless/broadcom-sta`` 输出信息
- 将输出信息项和 ``/usr/src/linux/.config`` 进行对比就知道内核配置有哪些不能满足闭源 ``wl`` 驱动的运行条件

``genkernel`` 内核安装 ``broadcom-sta``
========================================

- 安装 ``wl`` 驱动和firmware:

.. literalinclude:: gentoo_mbp_wifi/broadcom_bcm4360_driver_firmware
   :caption: 安装Broadcom BCM4360的私有驱动和firmware

- 提示错误显示 ``net-wireless/broadcom-sta`` 已经被 ``masked`` :

.. literalinclude:: gentoo_mbp_wifi/broadcom-sta_masked
   :caption: 安装 ``net-wireless/broadcom-sta`` 提示被 ``masked``
   :emphasize-lines: 3

这里软件被屏蔽的原因是 ``~amd64`` 关键字，有两种方式解决，

方法一: 在 :ref:`gentoo_makeconf` 中配置接受测试版本:

.. literalinclude:: gentoo_makeconf/accept_keywords_test_amd64
   :caption: 在 ``/etc/portage/make.conf`` 配置接受测试阶段的AMD64架构软件包

方法二(建议):  在 ``/etc/portage/package.accept_keywords`` 中添加你想安装的被mask的关键字:

.. literalinclude:: gentoo_makeconf/package.accept_keywords
   :caption: 创建 ``/etc/portage/package.accept_keywords`` 包含接受的软件包关键字

当初次完成 :ref:`install_gentoo_on_mbp` 采用通用发行版内核时，会提示如下信息:

.. literalinclude:: gentoo_mbp_wifi/broadcom-sta_install_messages
   :caption: 在通用内核的Gentoo上安装 ``net-wireless/broadcom-sta`` 提示信息

按照提示，需要配置 ``blocklist`` 屏蔽冲突内核模块 也就是配置 ``/etc/modprobe.d/blacklist.conf`` 如下:

.. literalinclude:: gentoo_mbp_wifi/broadcom-sta_blocklist.conf
   :caption: 针对安装 ``net-wireless/broadcom-sta`` 需要屏蔽地内核模块配置文件 ``/etc/modprobe.d/blacklist.conf``

.. warning::

   必须在操作系统启动时屏蔽掉上述冲突的内核模块，否则即使加载了 ``wl`` 模块，也看不到对应的网卡

- 移除冲突内核模块，加载 ``wl`` 内核模块:

.. literalinclude:: gentoo_mbp_wifi/modprobe_wl
   :caption: 移除冲突内核模块后加载 ``wl`` 内核模块

- 需要重新编译内核(并且每次升级内核都需要重新安装一次 ``net-wireless/broadcom-sta`` 并重新编译内核):

.. literalinclude:: gentoo_genkernel/genkernel_all
   :caption: 重新编译内核， ``all`` 参数将包括firmware

- 重启系统后，如果正确加载了 ``wl`` 内核模块，那么可以看到一块新出现的无线网卡 ``wlp3s0``

``PREEMPT_RCU`` 冲突
----------------------

我在最新的 6.1.12 内核安装 ``broadcom-sta`` 遇到报错::

   PREEMPT_RCU: Please do not set the Preemption Model to "Preemptible Kernel"; choose something else. 

这个问题在 `emerge broadcom-sta fails (6.1.12 kernel) due to PREEMPT_RCU <https://forums.gentoo.org/viewtopic-p-8780772.html?sid=5cc5e86da1895dbc2b210c1d15a2d113>`_ 有解决建议:

- ``PREEMPT_RCU`` 不能直接修改(确实，我在配置选项中没有找到)
- 在 ``General setup`` 中 当选择以下 ``preemption models`` 时 ``PREEMPT_RCU`` 会自动选择:

  - Preemptible Kernel (Low-Latency Desktop) # 位于 General setup => Preemption Model
  - Fully Preemptible Kernel (Real-Time) (this might not be available on all CPU architectures)

- 在 ``General setup`` 中如果激活 ``PREEMPT_DYNAMIC`` 就会自动选择

果然，原来我选择激活了 ``Gneeral setup => Preemption behaviour defined on boot`` ，这个选项就是 ``PREEMPT_DYNAMIC=y`` ，就是这个选项导致。真是这个选项激活导致了 ``PREEMPT_RCU`` 出现，我取消这个配置就可以了

配置 :ref:`wpa_supplicant`
=============================

和 :ref:`ubuntu_linux` 配置 :ref:`wpa_supplicant` 或者 :ref:`archlinux_wpa_supplicant` 类似，采用 ``wpa_supplicant`` 可以轻松配置无线连接:

- 检查无线网络:

.. literalinclude:: ../ubuntu_linux/network/wpa_supplicant/rfkill_list
   :caption: 使用 ``rfkill list`` 检查网卡设备是否被block

输出显示当前状态，可以看到无线网络没有屏蔽:

.. literalinclude:: gentoo_mbp_wifi/rfkill_list_output
   :caption: ``rfkill list`` 显示我的主机无线网卡没有被软件block
   :emphasize-lines: 7,8

- 创建初始配置:

.. literalinclude:: ../ubuntu_linux/network/wpa_supplicant/init_wpa_supplicant.conf
   :caption: 使用 ``wpa_passphrase`` 初始化一个简单配置

- 通过 :ref:`openrc` 启动 ``wpa_supplicant`` 服务:

.. literalinclude:: gentoo_mbp_wifi/openrc_wpa_supplicant
   :caption: 设置 ``openrc`` 启动 ``wpa_supplicant`` 服务

异常排查
===========

.. warning::

   我折腾了很久 ``wlp3s0`` 无线网卡无数据流量的问题，最初以为是内核编译问题，但是实际上最终解决的方法是将 ``wpa_supplicant`` 回退到旧版本 ``2.8`` 解决。非常坑

- ``wlp3s0`` 无线网卡没有任何数据包进出(观察 ``ifconfig`` 输出显示 RX/TX 包都是0)

通过前台执行命令 ``wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf -i wlp3s0`` 可以看到输出了错误信息:

.. literalinclude:: gentoo_mbp_wifi/wpa_supplicant_scan_failed
   :caption: ``wpa_supplicant`` 显示无线网卡扫描错误

参考 `gentoo linux wiki: WiFi <https://wiki.gentoo.org/wiki/Wifi>`_ 提到，当操作系统启动时， ``dmesg`` 或 :ref:`journalctl` 中应该有对应的firmware probe，则我现在检查 ``dmesg -T | grep -i firmware`` 输出:

.. literalinclude:: gentoo_mbp_wifi/dmesg_without_wl_firmware
   :caption: ``dmesg -T`` 输出过滤找不到无线网卡的firmware信息

``IPW2100``
-------------

参考 `Apple Macbook Pro Retina (early 2013)#Wireless <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)#Wireless>`_ 其中提到闭源Broadcom驱动需要内核中输出 ``LIB80211`` ，这个配置是通过将 ``Intel PRO/Wireless 2100 Network Connection`` 直接编译进内核(不是模块)来实现的。不过，需要注意这个 ``Intel Pro/Wireless 2100 Network Connection`` 默认是编译为模块，因为它依赖的内核部分是模块形式导致，需要仔细调整，强制为直接编译进内核:

.. literalinclude:: gentoo_mbp_wifi/intel_wireless_2100
   :caption: ``Intel PRO/Wireless 2100 Network Connection`` 需要编译进内核以激活 ``LIB80211``
   :emphasize-lines: 4

这里有一个模块依赖关系::

   IPW2100 (m) => CFG80211 (m) => RFKILL (m)

.. literalinclude:: gentoo_mbp_wifi/intel_wireless_2100_buildin
   :caption: 设置 ``IPW2100`` buildin 内核的配置方法
   :emphasize-lines: 3,6,11

最终解决方法是前文的 **经验总结** : 对比 ``net-wireless/broadcom-sta`` 安装后的输出信息 和 ``/usr/src/linux/.config`` ，调整内核配置。 也就是 ``grep XXX /usr/src/linux/.config`` ，我发现我的错误在于依然包含了冲突配置::

   CONFIG_SSB=m
   CONFIG_X86_INTEL_LPSS=y   <= Intel Low Power Subsystem Support
   CONFIG_PREEMPT_RCU=y

``PREEMPT_RCU``
----------------

.. note::

   `Broadcom Wireless Drivers <https://jimbob88.github.io/gentoo/broadcom_wifi_drivers.html>`_ 文档提到 ``ERROR: PREEMPT_RCU`` 可以忽略，原因不明

这个 ``PREEMPT_RCU`` 非常难找，在 ``make menuconfig`` 中，通过 ``/PREEMPT_RCU`` 找不到入口。参考 `How to disable CONFIG_PREEMPT_RCU in 5.14 kernel <https://stackoverflow.com/questions/75934094/how-to-disable-config-preempt-rcu-in-5-14-kernel>`_ ，这个配置在 3.14 内核没有激活，到 5.14 内核默认激活

根据 ``make menuconfig`` 搜索 ``/PREEMPT_RCU`` 可以看到提示这个选项在 ``kernel/rcu/Kconfig:19`` 提供: 所以查看源码中 ``/usr/src/linux/kernel/rcu/Kconfig``

.. literalinclude:: gentoo_mbp_wifi/Kconfig
   :language: c
   :caption: 根据 ``Kconfig`` : ``PREEMPTION`` 选择  ``PREEMPT_RCU`` 就会触发 ``PREEMPT_RCU=y`` 
   :emphasize-lines: 8,10,12,19,21,22

上述 ``Kconfig`` 可以看出选择的链路:

  - ``SMP`` 选择了 ``CONTEXT_TRACKING_IDLE`` 导致 ``TREE_RCU`` 为 ``Y``
  - ``TREE_RCU`` 选择之后就会导致 ``PREEMPT_RCU`` 为 ``Y``

但是，我还是没有找到可以调整的入口，看起来在最新的Kernel 这个配置是固化的？

.. warning::

   :strike:`太折腾了，我最终还是没有解决在最新的 Kernel 6.1.67 上支持 BCM4360 网卡的私有驱动 broadcom-sta (wl)的安装，太累了，放弃...` 突然找到了解决方案，最后再试一下

   我理解关闭内核 :ref:`rcu` ``PREEMPT_RCU`` 对性能是有影响的，无法充分发挥最新内核的特性。加上实在太折腾了，我放弃继续安装 ``broadcom-sta`` ，准备更换无线网卡硬件，采用内核原生开源驱动。 

   或许早期内核版本能够使用这个网卡驱动?

.. note::

   我学习和整理了内核的 :ref:`rcu_overview` 知识点，算是为这次无线网卡折腾画个句号。

最终的解决方法
=================

根据 `Broadcom Wireless Drivers <https://jimbob88.github.io/gentoo/broadcom_wifi_drivers.html>`_ 文档经验，原来最新版本的 ``wpa_supplicant`` 是无法配合 ``broadcom-sta`` 驱动工作的，需要回退到 2019 年的 ``wpa_supplicant-2.8`` 版本

.. literalinclude:: gentoo_mbp_wifi/wpa_supplicant
   :caption: 由于兼容性问题，需要回滚 ``wpa_supplicant`` 2.8 版本才能和 ``broadcom-sta`` 一起工作

需要修订 ``wpa_supplicant`` 编译配置，所以修改源代码 ``./wpa_supplicant/.config`` 如下:

.. literalinclude:: gentoo_mbp_wifi/wpa_supplicant_config
   :caption: 修改 ``./wpa_supplicant/.config`` 配置

- 删除掉系统已经安装的 ``wpa_supplicant`` 并清理:

.. literalinclude:: gentoo_mbp_wifi/remove_wpa_supplicant
   :caption: 删除并清理系统已经安装的 ``wpa_supplicant``

- 最后完成编译安装:

.. literalinclude:: gentoo_mbp_wifi/build_wpa_supplicant
   :caption: 编译安装旧版本 ``wpa_supplicant``

果然， **使用旧版wpa_supplicant** 就能够正常发起通讯，此时无线网卡已经显示有数据流量。

接下来 ``wpa_supplicant`` 和上文相同，不再重复

其他问题
------------

旧版 ``wpa_supplicant`` 在连接 :ref:`802.1x_eap` 报错:

.. literalinclude:: gentoo_mbp_wifi/wpa_supplicant_802.1x_eap_error
   :caption: 旧版 ``wpa_supplicant`` 连接 :ref:`802.1x_eap` 无线网络报错，显示不支持TLS
   :emphasize-lines: 3

这个报错 ``error:0308010C:digital envelope routines::unsupported`` 在 :ref:`nodejs` version 17 中常见，原因是不支持 TLS 导致。我感觉我回退到旧版本的 ``wpa_supplicant`` 应该也是存在这个异常问题的，不过我没有再折腾解决这个问题。(参考 `Error: error:0308010c:digital envelope routines::unsupported [Node Error Solved] <https://www.freecodecamp.org/news/error-error-0308010c-digital-envelope-routines-unsupported-node-error-solved/>`_ )

参考
=====

- `Apple Macbook Pro Retina - Closed source Broadcom driver <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina#Closed_source_Broadcom_driver>`_
- `gentoo linux wiki: WiFi <https://wiki.gentoo.org/wiki/Wifi>`_
- `emerge broadcom-sta fails (6.1.12 kernel) due to PREEMPT_RCU <https://forums.gentoo.org/viewtopic-p-8780772.html?sid=5cc5e86da1895dbc2b210c1d15a2d113>`_
- `bookpro-11-2-gentoo-config/README.md <https://github.com/aesophor/macbookpro-11-2-gentoo-config/blob/master/README.md>`_
- `Apple Macbook Pro Retina (early 2013)#Wireless <https://wiki.gentoo.org/wiki/Apple_Macbook_Pro_Retina_(early_2013)#Wireless>`_
- `gentoo linux wiki: wpa_supplicant <https://wiki.gentoo.org/wiki/Wpa_supplicant>`_
