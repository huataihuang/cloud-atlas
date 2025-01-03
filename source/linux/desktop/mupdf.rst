.. _mupdf:

===============
MuPDF
===============

`MuPDF(.com) <https://mupdf.com/>`_ 是一个轻量级PDF,XPS和E-book阅读器，包含了一个软件库，命令行工具以及适用不同平台的viewer。

``mupdf`` 的最大特点是: 小、快、功能全

- 支持多种文档格式: PDF, XPS, OpenXPS, CBZ, EPUB, 和 FictionBook 2
- 命令行工具提供了注释、编辑以及转换到其他文档格式( HTML, SVG, PDF, 和 CBZ )
- 采用C语言编写，模块化可移植，所以能够非常容易按需添加和移除
- 提供了一个使用JNI的Java库，可以和Java、Android集成。
- MuPDF SDK:MuPDF框架可以用来阅读和转换PDF, XPS 和 E-book文档，可以在几乎所有平台编译和运行
- `MuPDF App Kit <https://mupdf.com/docs/appkit/guide/index.html>`_ : 可以快速在Android和iOS平台实现PDF阅读和编辑功能(发布应用程序需要获得商业license)

使用
======

快捷键绑定
-----------------

.. csv-table:: mupdf快捷键
   :file: mupdf/mupdf_key_bindings.csv
   :widths: 30,70
   :header-rows: 1

上述有些快捷键我在FreeBSD mupdf中没有验证成功，例如 ``F1`` , ``o`` 等

参考
======

- `MuPDF OpenGL viewer <https://mupdf.com/docs/manual-mupdf-gl.html>`_ Linux平台交互使用界面操作说明(不过原官网这篇文档找不到了)
- `manual mupdf-gl <https://www.jianshu.com/p/8e225bfb7a23>`_ 简书上搬运的官网manual
