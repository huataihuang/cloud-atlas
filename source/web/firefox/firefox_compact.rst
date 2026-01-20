.. _firefox_compact:

=========================
Firefox优化UI紧凑方法
=========================

我在 :ref:`thinkpad_x220` 上使用 :ref:`freebsd_sway` 桌面，感觉一个很大的困扰就是，早期的笔记本屏幕分辨率很低，并且这款笔记本为了轻便，屏幕极小。这导致默认的Firefox UI显得特别臃肿，网页内容展示空间相应就非常狭小。

很久以前Firefox还支持 ``compact`` 插件来压缩UI占用的空间，但是现代的Firefox已经没有这样的方便的插件兼容了，所以需要通过一些技巧来优化:

- 开启Firefox 自带的“紧凑模式”(Compact Mode) -- **实测有效**

  - 在地址栏输入 about:config 并回车，点击“接受风险并继续”
  - 搜索 ``browser.uidensity.hardcoded.compact`` 将该项指双击改为 ``true``
  - 右击工具栏，将Tab栏改为垂直，并通过快捷键 ``ctrl-alt-z`` 控制tab工具栏的展示，这样可以极大优化tab的占用

- 调整界面缩放比例 (UI Density) -- **实测有效** ``这个方法强烈推荐``

  - 进入 ``about:config``
  - 搜索 ``layout.css.devPixelsPerPx``
  - 将值从 ``-1.0`` 改为 ``0.9`` 或 ``0.8`` : 我的实践是将该数值设为 ``0.8`` 最符合我的ThinkPad X220屏幕(另外，我将默认字体从 ``16`` 改为 ``14`` )

.. note::

   该方法实际上就是调整屏幕缩放比例，以前我在 :ref:`xfce` 桌面使用过，现在单独对firefox设置非常有效。需要注意这会缩小整个浏览器(包括网页内容和菜单)

- 使用 UserChrome.css 深度定制 -- **实测不佳**

  - `Lepton's Photon Style <https://github.com/mut-ex/minimal-functional-fox>`_ 主题配置，不过我使用下来发现不喜欢

- 推荐的扩展插件 -- 我没有使用

  - Sidebery 或 Tab Stash: 配合隐藏顶部标签栏使用
  - uBlock Origin: 移除网页上的悬浮广告和遮挡物
  - Fullscreen Plus: 允许你在全屏模式下依然保留部分功能条，或者更灵活地切换视图

参考
======

本文根据Gemini的提示进行实践对比，筛选出我实践有效的方法
