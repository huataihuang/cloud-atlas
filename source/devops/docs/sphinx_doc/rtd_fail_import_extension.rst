.. _rtd_fail_import_extension:

Read the Docs build失败: ``Could not import extension sphinxcontrib.video``
=============================================================================

最近在引入 :ref:`sphinx_embed_video` 和 :ref:`sphinx_embed_youtube`  到我的 Sphinx 项目，我在 ``source`` 目录下的 ``requirements.txt`` 加入了:

.. literalinclude:: ../../../requirements.txt
   :caption: requirements.txt 加入模块
   :emphasize-lines: 6,7

但是我发现在 Read the Docs 平台，最近的build失败，提示错误如下:

.. literalinclude:: sphinx_embed_video/readthedocs_build_fail_output
   :caption: Read the Docs 平台Build失败输出信息
   :emphasize-lines: 23,26

这里导入 ``sphinxcontrib.video`` 触发了 ``sphinx.util.docutils`` 无法导入 ``SphinxTranslator`` 模块。

Read the Docs 类似问题在之前遇到过 :ref:`sphinx_typeerror` ，主要是需要 `RTD eproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_

需要重新修订配置文件了，之前 :ref:`sphinx_typeerror` 修订过配置，随着时间推移又出现新的问题了。需要配置成和当前本地环境一致，这样可以引导 Read the Docs 按照我本地build方式build

``.readthedocs.yaml`` 配置文件
================================

- 修订项目目录下添加一个配置文件 ``.readthedocs.yaml`` ，这次参考 `Configuration file v2 <https://docs.readthedocs.io/en/stable/config-file/v2.html>`_ 修改:

.. literalinclude:: rtd_fail_import_extension/readthedocs.yaml
   :language: yaml
   
配置Python依赖的 ``requirements`` 文件
=======================================

之前在 ``source`` 目录下 ``requirements.txt`` 文件只指定需要哪些模块，但是不指定版本。为了能够更好完成build，改进成指定版本(和本地版本一致)

- 更新 ``requirements.txt`` :

.. literalinclude:: ../../../python/startup/rebuild_virtualenv/generate_requirements
   :language: bash
   :caption: 生成 :ref:`virtualenv` 所使用Python软件包依赖列表 ``requirements.txt``

现在似乎不再使用 ``environment.yaml`` ，我移除了这个配置文件

参考
========

- `RTD eproducible Builds <https://docs.readthedocs.io/en/stable/guides/reproducible-builds.html>`_
