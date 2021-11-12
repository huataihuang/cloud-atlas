.. _pandoc:

=====================
pandoc 文档转换工具
=====================

在撰写 :ref:`sphinx_doc` 时，也有一些以前使用markdown格式撰写的文档需要转换。

`开源文档转换工具pandoc <https://pandoc.org/>`_ 是一个瑞士军刀般的文档工具:

- 轻量级markup格式(markdown, reStructuredText, Emacs Org-Mode...)
- HTML格式
- Ebooks(epub,Fictionbooks)
- Word处理(微软Word docx, 富文本RTF, OpenOffice/LibreOffice ODT, OpenDocument XML, 微软PowerPoint)
- Wiki markup格式(MediaWiki markup, DokuWiki markup, TikiWiki markup ...)
- Slide show格式
- PDF

安装
=======

- macOS安装::

   brew install pandoc

- Linux各个发行版都提供了pandoc，在Debian/Ubuntu中安装非常简单::

   sudo apt install pandoc

简单使用
==========

- 将markdown转换成reStructuredText::

   pandoc readme.md --from markdown --to rst -s -o readme.rst

- `Pypandoc <https://github.com/bebraw/pypandoc>`_ 是一个简单的pandoc的python wrapper，可以用来转换文档::

   pip install pypandoc

转换操作只有2行代码::

   import pypandoc
   output = pypandoc.convert('somefile.md', 'rst')

参考
======

- `Pandoc: Best Way To Convert Markdown to reStructuredText! <https://avilpage.com/2014/11/pandoc-best-way-to-convert-markdown-to.html>`_
