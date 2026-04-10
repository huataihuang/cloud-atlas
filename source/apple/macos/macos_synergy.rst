.. _macos_synergy:

======================
macOS平台Synergy
======================

我在很久以前就使用 :ref:`synergy` 来使用一套键盘鼠标来协同操作Linux和macOS，最近我计划转向采用古旧的 :ref:`mbp15_late_2013` 作为桌面电脑，连接未来购买的 :ref:`mac_mini_m5` 来实现:

- :ref:`machine_learning`
- :ref:`ios` 开发

由于Mac mini虽然可以连接我现在的4k显示器，但是要配套macOS最佳的键盘和touchpad，实际上成本还是很高的，因为再购买一个touchpad花费不菲，而我现在已有的 :ref:`mbp15_late_2013` 实际上已经有一套很好的键盘和touchpad，如果能充分利用应该很有价值。

构想
======

在 MacBook Pro 和 Mac mini 上同时运行 Synergy。MBP 作为 Server（提供键盘/触控板），Mac mini 作为 Client:

- Synergy开启 **触控板模式** 来获得原生操作手感
- 4K显示器通过 **雷雳5转HDMI 2.1/DP** 连接 :ref:`mac_mini_m5`

  - 4K 显视器直连 Mac mini能够获得最佳的现实效果，通过 :ref:`synergy` 来操作Mac mini，可以充分发挥Mac mini的图形性能(避免MBP 远程桌面连 Mac mini的延迟和糟糕的图形)
  - 古老的MBP负载极低，所有高负载任务都在Mac mini完成

- 虽然 :ref:`mbp15_late_2013` 只有雷雳 2 接口，但通过“雷雳 3 转雷雳 2”转换器，它依然能以 20Gbps 的速度连接 Mac mini 集群。这种雷雳网桥下运行Synergy，延迟可以低至微秒级，完全感觉不到在操作另一台机器

- Synergy 在 macOS 之间共享大段代码或复杂格式时偶尔会失效，配合 **Universal Clipboard (通用剪贴板)** 。只要两台机器登录同一个 iCloud 账号并开启蓝牙，甚至不需要 Synergy 就能实现复制粘贴

- 快捷键冲突: ``Command + Tab`` 等系统级快捷键默认会作用于 MBP，需要在 Synergy 的高级设置中勾选“只在窗口激活时捕获系统按键”，或者习惯使用特定的热键切换

- ouchpad 优化: 苹果的“多指手势”（如三指扫动切换桌面）在通过 Synergy 转发时可能会失效。可以考虑使用 **BetterTouchTool (BTT)** 在 MBP 上将特定的手势映射为键盘组合键发送。

.. note::

   通过Synergy来结合MBP和Mac mini，可以省却购买控键盘（Magic Keyboard）和妙控板（Magic Trackpad），同时还能充分使用MBP屏幕来看参考文档，使用4K屏幕(连Mac mini)进行开发。

参考
======

本文和gemini讨论后总结，待后续实践
