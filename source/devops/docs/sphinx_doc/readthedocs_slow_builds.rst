.. _readthedocs_slow_builds:

===============================
Read the Docs编译缓慢的解决建议
===============================

``Build exited due to time out``
==================================

最近发现，在 Read the Docs 上build我的 Cloud Atlas总是失败:

.. literalinclude:: readthedocs_slow_builds/build_failed_time_out
   :caption: Read the Docs 上build failed，Error是超时
   :emphasize-lines: 17,18

可以看到失败退出的错误返回码 ``137`` ，也就是类似 :ref:`k8s_exit_code_137` ，表明运行程序被强制杀死了...

解决建议
===========

官方指南 `Read the Docs: How-to guides >> troubleshooting problems / Troubleshooting slow builds <https://docs.readthedocs.io/en/stable/guides/build-using-too-many-resources.html>`_ 有以下改善建议:

- 减少文档构建的格式: 特别是 ``htmlzip`` 会消耗大量的内存和时间
- 减少文档build的依赖: 可以创建一个仅用于文档的自定义需求文件，也就是 ``requirements.txt``
- 使用 ``mamba`` 代替 ``conda`` : 如果需要 ``conda`` 包来构建文档，则建议使用 ``mamba`` 作为 ``conda`` 的替代品，可以节约内存并且运行更快
- 静态记录 Python 模块 API:

安装大量 Python 依赖项只是为了使用 ``sphinx.ext.autodoc`` 记录 Python 模块 API，则可以尝试 ``sphinx-autoapi`` Sphinx 的扩展，它应该产生完全相同的输出，但静态运行。 这可以大大减少构建文档所需的内存和带宽。

- 请求更多资源: 如果还是遇到问题，则发送电子邮件给 ``support@readthedocs.org`` ，提供构建文档所需更多资源的充分理由 (类似 `Command killed due to excessive memory consumption #6627 <https://github.com/readthedocs/readthedocs.org/issues/6627>`_ 在 `GitHub: readthedocs / readthedocs.org <https://github.com/readthedocs/readthedocs.org>`_ 提交issue也能获得管理员帮助提高一定的资源限制)

最终解决
===========

我给 ``support@readthedocs.org`` 发了一封电子邮件请求更多资源，两天以后收到答复，说根据日志没有发现资源不足情况，但是把我的 ``cloud-atlas`` 项目编译时间限制放宽到1小时。我再次做了编译尝试，结果还是失败。

很郁闷...

但是我在回家路上思考这个问题的时候，想到这个编译过程确实在我的服务器上也非常长(如果 :ref:`cpu_frequency_governor` 设置为 ``powersave`` 则长达数小时)。这是非常诡异的事情，因为我记得很久以前，我曾经夸赞过 Sphinx Doc 的编译速度，当时可以在分钟级就完成完整编译。我的印象中是某个时间点开始，突然间编译速度就慢到难以忍受。只不过当时因为自己服务器没有编译限制，所以最终编译完成也就没有深究。

现在这个问题再次摆在面前，而且不得不解决...

既然是某个时间点突然变慢，那么说明很可能是某个模块升级或者配置修改导致的...我仔细回想了一下，突然想到 :ref:`sphinx_chinese_search` 失效很久了。记得刚开始配置 ``jieba`` ，我还欣喜地发现它能够神奇地切分中文，能够完成中文词汇搜索。然而，不知道何时，这个搜索功能就再也不工作了，似乎是什么模块升级导致的。

既然这个中文搜索功能失效很久了，既然编译缓慢也出现很久了，那么这两者会不会有什么关联呢？

果然，我将 :ref:`cpu_frequency_governor` 的以下 ``conf.py`` 配置取消:

.. literalinclude:: sphinx_chinese_search/conf.py
   :language: python
   :caption: 配置Sphinx ``conf.py`` 设置项目为中文

果然，编译速度惊人地快，仅仅三分半钟就完成了编译。再次同步到ReadTheDocs网站，也就能完成编译了。

.. note::

   :ref:`sphinx_chinese_search` 问题待我有空时候再彻底解决一下

参考
=====

- `Read the Docs: How-to guides >> troubleshooting problems / Troubleshooting slow builds <https://docs.readthedocs.io/en/stable/guides/build-using-too-many-resources.html>`_
