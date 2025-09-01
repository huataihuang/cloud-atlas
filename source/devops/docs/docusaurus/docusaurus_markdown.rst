.. _docusaurus_markdown:

===========================
Docusaurus Markdown
===========================

.. note::

   这里汇总我使用的一些常用格式，以备参考

   完整请参考官方文档

链接
=========

有两种方式链接到其他页面:

- URL path: ``[URL path to another document](./installation)``
- file path: ``[file path to another document](./installation.mdx)``

代码块
========

- 代码块案例，以 ``bash`` 为例

.. literalinclude:: docusaurus_markdown/code
   :caption: 代码块案例
   :emphasize-lines: 1

这里的代码块方法和GitHub相同，但是需要注意Docusaurus默认只支持部分常用语言，并没有包含 ``bash`` / ``ruby`` 之类，所以需要修订配置

- 修改 ``docusaurus.config.js`` 添加 ``prism`` 的支持语言类型:

.. literalinclude:: docusaurus_markdown/docusaurus.config.js
   :caption: 修订 ``docusaurus.config.js`` 添加 ``prism`` 的支持语言类型
   :emphasize-lines: 5
