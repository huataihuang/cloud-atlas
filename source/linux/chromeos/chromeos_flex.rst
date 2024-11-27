.. _chromeos_flex:

====================
ChromeOS Flex
====================

2022年2月，Google宣布了ChromeOS 的一个新版本 ChromeOS Flex，设计运行在旧的PC和Mac上。ChromeOS Flex外观和运行在ChromeBook笔记本上的ChromeOS相同，基于相同的代码库和法步周期。

由于ChromeBook在国内依然是比较昂贵的电子产品(如果要比较好的设计外观和配置)，所以，如果能够在自己的旧设备上运行ChromeOS Flex，能够体验ChromeOS，还是很有趣的。我看了一下 `ChromeOS Flex Certified models list <https://support.google.com/chromeosflex/answer/11513094>`_ ，发现Google认证了以下几款Mac设备比较接近我所拥有的:

.. csv-table:: ChromeOS Flex认证Mac设备
   :file: chromeos_flex/macs.csv
   :widths: 25,25,25,25
   :header-rows: 1

可以看到我拥有的 3款 Mac设备有一款 :ref:`mbp15_late_2013` 得到认证支持，另外两款 :ref:`mba11_late_2010` 和 :ref:`mba13_early_2014` 恰好错过了支持列表

为了尝试ChromeOS单独购买设备显然不现实，所以我考虑在我的旧设备上尝试安装体验:

- 了解完全基于网络的系统该如何运行，以便能够分析学习
- 对ChromeOS能够运行 :ref:`android` 应用非常感兴趣，这是能够使用大量企业级或者现代应用的方便之门
- ChromeOS现在还能运行 :ref:`debian` 系系统，可以实现一个简单的Linux开发环境

.. warning::

   2024年底，随着美国反垄断调查，Google有可能分拆Chrome浏览器，据说Google正在将ChromeOS融合到 :ref:`android` 中，今后可能ChromeOS会消失，取代以Android OS，也许会类似于三星的DX桌面(即手机连接大屏幕显示器时自动扩展为桌面) -- `Google 将杀死 Chrome OS <https://www.solidot.org/story?sid=79814>`_ :

   Android Authority 援引消息来源报道，Google 准备杀死 Chrome OS，或者说将 Chrome OS 变成 Android，以期望在平板市场与苹果的 iPad 展开竞争。两大操作系统在平板电脑上都无法抗衡苹果，Chrome OS 本身不太适合平板电脑，而 Android 则缺乏生产力功能。Google 的决定不是融合两种操作系统，而是将 Chrome OS 完全迁移到 Android。暂时不清楚此举对 Chromebook 品牌的影响。

.. note::

   有没有可能自己构建服务来支持ChromeOS在墙内的使用?

   - 云盘 - 数据自动同步
   - 挂载分布式存储作为大容量本地盘
   - 代理

   所有的数据都即存在网上，本地仅使用非常轻微的数据，甚至没有数据

硬件设备
===========

最近我购买了 :ref:`4_nvme_usb_disk` 用于构建 :ref:`zfs` ，恰好我手头上4块 :ref:`samsung_pm9a1` 的其中一块原先就是 :ref:`mbp15_late_2013_update_nvme` ，现在将用于构建 :ref:`zfs` 。而我想尝试用新购买的 :ref:`intel_optane_m10` 安装到 :ref:`mbp15_late_2013` 中作为瘦客户机，也就是尝试 ChromeOS 的存储。

目前就是这个硬件规划:

.. csv-table:: :ref:`mbp15_late_2013` 安装硬件环境
   :file: chromeos_flex/mbp.csv
   :widths: 40,30,30
   :header-rows: 1

.. warning::

   ChromeOS Flex 安装时会检测主机硬件配置，我原本以为最小配置仅是充分条件，但是没想到 :ref:`intel_optane_m10` 实际上只有 13.41G ，安装检测不能通过，所以被迫放弃。

准备
=============

- 解压缩下载的zip文件，并写入U盘:

.. literalinclude:: chromeos_flex/dd
   :caption: 使用 ``dd`` 将下载的镜像写入U盘

- 安装非常简单，将U盘插入 :ref:`mbp15_late_2013` ，立即触发启动，按提示进行安装。速度过快，我甚至一度怀疑操作系统复制是不是没有完成，但是实际上已经安装好了。

使用体验
==========

- 最大的困难可能是 :ref:`across_the_great_wall` ，我主要通过 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建一个简单翻墙来帮助完成账号初始化
- ChromeOS 内置了Google全家桶，大多数对于我来说并不是必须的，但是Terminal终端是我必要的工具:

  - ChromeOS使用了虚拟机结合容器的方式来构建一个Linux运行环境，第一次启动时会从互联网下载虚拟机并在虚拟机内部再启动一个容器，通过双层隔离沙响来实现安全: 这种方式为Linux技术开发带来不便，ChromeOS不提供底层操作系统直接的终端，你很难对ChromeOS进行剖析
  - 由于ChromeOS将 ``ctrl`` 健作为 Meta 健，导致在Linux虚拟机Terminal终端无法使用 ``ctrl`` 结合的快捷键，这个问题我还没有找奥解决方法: 暂时无法使用 ``ctrl-c`` (终止运行程序) 以及 ``ctrl-b`` ( :ref:`tmux` ) ，所以非常痛苦

- 总体来说ChromeOS就是一个Google官方构建的Gnome精简系统:

  - 提供了良好的中文输入支持，以及内置中文显示: 再也不用折腾Linux桌面中文环境，这点非常友好
  
- ChromeOS Flex 看起来还是和官方的ChromeOS有所区别，没有内置 :ref:`android` 运行环境，我暂时也没有时间去探索

我的目标是尝试在ChromeOS Flex中能够运行 :ref:`android`  程序，但是看来目前没有简单方法实现。另外，内置的Linux Terminal由于在虚拟机和容器的双层嵌套下非常不方便，对开发和运维工作带来很大困扰。

目前看不出将 :ref:`macos` 替换为 ChromOS的理由，甚至因为诸多安全限制，使用起来还不如 :ref:`linux_desktop` 方便，所以短暂尝试后，我暂时放弃了ChromeOS Flxe。(另外一个原因是无法使用Android，甚至现在科技新闻报导由于反垄断，Google很有可能拆分Chrome，并将放弃ChromeOS，合并到Android系统中，未来前景不明)

参考
======

- `将旧 PC 和 Mac 变成 Chromebook <https://www.solidot.org/story?sid=72130>`_
- `Google 将杀死 Chrome OS <https://www.solidot.org/story?sid=79814>`_
- `Upgrade your PCs and Macs to ChromeOS Flex <https://chromeos.google/products/chromeos-flex/>`_
- `ChromeOS Flex installation guide > Prepare for installation <https://support.google.com/chromeosflex/answer/11552529?hl=en>`_
- `ChromeOS Flex installation guide > 1: Create the USB installer <https://support.google.com/chromeosflex/answer/11541904?hl=en>`_
