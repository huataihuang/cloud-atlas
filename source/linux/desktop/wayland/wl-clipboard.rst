.. _wl-clipboard:

================================
Wayland环境剪贴板wl-clipboard
================================

.. note::

   `arch linux: Clipboard <https://wiki.archlinux.org/title/clipboard>`_ 介绍了不同环境的剪贴板工具，可以参考

`wl-clipboard: Wayland clipboard utilities <https://github.com/bugaevc/wl-clipboard>`_ 是 :ref:`wayland` 环境下的剪贴板工具，特别适合对大型文件进行复制粘贴::

   # copy a simple text message
   $ wl-copy Hello world!

   # copy the list of files in Downloads
   $ ls ~/Downloads | wl-copy

   # copy an image file
   $ wl-copy < ~/Pictures/photo.png

   # paste to a file
   $ wl-paste > clipboard.txt

   # grep each pasted word in file source.c
   $ for word in $(wl-paste); do grep $word source.c; done

   # copy the previous command
   $ wl-copy "!!"

   # replace the current selection with the list of types it's offered in
   $ wl-paste --list-types | wl-copy

参考
======

- `wl-clipboard: Wayland clipboard utilities <https://github.com/bugaevc/wl-clipboard>`_
