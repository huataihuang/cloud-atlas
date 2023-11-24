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

可以看到失败退出的错误返回码 ``137`` ，也就是类似 :ref:`k8s_exit_code_137` ，表明运行程序 ``OOM`` 了

解决建议
===========

官方指南 `Read the Docs: How-to guides >> troubleshooting problems / Troubleshooting slow builds <https://docs.readthedocs.io/en/stable/guides/build-using-too-many-resources.html>`_ 有以下改善建议:

- 减少文档构建的格式: 特别是 ``htmlzip`` 会消耗大量的内存和时间
- 减少文档build的依赖: 可以创建一个仅用于文档的自定义需求文件，也就是 ``requirements.txt``
- 使用 ``mamba`` 代替 ``conda`` : 如果需要 ``conda`` 包来构建文档，则建议使用 ``mamba`` 作为 ``conda`` 的替代品，可以节约内存并且运行更快
- 静态记录 Python 模块 API:

安装大量 Python 依赖项只是为了使用 ``sphinx.ext.autodoc`` 记录 Python 模块 API，则可以尝试 ``sphinx-autoapi`` Sphinx 的扩展，它应该产生完全相同的输出，但静态运行。 这可以大大减少构建文档所需的内存和带宽。

- 请求更多资源: 如果还是遇到问题，则发送电子邮件给 ``support@readthedocs.org`` ，提供构建文档所需更多资源的充分理由 (类似 `Command killed due to excessive memory consumption #6627 <https://github.com/readthedocs/readthedocs.org/issues/6627>`_ 在 `GitHub: readthedocs / readthedocs.org <https://github.com/readthedocs/readthedocs.org>`_ 提交issue也能获得管理员帮助提高一定的资源限制)

参考
=====

- `Read the Docs: How-to guides >> troubleshooting problems / Troubleshooting slow builds <https://docs.readthedocs.io/en/stable/guides/build-using-too-many-resources.html>`_
