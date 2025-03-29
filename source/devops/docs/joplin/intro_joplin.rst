.. _intro_joplin:

============================
Joplin简介
============================

需求
======

虽然Evernote提供了非常完善的知识管理功能(收集、整理、复习)，但是Evernote并不开源，并且使用私有文档格式，不支持开源文档常用的MarkDown格式。所以，我一直以来想找一个更好的个人知识管理工具:

- 支持MarkDown
- 多设备同步(跨平台)
- 开源或者开放: 文档格式开放可以随意导出到不同平台，避免锁定
- 文档管理简便：著名的Notion实在功能太复杂了，并且绑定平台服务
- 最好支持WEB抓取便于搜集资料

Joplin带给我们什么
=====================

开源的Markdown实现 `Joplin笔记应用 <https://joplinapp.org>`_ :

- 开源
- 提供Note和to-do记录，可以处理大量的笔记，并且可以搜索、复制、标签，也支持采用独立应用编辑
- 支持不同的服务端进行多设备同步，例如可以使用开源的 NextCloud ，也可以自建 :ref:`webdav` 服务器进行同步
- 支持 :ref:`joplin_import_evernote` 并且导入时保留完整元数据(位置，创建时间和更新时间等等)；微软的OneNote可以先导出导入到Evernote再导入Joplin
- 跨平台客户端: Windows, Linux, macOS, Android, iOs 都有客户端
- 通过 `Jopline Cloud <https://joplinapp.org/plans/>`_ (位于法国的云计算厂商收费服务)可以实现多设备同步记事本同步以及企业团队协作；也支持其他云同步，如 Nextcloud, Dropbox, OneDrive
- 基于浏览器(chome和firefox)的插件可以实现网页抓取

.. note::

   `AlternativeTo: Open Source Note Taking Apps <https://alternativeto.net/category/productivity/note-taking/?license=opensource>`_ 提供了开源笔记软件对比(你可以以这个列表来参考尝试): 最为推举的开源Note Taking就是 `Joplin笔记应用 <https://joplinapp.org>`_

我日常工作和思考的整理采用 :ref:`mkdocs` 完成，相当于最后的文档化，所以会非常仔细和反复打磨。不过，日常有一种随手记的需求，可以采用Joplin实现，多设备同步并作为初步的Inbox，为后续 :ref:`mkdocs` 做初步的资料加工::

   阅读/灵感(joplin) => 系统化文档(mkdocs)

.. note::

   我准备自建 :ref:`webdav` 进行多设备同步。


