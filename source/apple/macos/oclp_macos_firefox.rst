.. _oclp_macos_firefox:

====================================
使用OCLP安装最新macOS后Firefox调整
====================================

在 :ref:`oclp_macos` 之后，我发现Firefox使用一段时间后，会莫名其妙出现 ``Firefox GPU Helper`` 大量占用CPU资源，CPU使用率达到 600%，也就是几乎把所有cpu资源都耗尽了。

gemini解释:

:ref:`mbp15_late_2013` :ref:`oclp_macos` 后，流畅的系统界面，完全是 OCLP 的非官方图形补丁（Graphics Patches）在底层通过软件指令集翻译 + 部分注入驱动“模拟”出来的。

而在现代 macOS 中，浏览器的页面渲染、视频解码、滚动动画都已经完全依赖苹果的 Metal API 硬件加速。 ``Firefox GPU Helper`` 进程正是 Firefox 专门派生出来、与系统 GPU 驱动进行对接并传输渲染指令的“联络官”:

- 2013 款 MBP 的旧显卡物理上并不完全支持 macOS 15 的现代 Metal 3 规范
- 当 Firefox 尝试调用高级图形特效、或者是播放特定格式的视频（如 YouTube 默认的 AV1 或 VP9 视频硬解）时， ``Firefox GPU Helper`` 尝试向显卡申请硬件加速。但由于 OCLP 模拟出的驱动无法通过该指令，导致进程陷入了 ``申请硬件渲染 -> 失败报错 -> 重新申请 -> 报错`` 的无限死循环
- 协商失败后，Firefox 被迫用 CPU 的多线程去强行“软件模拟”原本由 GPU 负责的渲染或视频转码，这导致CPU负载过高

解决方法
==========

关闭 Firefox 内部的硬件加速
-----------------------------

对于打过 OCLP 补丁的老 Mac，让浏览器放弃部分复杂的 GPU 硬件加速，改用稳定的 2D 基础渲染，能够瞬间解决 90% 的卡死和暴走问题:

- 打开 Firefox，在地址栏输入 ``about:preferences`` 并回车
- 在 ``常规 (General)`` 面板中，向下滚动找到 ``性能 (Performance)`` 区域
- **取消勾选** ``使用推荐的性能设置 (Use recommended performance settings)``
- 随后，下方会出现新选项 **取消勾选** ``使用硬件加速（如果可用）(Use hardware acceleration when available)``
- 彻底重启 Firefox 浏览器

禁用死循环的底层 WebGL 特效
-----------------------------

很多现代网页（如 3D 渲染、复杂的金融图表、甚至部分带动态特效的网页）会自动调用 WebGL。在 OCLP 驱动下，WebGL 极易导致 GPU Helper 进程崩溃崩溃并吃满 CPU。

- 在 Firefox 地址栏输入 ``about:config`` ，点击 ``接受风险并继续``
- 在搜索框中输入： ``webgl.disabled``
- 双击将该值从 ``false`` 修改为 ``true`` （即禁用 WebGL）
- 接着搜索： ``layers.acceleration.disabled``
- 将其修改为 ``true``
- 重启浏览器

.. note::

   关闭 WebGL 仅影响少数 3D 网页游戏的运行，对于日常写代码、看文档、查资料的体验没有任何负面影响，反而会让系统更加稳定。

解决视频硬解问题
-----------------

如果播放网页视频发生CPU使用率暴涨，则是因为 2013 MBP 的显卡无法硬解现代的高清视频编码，需要强制让浏览器使用兼容的 H.264 编码:

- 在 Firefox 的 ``扩展与主题 (Add-ons & Themes)`` 里搜索并安装插件： ``Enhanced-h264ify``
- 点击该插件图标，勾选 ``Block VP8`` 、 ``Block VP9`` 、 ``Block AV1``

这样会强制 YouTube 等网站退回到最古老、但 :ref:`mbp15_late_2013` 硬件本身支持硬解的 H.264 (AVC) 编码。这能极大地释放 CPU 解码压力，视频播放时的发热量也会断崖式下跌。

.. note::

   当前我尚未遇到YouTube访问问题，所以暂时没有采用这个步骤

补充
======

如果发现关闭硬件加速后，系统整体拖动网页有些轻微的果冻效应，可以检查一下是否是因为 macOS 15 的微版本更新，导致 OCLP 驱动失效了:

- 打开 ``OpenCore Legacy Patcher`` 客户端
- 点击 ``Post-Install Root Patch``
- 如果按钮显示有新补丁或需要 Re-patch，则点击并重新应用驱动补丁，然后重启电脑

参考
======

- gemini 实践有效，记录本文
