.. _tile_window_in_lxqt:

============================
LXQt环境平铺窗口
============================

LXQt的窗口管理器是Openbox，所以修订 ``~/.config/openbox/rc.xml`` 添加如下内容

.. literalinclude:: tile_window_in_lxqt/rc.xml
   :language: xml
   :caption: LXQt配置Openbox实现Tile Window: ~/.config/openbox/rc.xml

- 然后在图形终端模拟器中执行::

   openbox --reconfigure

就能够生效。

参考
======

- `Lubuntu 19.10 & 20.04: How to tile windows? The window tiling section is missing in lxqt-rc.xml <https://askubuntu.com/questions/1182097/lubuntu-19-10-20-04-how-to-tile-windows-the-window-tiling-section-is-missing>`_
