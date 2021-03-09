.. _xfce:

============
Xfce
============

- 安装XFce4::

   sudo pacman -S xfce4

.. note::

   参考 `arch linux文档 - Xfce <https://wiki.archlinux.org/index.php/Xfce>`_ 设置Xfce，安装步骤可以参考 `How to Set Up the XFCE Desktop Environment on Arch Linux <https://www.maketecheasier.com/set-up-xfce-arch-linux/>`_ 和 `How to install Arch Linux with XFCE Desktop - Page 2 <https://www.howtoforge.com/tutorial/arch-linux-installation-with-xfce-desktop/2/>`_

   xfce4组合包含了基础软件包，如果还安装 ``xfce4-goodies`` 则会包含桌面组件

- 可以直接启动Xfce::

   startxfce4

- 中文设置

只需要安装一种中文字体'文泉驿'就可以正常在图形界面显示中文，并且这个字体非常小巧::

   pacman -S wqy-microhei

安装输入法fcitx(主要考虑轻量级)::

   pacman -S fcitx fcitx-sunpinyin fcitx-im

.. note::

   fcitx-im 是为了包含所有输入模块，包括 fcitx-gtk2, fcitx-gtk3, 和 fcitx-qt5

   fcitx-sunpinyin 是输入速度和输入精度较为平衡的输入法，并且轻巧

   此外，现在推荐 fcitx-googlepinyin 

.. note::

   中文设置参考 `arch linux 文档 - Localization/Chinese <https://wiki.archlinux.org/index.php/Localization/Chinese>`_

   输入法fcitx参考 `arch linux 文档 - Fcitx (简体中文) <https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>`_

安装了fcitx之后，重新登陆Xfce桌面会自动启动fcitx(这里利用了session恢复)。不过还是建议还是采用在 ``.xinitrc`` 中明确配置启动fcitx::

   export GTK_IM_MODULE=fcitx
   export QT_IM_MODULE=fcitx
   export XMODIFIERS=@im=fcitx
   exec fcitx &

此时还没有能够通过 ``ctrl+space`` 唤出中文输入法。这里建议安装 ``fcitx-configtool`` 工具，安装以后在终端运行 ``fcitx-config-gtk3`` 命令就可以打开图形界面配置。

配置方法: 对于新安装的英文系统，要取消只显示当前语言的输入法（Only Show Current Language），才能看到和添加中文输入法(Pinyin, Libpinyin等)。添加输入法之后，按下 ``ctrl+space`` 就可以正常输入中文。

- 编辑 ``~/.xinitrc`` 添加::

   exec startxfce4

这样就可以简单执行 ``startx`` 启动桌面。

- 或者更方便使用显示管理器 LightDM (不过，我感觉多占用一个系统服务也是资源，所以没有安装)::

   sudo pacman -S lightdm

.. note::

   `7 Great XFCE Themes for Linux <https://www.maketecheasier.com/xfce4-desktop-themes-linux/>`_ 介绍了不同的XFCE themes，可以选择一个喜欢的安装。

   不过，我发现默认安装的theme，选择 Apperance 中的 Adwaita-dark Style就已经非常美观简洁，除了图标比较简陋以外，其他似乎不需要再做调整。

Theme
-----------

以下文档可参考Xfce theme:

- `8 Great XFCE Themes To Check Out <https://www.addictivetips.com/ubuntu-linux-tips/great-xfce-themes/>`_
- `Make Xfce look modern and beautiful <https://averagelinuxuser.com/xfce-look-modern-and-beautiful/>`_
- `4 Ways You Can Make Xfce Look Modern and Beautiful <https://itsfoss.com/customize-xfce/>`_

我感觉比较modern的是平面型(flat)的风格，推荐可以尝试一下 Arc 风格::

   pacman -S arc-gtk-theme

此外，图标可以选择安装 Flat Remix icons ::

   yay -S flat-remix

.. note::

   我在 :ref:`jetson_xfce4` 中没有安装其他第三方theme，主要是为了精简和减轻系统负担。不过，默认安装的xfce4 theme也有比较精巧的界面，例如，我选择 ``Greybird-compact`` 作为窗口管理器风格： ``Settings >> Window Manager`` 然后选择 ``Greybird-compact`` 可以使得窗口标题条占用较少的屏幕空间。

   我在 :ref:`pi_400_desktop` 中同样也没有安装附加的theme，也是为了减轻系统压力。我直接采用了 ``Window Manager`` 中的 ``Kokodi`` 风格，这个风格在高分屛上大小比较合适，并且提供了窗口的边缘立体阴影，非常有macOS的窗口风格。

.. note::

   对于高分辨率屏幕，字体有可能会显示较小，看起来比较吃力。在不修改显示器分辨率(不使用默认显示器分辨率虽然能够使得字体放大但是显示会模糊)，可以通过修改显示DPI来解决: ``Settings >> Appearance >> Fonts`` 然后调整 ``DPI`` 使用 ``Custom DPI settings`` 进行调整，例如，对于2K屏幕，调整为 ``108`` 可以达到普通屏幕 ``96`` DPI的显示效果。

   注意，DPI调整只影响字体显示，对图标显示不影响，适合编码工作放大字体。请参考 `DPI Calculator / PPI Calculator <https://www.sven.de/dpi/>`_ 进行计算以及常用显示器配置参考。

以下是我在 :ref:`jetson` 中使用xfce4的设置::

   Appearance >>
     Style >>
       Xfce
     Icons >>
       Ubuntu-Mono-Light
     Fonts >>
       Default Font: Sans 9
       Default Monospace Font: Monospace 9
       Rendering: Enable anti-aliasing
       DPI: 

   Window Manager >>
     Style >>
       Theme: Greybird-compact
       Title font: Sans Bold 9

   Window Manager Tweaks >>
     Compositor >> (我感觉启用display compositing会消耗资源)
       去除 Enable display compositing 选择

   Panel >>
     Panel1 >>
       Display >>
         Measurements >>
           Row Size (pixels) : 20 (默认是30，该数值调小可以使得工具条变窄)
     Panels2 >>
       Display >>
         Measurements >>
           Row Size (pixels) : 33 (默认是?，该数值调小可以使得工具条变窄)

高分辨率调优
----------------

高分辨率显示器下主要调整如下：

- 修改显示DPI来放大字体 120%: ``Settings >> Appearance >> Fonts`` 然后调整 ``DPI`` 使用 ``Custom DPI settings`` 进行调整，例如，对于2K屏幕，调整为 ``108`` 可以达到普通屏幕 ``96`` DPI的显示效果。
- Firefox通过放大 120%: 

  - 在浏览器地址栏输入 ``about:config`` 并回车
  - 搜索 ``layout.css.devPixelsPerPx`` ，默认参数是 ``-1`` 表示不调整。可以修改成 ``1.0`` 则对应标准的96 dpi字体。要设置放大20%，则设置 ``1.2``

- mupdf阅读器调整字体也是放大 120%就足够清晰

平铺窗口
===========

以往使用macOS的时候，非常羡慕Windows用户有一个平铺窗口(Tile window)的内置功能。好在虽然macOS没有提供的Tile window可以通过第三方软件来实现。

切换到Linux工作平台，开始使用Xfce桌面，惊喜发现这个平铺窗口的功能是Xfce的内置功能，只需要把窗口拖放到桌面的边缘就可以实现窗口平铺。不过，也有一个烦恼，就是由于默认的multi workspace，会导致拖放窗口切换到其他工作台。

改进的方法就是使用Xfce Window Manager快捷键，这样就不需要使用鼠标，完全可以做到和macOS平台的第三方窗口平铺软件一样的功能。

注意：系统默认没有给平铺窗口预设快捷键，需要使用 ``Setting >> Window Manger >> Keyboard`` 设置，我为了和macOS使用的第三方软件快捷键一致，采用如下快捷键

================================   ===================== 
平铺方式                             快捷键                  
================================   ===================== 
 Tile window to the top            ``Ctrl+Super+Up``       
 Tile window to the bottom         ``Ctrl+Super+Down``     
 Tile window to the left           ``Ctrl+Super+Left``     
 Tile window to the right          ``Ctrl+Super+Right``    
 Tile window to the top-left       ``Ctrl+Super+U``        
 Tile window to the top-right      ``Ctrl+Super+I``        
 Tile window to the bottom-left    ``Ctrl+Super+J``        
 Tile window to the bottom-right   ``Ctrl+Super+K``        
 Maximize window                   ``Ctrl+Super+Return``   
================================   ===================== 

屏幕锁定
==========

对于轻量级系统，我不希望搞复杂的屏保(占用磁盘也消耗内存)，仅仅需要一个简单的黑屏锁定。

`slock <http://tools.suckless.org/slock/>`_ 是一个简单的X display locker，简单到只有黑屏和单色屏幕，并且安装只占用几百K磁盘空间。

使用方法::

   slock

当触动锁屏状态的键盘，则现实一个单色的屏幕，此时也没有任何输入窗口或者按键。实际上，此时只要盲打输入当前帐号的密码就可以解开锁屏。非常轻量级。

slock还可以结合 ``xautolock`` 来使用，例如，没有交互10分钟自动锁屏::

   xautolock -time 10 -locker slock

快捷键输入字符串
=================

线上维护需要反复输入一些命令，打字非常浪费生命。所以安装X window平台 `xdotool <http://www.semicomplete.com/projects/xdotool/xdotool.xhtml>`_  工具。

以下脚本存储为 `~/bin/sendtext.sh` ::

   #!/usr/bin/bash
   text=(
   windowid=$(xdotool getwindowfocus)
   sleep 0.1 && xdotool windowactivate --sync $windowid type $text

在LXQt和Xfce管理桌面快捷键中创建一个新的快捷键 ``Meta-t`` ，则在Windows或Mac系统按下 ``Window`` 键/ ``Command`` 键加上 ``t`` 键，就会向当前窗口发送`text`这个字符串。只需要修改一下脚本，替换成你希望输入的大段文本，就可以一键输入大量的文字，堪称节约生命的神器。

应用软件
==========

thunar
---------

thunar轻量级强大的文件管理器，提供了插件支持文件压缩和解压缩::

   pacman -S thunar-archive-plugin

xfce4-terminal
------------------

xfce4-terminal兼顾了轻量级和功能丰富，可以在xfce桌面替代常用的uxterm/xterm。

GoldenDict(取消)
-------------------

`GoldenDict <http://goldendict.org/>`_ 是使用WebKit引擎的字典软件，支持各种字典文件，也支持在线字典查询。不过软件以来qt5-webkit，会占用较大的系统资源(安装占用140MB磁盘空间)。

- 安装::

   pacman -S goldendict

.. note::

   现在已经不再单独安装字典软件，而是采用在线的google translate。

flameshot
---------------

`Flameshot <https://flameshot.js.org/>`_ 是一个轻量级截图软件，并且支持直接图形编译，添加一些标注。并且flameshot和Xfce集成非常完美，能够在托盘驻留，编辑后的截图还可以传送给其他程序进一步出来。

- 安装::

   pacman -S flameshot

mupdf
----------------

`mupdf <https://mupdf.com>`_ 是一个开源的采用C语言编写的PDF, XPS和EPUB阅读器，性能非常卓越，并且安装体积小依赖少::

   pacman -S mupdf

mupdf非常简洁，甚至没有提供菜单，但是基本功能完备。使用 ``ctrl`` 键结合鼠标滚轮可以方法缩小页面（对于MacBook Pro的Retina屏幕，epub和pdf显示的字体都太小了)。

midori(取消)
----------------

虽然chrome已经成为浏览器的事实标准，但是chromium实在太庞大沉重了。xfce项目推荐的集成的浏览器是midori。虽然midori一度停止开发，但是现在再次活跃开发。作为轻量级的 webkit 引擎浏览器，比chromium消耗资源少，也能兼容大多数网站。

在 :ref:`jetson_nano` 上使用的默认浏览器是chromium，可以通过 :ref:`arm_build_midori` 方式安装。

.. note::

   我实践发现midori兼容性不能满足日常使用，所以还是只结合采用firefox和chromium: chromium主要用于工作(大量的工作网站只兼容chrome)，个人使用则主要采用firefox(感觉更为轻巧)
