.. _xfce:

============
Xfce
============

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
