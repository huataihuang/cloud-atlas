.. _light_terminal:

====================
轻量级终端
====================

作为运维和Linux服务器端开发，主要的工作都是在terminal终端中完成，所以选择轻量级的终端非常重要。我个人比较倾向于无KDE和无GNOME依赖的纯GTK/Qt类型终端:

选择
=============

选择终端程序的思路是:

- 终端程序的底层依赖最小化:

  - 应该选择不依赖于大而全的 :ref:`kde` 或GNOME环境的终端，原因是如果基于KDE和GNOME的底层开发，则会带入大量的相关依赖安装，很多功能实际上完全是锦上添花，几乎没有使用的必要
  
- 对中文字体和中文输入法友好:

  - 作为中文使用者，不可避免有大量的中文输入，就需要面对繁杂的中文字体配置( :ref:`qterminal_chinese_font` )和中文输入法适配( :ref:`fcitx` ):

    - 首先排除掉难以配置中文字体的终端(即使轻量级的xterm和urxvt理论上也支持中文字体，但是互联网上难以找到真正能够实践成功的资料)
    - 现代中文输入法主要针对GTK和Qt开发，所以对输入法友好的的终端必然是基于这两者开发: 排除掉优秀的基于 :ref:`wayland` 开发的GPU加速 ``alacritty`` (遗憾)

  - 终端需要使用正宽字体(MonoSpace):

    - 需要方便配置选择中文字体: 大多数国外开发的终端程序很少兼顾中文字体，需要反复尝试和对比才能选择较为合适的终端

缩小选择范围，也就是纯基于GTK和Qt的，并且支持中文输入的终端:

- ``qterminal`` : 和 ``LXQt`` 最为契合，轻快且具有很多定制界面功能，对中文输入也友好(Qt5)，能够非常容易使用 :ref:`fcitx` 进行中文输入。但是这个程序能够使用的字体很少( 实际是因为强制过滤选择 ``monospace`` 所以无法选择中文字体: `How to use more fonts? #333 <https://github.com/lxqt/qterminal/issues/333>`_  )， :strike:`导致无法选择文泉驿中文字体，在中文显示上会出现中文显示略大于英文无法对齐，正在输入的那一行中文头部显示不完整。` 通过选择正确的Mono字体，可以实现 :ref:`qterminal_chinese_font`
- ``lxterminal`` : 原生 ``LXDE`` 终端(LXQt前身)，只使用GTK所以非常轻量级。对中文字体支持极佳，可以选择文泉驿中文字体所以撰写中文文档非常方便。不过在LXQt中运行，使用 :ref:`tile_window_in_lxqt` 时无法完全平铺满屏幕，总是露出一条空白让强迫症非常难受。

综上我的选择: :ref:`qterminal`

其他终端
========

大多数终端程序其实都是依赖于GNIME或者KDE的核心，所以功能和绚烂程度都相差无几。比较有特色的可能是:

- 下拉式终端: `令人眼前一亮的下拉式终端 Tilda & Guake <https://segmentfault.com/a/1190000008787828>`_

- 支持透明度终端: 目前看来很多系统已经支持

.. note::

   - 对于我个人而言，倾向于使用操作系统快捷键，所以 :ref:`openbox_keybind` 结合 :ref:`tile_window_in_lxqt` 可以不弱于下来式终端
   - 透明终端虽然比较科幻，但是实际上对于终端操作带来影响，所以舍弃

