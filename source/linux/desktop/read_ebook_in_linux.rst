.. _read_ebook_in_linux:

=======================
在Linux环境阅读电子书
=======================

除了 :ref:`use_kindle_read_pdf` ，也经常需要在工作的Linux桌面阅读技术书籍。不过，在 :ref:`run_sway` 的桌面，图形应用程序需要适配 :ref:`wayland` ，所以需要合理选择电子书阅读器:

- 轻量级电子书阅读器能够更匹配 :ref:`raspberry_pi` 有限的硬件
- 能够阅读 pdf 和 epub

okular
===============

okular是KDE桌面默认电子书阅读器，内置支持pdf阅读:

- pdf阅读功能比较完美，打开pdf速度很快，在 :ref:`pi_400` (已经做过 :ref:`pi_overclock` 优化)滚动pdf时，占用一个cpu core大约50%，还算比较轻量级
- 对于 ``epub`` 书籍需要通过插件来支持，但是实际插件性能不高: 只能单cpu core运行，滚动epub文档时会占用整个cpu core，所以明显有卡顿

总体来说 ``okular`` 适合阅读pdf文档，但是作为大而全的框架，通过插件支持阅读其他格式依然存在不足。实际上，和Gnome桌面默认的 ``gnome-books`` 类似， ``okular`` 提供的是一种通用能力，支持广泛的阅读格式，但是也带来单项能力平庸的不足。

由于我使用 :ref:`wayland` 上的 :ref:`sway` 桌面，所以比较适合运行 QT5 的应用。 ``okular`` 作为KDE应用，阅读pdf文档还是及格的。不过，我还在探索找一个更为请谅解专注pdf阅读的工具

- 安装okular::

   sudo apt install okular okular-extra-backends

.. note::

   需要安装 ``okular-extra-backends`` 才能通过插件来支持 epub 阅读

evince
==============

evince是GNOME平台的一个通用文档阅读器，非常轻量级，专注于pdf文档阅读，占用资源少，所以配合 :ref:`sway` 使用还是非常适合的。

mupdf
==========

mupdf是一个同时支持 pdf 和 epub 的轻量级文档阅读器，从功能来说其实是最合适的，性能也非常卓越。不过，这个软件是面向 X11 开发的，在 :ref:`sway` 上没有运行，非常遗憾

zathura
===========

zathura是一个高度定制化的文档阅读器，基于GTK+，跨平台::

   sudo apt install zathura

你可以将zathura视为mupdf的再制版本，完全支持 :ref:`sway` 环境运行，非常轻量级，没有任何花哨的功能。

zathura最大特点是快(轻量级):

- 比 evince 差不多，默认安装使用 ``pdf-poppler`` 引擎

控制方式类似 :ref:`vim` ，例如按下 ``o`` 则在命令行提示打开文件

`zauthra plugins <https://pwmt.org/projects/zathura/plugins/>`_ 支持多种插件来实现不同文档格式。虽然默认不支持 epub ，但是借用 ``mupdf`` 引擎插件可以实现。不过ubuntu官方仓库没有提供 mupdf 插件，而可以通过第三方PPA安装::

   sudo rm /etc/apt/preferences.d/pin-zathura
   sudo add-apt-repository ppa:spvkgn/zathura-mupdf
   sudo apt-get install zathura zathura-pdf-mupdf

foliate
=========

`foliate <https://johnfactotum.github.io/foliate/>`_ 是一个现代化电子书阅读器::

   sudo add-apt-repository ppa:apandada1/foliate
   sudo apt-get update
   sudo apt install foliate

不过，我在Raspberry Pi OS上安装实践未成功(安装并没有找到对应软件包)

calibre
==================

calibre 是全功能的电子书库管理软件，提供阅读、转换和分类电子书的功能，并且可以和主要的电子书阅读设备通讯，能够从internet获取电子书的元信息，以及下载封面转换到电子书，以及夸平台工作哦。

:ref:`calibre_remove_drm` 可以自由在Linux平台阅读自己购买的电子书:

- 将在Kindle商店购买的电子书通过Google Books存储和传输，可以实现跨平台阅读(Apple ibook虽然好用但是非常封闭)，支持pdf和epub
- 使用移动设备，如 :ref:`pixel_3` 和 :ref:`iphone_se1` 中Google Books客户端来实现移动阅读


``calibre`` 可以说是全功能的电子书处理软件，并且提供了 ``ebook-viewer`` 工具来阅读电子书:

- ``ebook-viewer`` 处理 ``epub`` 电子书非常高效，在打开文档渲染时就明显能够看出速度远超 okular (epub插件)，从 top 命令可以看到实际上 ``ebook-viewer`` 是多线程处理epub文档，解析时可以充分利用多处理器的优势
- ``ebook-viewer`` 非常适合阅读epub文档，渲染加载以后，阅读滚动几乎不占用cpu资源，流畅清晰
- 但是 ``ebook-viewer`` 阅读pdf文档存在不足: 加载pdf文档时可以看到启动了 ``pdf2htm`` 程序进程转换，实际上最后阅读的是pdf转换成html的文档，对于阅读文字没有影响，但是pdf排版格式会丢失，所以使用上不建议使用 ``ebook-viewer``  阅读pdf文档

我的选择
===========

几乎没有一个电子书阅读器是全能而完美的:

- 通用型电子书阅读器，例如 ``okular`` 虽然能够通过插件支持不同格式电子书，但是显然只有原生pdf较为完善，而插件非常消耗资源
- 第三方阅读器，如 ``foliate`` 虽然更为现代化和功能丰富，但是没有发行版提供的安装源对于使用和维护不方便，仅仅为了一个阅读器功能手工维护安装性价比不高
- 发行版软件仓库同时提供了 ``zathura`` ，但是后端引擎采用 ``poppler`` 渲染，实际效果和GNOME默认pdf阅读器 ``evince`` 是完全一样的；虽然 ``zathura`` 还支持通过 ``mupdf`` 引擎插件支持 epub的电子书，但是该插件发行版没有提供，从源代码安装不发方便维护

.. note::

   如果后续采用 :ref:`gentoo_linux` 或者 :ref:`lfs_linux` 则从源代码编译，我比较倾向于：

   - ``foliate`` 独立支持不同格式电子书
   - ``zathura`` 使用 ``mupdf`` 后端同时支持 pdf 和 epub

初步选择
---------

- :strike:`okular阅读处理pdf文档，提供了标记和注释功能` 
- ``evince`` 作为GTK应用非常轻量级，专注于阅读pdf文档
- 使用 calibre 的 ``ebook-viewer`` 来阅读 epub 文档，轻量级快速

最终选择
-----------

- 如果同时兼做电子书转换，则采用 ``calibre`` ，只需要这个一个全功能软件就能满足电子书转换、管理和阅读
- 如果只阅读电子书，则采用 :ref:`mupdf` 这个全功能轻量级阅读器，采用快捷键控制，方便使用

参考
======

- `3 eBook readers for the Linux desktop <https://opensource.com/article/20/2/linux-ebook-readers>`_
- `Light epub reader? <https://www.reddit.com/r/linux/comments/98mob0/light_epub_reader/>`_
