.. _archlinux_ms_fonts:

========================
Arch Linux Windows字体
========================

安装微软字体
===============

- 如果有一个安装了Windows的分区，可以通过链接来使用字体。假设 Windows 的C:\盘挂在在 ``/windows`` 目录::

   ln -s /windows/Windows/Fonts /usr/share/fonts/WindowsFonts

- 然后重新生成字体缓存::

   fc-cache -f

.. note::

   也可以直接将Windows字体复制到 ``/usr/share/fonts`` 目录

参考
======

- `<Arch Linux社区文档 - Microsoft fonts (简体中文) <https://wiki.archlinux.org/index.php/Microsoft_fonts_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)>`_
