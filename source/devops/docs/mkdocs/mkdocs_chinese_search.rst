.. _mkdocs_chinese_search:

====================
MkDocs中文搜索
====================

在使用MkDocs时候就会发现，默认只能搜索英文，中文内容是搜索不到的。虽然早期网上很多文章都说，只要在 ``mkdocs.yml`` 配置中启用 ``日语`` 搜索支持就能很好支持中文搜索，但是实际上依然几乎无效。

不过，2022年5月， `Material Design theme for MkDocs <https://github.com/squidfunk/mkdocs-material>`_ 在 sponsor 仓库 `Insiders <https://squidfunk.github.io/mkdocs-material//insiders/>`_ 提供了内置支持中文搜索。不过，这个私有fork of Material for MkDocs需要加入Sponsorships(每月10美元)才能获取。

.. note::

   `Chinese search support – 中文搜索支持 <https://squidfunk.github.io/mkdocs-material//blog/2022/chinese-search-support/>`_ 文章提供了解决方法: 使用 `jieba "结巴"中文分词 <https://pypi.org/project/jieba/>`_ 模块，可以较好进行中文分词及搜索。

这个 ``Insiders`` 版本可以非常轻松配置中文搜索支持，安装参考见 `Chinese language support <https://squidfunk.github.io/mkdocs-material//setup/setting-up-site-search/#chinese-language-support>`_

如果你没有这笔经费，则可以参考 `4行代码为Mkdocs实现简单中文搜索 <https://zhuanlan.zhihu.com/p/411854801>`_ - 原帖见 `mkdocs search plugin supports zh_CN #2509 <https://github.com/mkdocs/mkdocs/issues/2509>`_

配置MkDocs中文搜索
=========================

- 安装 `jieba "结巴"中文分词 <https://pypi.org/project/jieba/>`_ 模块::

   pip install jieba

- 在 ``mkdocs.yml`` 中配置 ``separator`` ::

   plugins:
       - search:
           lang:
               - en
               - ja
           separator: '[\s\-\.]+'

- 修订 ``lib/python3.10/site-packages/mkdocs/contrib/search/search_index.py`` :

.. literalinclude:: mkdocs_chinese_search/search_index.py
   :language: python
   :caption: 修订search_index.py

- 然后重新生成site

此时可以使用中文进行搜索，不过有限制:

- 每个单词只能2个中文字，超过两个字的词不能匹配，但是可以将多于2个字的词拆成以2个字为一个词的方式，多个词用空格连接进行搜索。例如， ``阿里云`` 拆分成 ``阿里 云`` ，这样就能够搜索到同时具备这2个词的段落，也能搜索到只具备 ``阿里`` 或 ``云`` 的段落。并且搜索结果会注明是同时满足还是 ``missing`` 了某个关键字
- 以段落为搜索匹配范围
- 搜索可以通过空格来连接多个中文词汇，会同时展示 ``and`` 和 ``or`` 结果: 举例，搜索 ``阿里`` 和 ``容灾`` 

.. figure:: ../../../_static/devops/docs/mkdocs/mkdocs_chinese_search.png
   :scale: 70

参考
=====

- `Chinese search support – 中文搜索支持 <https://squidfunk.github.io/mkdocs-material//blog/2022/chinese-search-support/>`_
- `4行代码为Mkdocs实现简单中文搜索 <https://zhuanlan.zhihu.com/p/411854801>`_ - 原帖见 `mkdocs search plugin supports zh_CN #2509 <https://github.com/mkdocs/mkdocs/issues/2509>`_
