.. _joplin:

============================
Joplin - 开源Markdown编辑器
============================

虽然Evernote提供了非常完善的知识管理功能(收集、整理、复习)，但是Evernote并不开源，并且使用私有文档格式，不支持开源文档常用的MarkDown格式。所以，我一直以来想找一个更好的个人知识管理工具:

- 支持MarkDown
- 多设备同步(跨平台)
- 开源或者开放: 文档格式开放可以随意导出到不同平台，避免锁定
- 文档管理简便：著名的Notion实在功能太复杂了，并且绑定平台服务
- 最好支持WEB抓取便于搜集资料

最近，我找到一个开源的Markdown实现 `Joplin笔记应用 <https://joplinapp.org>`_ :

- 开源
- 支持不同的服务端进行多设备同步，例如可以使用开源的 NextCloud ，也可以自建 :ref:`webdav` 服务器进行同步
- 跨平台客户端：提供了iOS版本客户端，也就是你可以在电脑上编辑，在手机上阅读
- 有开发了基于浏览器的插件可以实现网页抓取

.. note::

   `AlternativeTo: Open Source Note Taking Apps <https://alternativeto.net/category/productivity/note-taking/?license=opensource>`_ 提供了开源笔记软件对比(你可以以这个列表来参考尝试): 最为推举的开源Note Taking就是 `Joplin笔记应用 <https://joplinapp.org>`_

我日常工作和思考的整理采用 :ref:`mkdocs` 完成，相当于最后的文档化，所以会非常仔细和反复打磨。不过，日常有一种随手记的需求，可以采用Joplin实现，多设备同步并作为初步的Inbox，为后续 :ref:`mkdocs` 做初步的资料加工::

   阅读/灵感(joplin) => 系统化文档(mkdocs)

.. note::

   目前我还没有时间仔细研究，但是这个开源软件的发展方向让我比较中意，我准备自建 :ref:`webdav` 进行多设备同步。
