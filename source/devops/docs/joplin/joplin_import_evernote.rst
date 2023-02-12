.. _joplin_import_evernote:

==========================
Joplin导入Evenote笔记
==========================

我曾经有很长一段时间使用Evernote来管理自己的笔记，特别是Evernote的Cliper功能帮助我搜集了很多WEB资料。不过，Evernote不支持Markdown，也比较封闭(例如很难在 :ref`linux` 使用)。这使得我在工作平台多次切换之后，逐步放弃使用复杂Evernote，改为使用 :ref:`mkdocs` 来整理个人笔记。不过， :ref:`mkdocs` 纯手写Markdown，缺少方便快捷的输入方式以及跨平台同步编辑。

为方便整理知识库(搜集素材)，我选择Joplin替代 :ref:`mkdocs` 。并且，Joplin也被设计成取代Evernote，所以提供了完整的Evernote导入功能:

- 笔记内容
- tags
- 资源(附件)
- 笔记的元数据(例如作者，地理位置等)

通过Evernote的 ``ENEX`` 文件，可以较为完整地导入Joplin:

- 辨识数据(Recognition data): Evernote的图片有相关的辨识数据以便Evernote可以在文档中识别他，但是导入到Joplin中无法表示，不过还是可以通过搜索找到
- 色彩: Evernote将文本保存为HTML，在导入到Joplin时会转为Markdown格式，此时大多数基本格式(黑体、斜体、列表，链接等)都能完整保留，这样重新渲染成HTML的样式就非常接近。表格会导入并转换成Markdown表格。但是非常复杂的笔记的一些格式会丢失

参考
======

- `Jopline Help: Importing from Evernote <https://joplinapp.org/help/#importing>`_
