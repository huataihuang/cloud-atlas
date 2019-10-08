.. _write_doc:

=============
写文档
=============

正如我在撰写 :ref:`cloud_atlas` ，文档是我数理知识和想法最好的方式。我采用以下方式撰写文档:

- Sphinx Doc
- MkDocs
- GitBook

GitBook是我最早撰写 :ref:`cloud_atlas` 的 `Cloud Atlas 草稿 <https://github.com/huataihuang/cloud-atlas-draft>`_ 时使用的文档撰写平台。但我感觉GitBook采用Node.js来生成html，效率比较低，对于大量文档生成非常缓慢。所以我仅更新源文件，很少再build生成最终的html文件。

Sphinx Doc是我撰写 :ref:`cloud_atlas` 的文档平台，我是模仿Kernel Doc的结构来撰写文档的，现在已经使用比较得心应手，感觉作为撰写书籍，使用Sphinx Doc是比较好的选择。

不过，Sphinx采用的reStructureText格式比较复杂(功能强大)，日常做快速笔记不如MarkDown格式。我发现MkDocs比较符合我的需求：

- 美观
- MarkDown语法
- 文档生成快速

.. note::

   Sphinx Doc 和 MkDocs 都采用Python编写，可以共用Python virtualenv环境，这也是我比较喜欢这两个文档撰写工具的原因。

Python Virtualenv
===================


