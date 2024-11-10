.. _embed_fonts_into_pdf:

========================
PDF嵌入字体
========================

在使用 :ref:`kobo_libra_h20` 阅读中文PDF时候，我发现中文页面是完全空白的。这表明PDF文档没有内嵌字体(以前在 :ref:`linux` 平台阅读中文PDF时常遇到)，解决的方法是修订PDF，将其引用的字体嵌入到PDF文件中。

方法一: 通过postscript实现
=============================

当PDF文档转换成PS文档，然后再转换回PDF时，所生成的PDF文件将内嵌所需字体:

.. literalinclude:: embed_fonts_into_pdf/pdf_ps
   :caption: 通过 PDF->PS->PDF 格式转换来将字体嵌入到PDF中

方法二: 通过PDF打印实现
=========================

在桌面系统中，当通过PDF打印时选择 ``save to pdf`` 功能，就会实现依次PDF打印到PDF文件的过程，且这个过程会嵌入所需字体(Windows平台也是如此):

- 我使用的是 :ref:`firefox` 来阅读PDF(包括网络下载PDF文档也是FireFox内部打开阅读)，此时使用Firefox的文档打印功能能:

.. figure:: ../../../_static/devops/docs/kobo/firefox_print.png

   利用打印到PDF的功能将字体内嵌

参考
======

- `Fonts are not embedded into a pdf? <https://askubuntu.com/questions/50274/fonts-are-not-embedded-into-a-pdf>`_
