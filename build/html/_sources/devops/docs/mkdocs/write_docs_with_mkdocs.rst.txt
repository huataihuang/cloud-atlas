.. _write_docs_with_mkdocs:

========================
使用MkDocs撰写文档
========================

文档布局
=========

在MkDocs中，文档就是常规的Markdown文件，存放在 ``docs_dir`` 配置对应的目录(默认是 ``docs`` 目录)::

   mkdocs.yml
   docs/
       index.md

如何合理布局
================

其实我也是依样画葫芦，在网上能够找到大量的采用 MkDocs 撰写的文档库，可以直接clone下来参考构建自己的文档。例如，我参考 `Argo CD 官方文档 <https://argoproj.github.io/argo-cd/>`_ 的 `Argo CD 手册案例 <https://github.com/argoproj/argo-cd/blob/master/mkdocs.yml>`_ ，构建文档索引:

.. literalinclude:: write_docs_with_mkdocs/mkdocs.yml
   :language: bash
   :caption: mkdocs.yml

.. note::

   我发现 `Mkdocs 配置和使用 <https://www.xncoding.com/2020/03/01/tool/mkdocs.html>`_ 写得非常清晰，值得学习参考。珠玉在前，我就不再重复了。后续我可能会根据实践再补充本文，不过目前我还是简单使用，主要用于工作文档记录，就暂且这样吧。

参考
======

- `Writing your docs - How to layout and write your Markdown source files. <https://www.mkdocs.org/user-guide/writing-your-docs/>`_
