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

.. warning::

   目前不知道什么变化导致 :ref:`readthedocs_slow_builds` ，我通过关闭中文language来恢复快速编译。不影响阅读，但是搜索功能已经很久不工作了，待有空再解决

.. note::

   `readthedocs-demo-zh <https://readthedocs-demo-zh.readthedocs.io/zh-cn/latest/%E6%96%87%E4%BB%B6%E6%89%98%E7%AE%A1%E7%B3%BB%E7%BB%9F-ReadtheDocs.html>`_ 给出了一个完整构建中英文双语文档的方法，或许今后可以参考

参考
=====

- `SPHINX-DOC的中文搜索 <https://www.cnblogs.com/chunyin/p/9610857.html>`_
