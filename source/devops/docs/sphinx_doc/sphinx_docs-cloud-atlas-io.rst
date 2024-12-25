.. _sphinx_docs-cloud-atlas-io:

=================================
docs.cloud-atlas.io 文档的sphinx
=================================

(放弃):strike:`2024年3月` ，我启动新的文档撰写项目 `cloud-atlas-io/docs <https://github.com/cloud-atlas-io/docs>`_ 作为个人数据中心项目的文档。这个文档项目将继续采用 Sphinx docs ，同时我将实践:

2024年底，我重新开始 docs.cloud-atlas.io 项目，构建多语言、多版本Sphinx，我准备参考一些好的practice来完成，所以需要做一些测试

- :ref:`sphinx_openstackdocstheme`
- `My Sphinx Best Practice Guide for Multi-version Documentation in Different Languages <https://www.codingwiththomas.com/blog/my-sphinx-best-practice-for-a-multiversion-documentation-in-different-languages>`_ 支持多种语言和版本，经验分享
- `How to manage translations for Sphinx projects <https://docs.readthedocs.io/en/stable/guides/manage-translations-sphinx.html>`_ 自动的多语言翻译(使用 `Transifex <https://www.transifex.com/>`_ 引擎实现)

初始化
===========

- 安装Sphinx工作环境(这里借用了RTD的themes安装命令，对于使用其他theme，可以忽略 ``sphinx_rtd_theme`` 安装命令行:

.. literalinclude:: ../write_doc/install_sphinx_doc
   :language: bash
   :caption: 通过virtualenv的Python环境安装sphinx doc(请忽略 ``sphinx_rtd_theme`` )

- 安装 ``openstackdocstheme`` 风格:

.. literalinclude:: sphinx_openstackdocstheme/install
   :caption: 安装 ``openstackdocstheme`` 风格

- 初始化项目:

.. literalinclude:: sphinx_docs-cloud-atlas-io/sphinx-quickstart
   :caption: 初始化sphinx文档

.. note::

   我的文档项目初始化设置采用了 ``source`` 和 ``build`` 分离的设置

- 修改 ``conf.py`` 配置，启用  ``openstackdocs``

.. literalinclude:: sphinx_openstackdocstheme/conf.py
   :caption: 修订 ``conf.py`` 启用 ``openstackdocstheme``
   :language: python

- build初始文档

.. literalinclude:: ../write_doc/make
   :caption: 执行build出html和epub
