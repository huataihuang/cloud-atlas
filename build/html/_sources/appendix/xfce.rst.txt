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

应用软件
==========

GoldenDict
------------

`GoldenDict <http://goldendict.org/>`_ 是使用WebKit引擎的字典软件，支持各种字典文件，也支持在线字典查询。不过软件以来qt5-webkit，会占用较大的系统资源(安装占用140MB磁盘空间)。

- 安装::

   pacman -S goldendict
