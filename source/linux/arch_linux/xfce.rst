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

.. note::

   中文设置参考 `arch linux 文档 - Localization/Chinese <https://wiki.archlinux.org/index.php/Localization/Chinese>`_

   输入法fcitx参考 `arch linux 文档 - Fcitx (简体中文) <https://wiki.archlinux.org/index.php/Fcitx_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>`_

安装了fcitx之后，重新登陆Xfce桌面会自动启动fcitx。不过，此时还没有能够通过 ``ctrl+space`` 唤出中文输入法。这里建议安装 ``fcitx-configtool`` 工具，安装以后在终端运行 ``fcitx-config-gtk3`` 命令就可以打开图形界面配置。

配置方法: 对于新安装的英文系统，要取消只显示当前语言的输入法（Only Show Current Language），才能看到和添加中文输入法(Pinyin, Libpinyin等)。添加输入法之后，按下 ``ctrl+space`` 就可以正常输入中文。

- 编辑 ``~/.xinitrc`` 添加::

   exec startxfce4

这样就可以简单执行 ``startx`` 启动桌面。

- 或者更方便使用显示管理器 LightDM (不过，我感觉多占用一个系统服务也是资源，所以没有安装)::

   sudo pacman -S lightdm

.. note::

   `7 Great XFCE Themes for Linux <https://www.maketecheasier.com/xfce4-desktop-themes-linux/>`_ 介绍了不同的XFCE themes，可以选择一个喜欢的安装。

   不过，我发现默认安装的theme，选择 Apperance 中的 Adwaita-dark Style就已经非常美观简洁，除了图标比较简陋以外，其他似乎不需要再做调整。

平铺窗口
===========

以往使用macOS的时候，非常羡慕Windows用户有一个平铺窗口(Tile window)的内置功能。好在虽然macOS没有提供的Tile window可以通过第三方软件来实现。

切换到Linux工作平台，开始使用Xfce桌面，惊喜发现这个平铺窗口的功能是Xfce的内置功能，只需要把窗口拖放到桌面的边缘就可以实现窗口平铺。不过，也有一个烦恼，就是由于默认的multi workspace，会导致拖放窗口切换到其他工作台。

改进的方法就是使用Xfce Window Manager快捷键，这样就不需要使用鼠标，完全可以做到和macOS平台的第三方窗口平铺软件一样的功能。

注意：系统默认没有给平铺窗口预设快捷键，需要使用 ``Setting >> Window Manger >> Keyboard`` 设置，我为了和macOS使用的第三方软件快捷键一致，采用如下快捷键

================================   ===================== 
 平铺方式                          快捷键                  
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

GoldenDict
------------

`GoldenDict <http://goldendict.org/>`_ 是使用WebKit引擎的字典软件，支持各种字典文件，也支持在线字典查询。不过软件以来qt5-webkit，会占用较大的系统资源(安装占用140MB磁盘空间)。

- 安装::

   pacman -S goldendict

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
