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



参考
=====

- `SPHINX-DOC的中文搜索 <https://www.cnblogs.com/chunyin/p/9610857.html>`_
