.. _chromecast_linux:

====================================
从Linux平台Cast Media到Chromecast
====================================

chrome内置cast
=================

Google Chome浏览器(包括开源chromuim)，都内置了将当前浏览页面直接Cast给Google Chromecast设备的能力，无需配置，直接从下拉菜单中选择 ``Cast...`` 就可以找打局域网中的Chromecast设备

Mkchromecast
=================

`muammar/mkchromecast <https://github.com/muammar/mkchromecast>`_ 开源Mkchromecast提供了在macOS和Linux平台向Google Cast设备发送cast的能力。请按照官方文档进行安装。以下是我在 :ref:`arch_linux` 上安装(使用 :ref:`archlinux_aur` )::

   yay -S mkchromecast-git

- 首先需要配对 chromecast设备，在终端中输入以下命令::

   mkchromecast -t

可能会报错，显示缺少Qt相关模块::

   Traceback (most recent call last):
     File "/usr/bin/mkchromecast", line 15, in <module>
       from mkchromecast.cast import Casting
     File "/usr/lib/python3.10/site-packages/mkchromecast/cast.py", line 9, in <module>
       from mkchromecast.preferences import ConfigSectionMap
     File "/usr/lib/python3.10/site-packages/mkchromecast/preferences.py", line 62, in <module>
       from PyQt5.QtWidgets import (
   ModuleNotFoundError: No module named 'PyQt5.QtWidgets'

则补充安装 ``python-pyqt5`` 后再重试即可(按照官方文档，这个 ``PyQt5`` 是可选的，安装以后可以提供系统托盘菜单，我在 :ref:`lxqt` 中安装后确实可以看到系统托盘按钮)，此时终端显示::

   Mkchromecast v0.3.9
   Selected backend: /usr/bin/parec
   Selected audio codec: mp3
   Default bitrate used: 192k
   Default sample rate used: 44100Hz.

- 在系统菜单右击 ``Mkchromecast`` 图标，然后选择菜单 ``Search for Media Streaming Devices`` ，此时就会在终端显示::

   List of Devices Available in Network:
   -------------------------------------
                                                                                                                          
   Index   Types   Friendly Name 
   =====   =====   ============= 
   0       Gcast   Family Room TV
   available_devices received
   Available Media Streaming Devices [[0, 'Family Room TV', 'Gcast']]

这表明找到了局域网中的Chromecast设备

- 现在就可以在 ``Mkchromecast`` 图标的右击菜单中找到可以cast的设备 ``Family Room TV`` ，勾选该设备

.. note::

   我遇到一个问题，虽然连接上，但是没有输出内容。待后续排查

参考
=====

- `Mkchromecast.com <https://mkchromecast.com/>`_
- `How to Cast Video from Ubuntu to Chromecast <https://vitux.com/how-to-cast-video-from-ubuntu-to-chromecast/>`_
