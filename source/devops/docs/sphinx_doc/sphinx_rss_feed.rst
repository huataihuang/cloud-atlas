.. _sphinx_rss_feed:

=====================
Sphinx生成RSS feed
=====================

问题
=======

这是一个网友在GitHub上提的issue:  `如何订阅？ #21 <https://github.com/huataihuang/cloud-atlas/issues/21>`_

这是一个很好的问题:

- 一直以来我都是将 「Cloud Atlas」 作为个人 ``电子书+博客`` 来撰写的，先搭框架文档框架，然后不断更新丰富内容
- 采用变通的方式来实现Blog的部分功能:

  - 在 `Cloud Atlas GitHub项目 <https://github.com/huataihuang/cloud-atlas/>`_ 推送更新时，Read the Docs平台会自动构建  `readthedocs平台上的云图 <https://cloud-atlas.readthedocs.io/zh_CN/latest/index.html>`_ ，相当于Blog发布
  - 在页脚上增加 `留言和讨论 <https://github.com/huataihuang/cloud-atlas/issues>`_ 引导用户到 `Cloud Atlas GitHub项目 <https://github.com/huataihuang/cloud-atlas/>`_ 的issue页面进行讨论
  - GitHub提供了 ``Watch`` (仓库)和 ``Fellow`` (人)功能，理论上来说文档仓库变化， ``Watch`` 和 ``Fellow`` 就会收到通知(得通过邮件)

不过，和天然的Blog WordPress相比，有很多不足:

- 讨论和原文是割裂的: 读者无法直接在关心的文章下面直接评论，很可能就失去了讨论的兴趣(看不到别人的激发灵感的问题)
  
  - **这个问题我后面想办法解决** : 想办法在Sphinx下构建一个类似disqus的交互

- 对于中国大陆读者，被防火墙屏蔽的GitHub是很多网友心中的痛，虽然有梯子，但是对很多人来说是一个麻烦
- (本文问题)没有提供Blog常用的RSS Feed功能，这是很多因特网老用户(如果从Blog时代走过)心心念念的功能

对于我个人来说，我也每天使用 `Feedly <https://feedly.com/>`_ (已被墙)订阅一些重要的博客来获得互联网资讯。是的，从Google Reader年代过来的人都无比怀念那个没有墙的岁月...

那么网友的这个问题不就是我们依然坚持纯净的互联网资讯的需求么? 虽然现在互联网新用户都不知道RSS了...

可行的方案
===========

Google了一下，我觉得思路是采用 Sphinx 的插件来实现 RSS feed 生成，有一些实现插件:

- `lsaffre/sphinxfeed <https://github.com/lsaffre/sphinxfeed>`_ ( 从已停止开发的 `junkafarian/sphinxfeed <https://github.com/junkafarian/sphinxfeed>`_ Fork出来) 目前仍在活跃维护，是比较有希望的解决方案
- `sphinxcontrib-newsfeed <https://pypi.org/project/sphinxcontrib-newsfeed/>`_  从2013年开始支持Python 3，虽然2015年之后不再更新，但是由于Sphinx的API非常稳定，所以依然可以使用

``sphinxcontrib-newsfeed``
==============================

- 在 :ref:`virtualenv` 中通过 ``pip`` 安装::

   pip install sphinxcontrib-newsfeed

- 修改 ``conf.py`` ::

   extensions.append('sphinxcontrib.newsfeed')

我的实际配置::

   extensions = [
           'sphinx.ext.graphviz',
           'sphinxnotes.strike',
           'sphinxcontrib.newsfeed'
   ]

参考
=======

- `Feed generation #2 <https://github.com/sphinx-doc/sphinx/issues/2>`_
