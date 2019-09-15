.. _seamless_rdp:

===========================
Seamless RDP使用Windows应用
===========================

安装rdp客户端
================

Linux平台远程RDP客户端是rdesktop或者freerdp，为了方便使用，可以结合Remmina(图形配置客户端)一起使用。不过，Remmina默认没有集成rdesktop插件，需要单独通过AUR安装 ``remmina-plugin-rdesktop`` ::

   pacman -S rdesktop remmina
   yay -S remmina-plugin-rdesktop



参考
=========

- `arch linux社区文档 - Remmina <https://wiki.archlinux.org/index.php/Remmina>`_
- `arch linux社区文档 - Redsktop <https://wiki.archlinux.org/index.php/Rdesktop>`_
- `Guide - Using Seamless RDP for native looking Windows applications <https://forums.macrumors.com/threads/guide-using-seamless-rdp-for-native-looking-windows-applications.1984261/>`_
- `Remmina Setting <http://www.muflone.com/remmina-plugin-rdesktop/english/settings.html>`_
