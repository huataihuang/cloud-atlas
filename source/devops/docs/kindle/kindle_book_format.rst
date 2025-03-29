.. _kindle_book_format:

===================
Kindle电子书格式
===================

虽然Kindle即将退出中国，但是并不妨碍我们使用它来阅读学习。对于瓷器国居民，不得不采用 ``曲径`` 方式( :ref:`calibre_remove_drm` + :ref:`convert_doc_to_kindle` )，来解决2023年6月20日Kindle退出中国市场的困扰。

常用电子书格式有 mobi, azw, azw3, epub ，这些电子书格式本质上都是HTML文档转换过来，所以大多数HTML标签和CSS样式表特性都支持，它们之间的区别在于对排版以及新特性支持程度。

mobi和azw格式
==============

mobi和azw都是亚马逊的私有格式，没有本质区别。简单而言，mobi是早期格式，azw只是mobi增加了DRM版权保护。目前mobi主要是其他电子书格式，如epub、pdf或txt转换而来，通常是自出版作者通过KDP(Kindle Direct Publishing)直接在Amazon发售电子书。通过KDP平台发布，作者只需要上传Word文档，就可以由Amzon官方平台保证mobi文件规范发布。

azw3格式
==========

azw3是2011年Amazon随着Kindle Fire平板一起推出的电子书格式，填补了mobi对于复杂排版支持的缺陷，支持很多HTML5(目前不支持HTML5视频和音频标签)和CSS3语法，和epub格式功能相当。目前Amazon官方购买书籍大多数是azw3格式，已经是Kindle电子书的主流格式。

epub格式
===========

维基百科对 epub 的定义：EPUB（Electronic Publication 的缩写，电子出版）是一种电子图书标准，由国际数字出版论坛（IDPF）提出；其中包括 3 种文件格式标准（文件的附文件名为 .epub），这个格式已取代了先前的 Open eBook 开放电子书标准。

epub格式是开放标准，支持复杂的排版、图表、公式等，摒弃支持脚本、矢量图形等。epub格式的主要优势是图文混排，图片嵌入字体等，未来还会对音频、视频等多媒体内容互动支持。epub有各种制作软件，例如 Sigil、Calibre、Jutoh等软件，但是不同的制作软件制作的epub并不一定符合标准并且可能存在不兼容。

Calibre工具支持不同电子书格式转换，但是需要注意新格式azw3转换成mobi后会产生格式丢失问题。此外，还有Kindle官方提供的 :ref:`convert_doc_to_kindle`

参考
=====

- `kindle支持什么格式的电子书 <https://www.jianshu.com/p/d1925188f627>`_
