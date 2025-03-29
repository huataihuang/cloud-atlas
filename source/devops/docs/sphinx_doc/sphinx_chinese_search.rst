.. _sphinx_chinese_search:

===================
Sphinx中文搜索
===================

- 和 :ref:`mkdocs_chinese_search` 一样，采用 jieba 类库:

.. literalinclude:: ../mkdocs/mkdocs_chinese_search/jieba
   :caption: 安装 ``jieba`` 模块

- 修改 ``conf.py`` 配置，将项目设置为中文，或者html搜索语言设置为中文:

.. literalinclude:: sphinx_chinese_search/conf.py
   :language: python
   :caption: 配置Sphinx ``conf.py`` 设置项目为中文

- 可选配置:

.. literalinclude:: sphinx_chinese_search/conf_jieba_dict.py
   :language: python
   :caption: 可选配置 ``jieba`` 词典路径

排查
======

有一段时间不知道什么变化导致 :ref:`readthedocs_slow_builds` ，我通过关闭中文language来恢复快速编译。当时就发现搜索功能已经失效了，不论在搜索框中输入中文还是英文，回车以后就看到页面上有一个 ``search...`` 没有任何输出。

经过很久很久，我终于发现(2024年底)，应该是某次升级Sphinx之后，很久以前的Sphinx旧版本 ``conf.py`` 配置有很多不兼容的残留配置导致无法正常生成搜索索引文件。解决的方法也很简单，就是用最新的Sphinx重新创建一个空的project，获得干净的 ``conf.py`` 文件，再手工将需要的配置(参考现在的)添加回去，这样再次 ``make html`` 就能正常生成搜索索引文件，最终恢复了搜索功能。

- ``source/conf.py`` 配置修订如下:

.. literalinclude:: ../../../conf.py
   :caption: 重新简化生成新版本正确的 ``conf.py``

参考
=====

- `SPHINX-DOC的中文搜索 <https://www.cnblogs.com/chunyin/p/9610857.html>`_
- `readthedocs-demo-zh <https://readthedocs-demo-zh.readthedocs.io/zh-cn/latest/%E6%96%87%E4%BB%B6%E6%89%98%E7%AE%A1%E7%B3%BB%E7%BB%9F-ReadtheDocs.html>`_ 给出了一个完整构建中英文双语文档的方法，或许今后可以参考
