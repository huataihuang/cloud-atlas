.. _tiddlywiki_startup:

==================
TiddlyWiki快速起步
==================

我在十几年前，曾经有一度非常痴迷wiki系统，想用wiki构建个人知识库。个人知识库的需求:

- 轻量级: 简单易用、易部署(不要依赖数据库)
- 便于平台切换: 跨平台，并且数据可以简单传输在不同平台使用

虽然我也在最近几年尝试几种不同的方法，但是也存在一些不足，使得我反过来想寻求最初的方案 ``TiddlyWiki``

- :ref:`mkdocs` : 通用MarkDown格式文档，静态生成WEB页面

  - 需要执行命令来构建web页面输出
  - 需要人工维护文档之间的关系(略有复杂)

- :ref:`joplin` : 跨平台MarkDown应用程序，各个平台都有App提供笔记功能(支持复制粘贴图片)

  - 运行比较缓慢
  - 需要构建一个 :ref:`joplin_sync_webdav` 来同步不同设备(复杂)

TiddlyWiki适合做什么
=======================

我感觉TiddlyWiki比较适合:

- 个人发散性的思维记录: 利用Wiki的随意性快速输入，通过标签聚合思维
- **个人学习理解并加工过的知识** : 建议是实际学习和掌握的，而不是简单资料搜集

  - TiddlyWiki需要一点点 **思维** 构建(Wiki系统的特征)，所以堆砌资料(复制粘贴)浪费了TiddlyWiki的优势
  - 不过，也可以将资料搜集分为不同的TiddlyWiki，用目录组织起来，但是建议是可分享的不包含敏感信息

- 方便跨平台使用: 通用的HTML/JS技术使得TiddlyWiki是一个开放平台，文档可以长存

  - 我考虑在 :ref:`mobile_pixel_dev` 的 :ref:`termux` 中运行 :ref:`tiddlywiki_on_nodejs`
  - 成为个人移动知识库

使用TiddlyWiki的优缺点
========================

- 优点

  - 只需要一个文件就能包含所有数据，方便平台间切换，备份和恢复
  - 几乎所见所得，一旦文档完成保存立即可以看到效果，比较直观

- 缺点

  - 对于大量内容的单一文件运行会逐渐缓慢(我印象中是这样的)
  - 默认使用了自己的wiki格式，使用有些复杂

我目前 :strike:`还没有完全确定` 使用tiddlywiki记录个人快速笔记，然后不断修订。由于是自己的个人笔记，以纯文字为主，数据量有限，也就避免了单一文件过大导致TiddlyWiki运行缓慢的潜在风险。

我感觉如果个人数据有限，并且是精心整理记录的私有文档，采用tiddlywiki会比较合适。

大规模的文档，则建议使用 :ref:`sphinx_doc` ；中等规模则建议 :ref:`mkdocs`

快速起步
===========

- 从 `TiddlyWiki官网 <https://tiddlywiki.com/>`_ 下载一个空白文档 ``empty.html`` ，这是一个单文件集成了js来实现交互。使用方法请参考 `TiddlyWiki简易指南 <https://zhuanlan.zhihu.com/p/555893660>`_

- **注意** 需要使用插件或者服务端来解决TiddlyWiki的更新保存:

  - 简单的方法: :ref:`tiddlywiki_on_ruby_webrick`
  - 完整的方法: :ref:`tiddlywiki_on_nodejs`

Markdown支持
==============

TiddlyWiki默认使用了自己独有的wiki语法，我在早期使用时特意学习过，但是时隔多年之后，已经忘记怎么使用了。然而，Markdown作为最流行的撰写文档格式，通用性和易学性要好很多，我也不想再使用其他标记语言，所以考虑在Tiddlywiki中也配置支持Markdown。

TiddlyWik 5在2023年1月23官宣了 `TiddlyWiki: New Markdown Plugin Merged <https://talk.tiddlywiki.org/t/new-markdown-plugin-merged/5894>`_ ，使用新版本markdown插件取代了旧版 ``markdown-legacy`` 。

安装 ``markdown`` 插件
-----------------------

访问 `markdowndemo <https://tiddlywiki.com/prerelease/plugins/tiddlywiki/markdown/>`_ 将其中的 ``markdown`` 插件链接拖放到现有的 TiddlyWiki 页面上，按照提示进行安装即可。

安装以后，创建文档选择Markdown格式即可采用markdown方式撰写，非常简便。

学习资料
=========

互联网上能够找到一些很好地使用学习文档，我这里不再复述，建议参考:

- `TiddlyWiki简易指南 <https://zhuanlan.zhihu.com/p/555893660>`_ 原文详尽，非常建议阅读学习
- `Markdown 官方教程 <https://markdown.com.cn/>`_ 中文版，非常详尽简洁，简单浏览一下就能流畅撰写(安装 ``markdown`` 插件之后)

平台
======

- `墨屉 <https://oflg.github.io/Tidme/zh-Hans>`_ 基于TiddlyWiki开发的 `渐进学习 <https://www.yuque.com/supermemo/wiki/what_is_incremental_learning>`_ 工具，主要用来阅读、学习和笔记(对于学生学习外语有帮助)

参考
=====

- `TiddlyWiki官网 <https://tiddlywiki.com/>`_
