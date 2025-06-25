.. _docusaurus_code_snippets:

==============================
Docusaurus 代码片段
==============================

:ref:`docusaurus_code_blocks` 提供了在Markdown文档中嵌入代码的基本能力，但是有时候我需要在多个文档中引用相同的代码片段，类似 :ref:`sphinx_show_code` 提供的 ``代码包含`` ( ``literalinclude::`` ) 指令。

引用本地文件
================

google gemini提到了使用 ``raw-loader`` 可以实现直接加载代码文件

- 先安装 ``raw-loader`` :

.. literalinclude:: docusaurus_code_snippets/install_raw-loader
   :caption: 安装 ``raw-loader``

- 编写 ``.mdx`` 文档，这里我编写了一个 ``proxy.mdx`` ，引用了一个 ``../_code/os/proxy/environment`` 文件:

.. literalinclude:: docusaurus_code_snippets/raw-loader
   :caption: 使用 ``raw-loader`` 加载本地文件

**amazing** 果然可以实现加载代码片段，这样就可以在不同的 ``mdx`` 文档中引用相同的代码片段

.. note::

   不过， ``markdown`` 格式实在太简陋了，完全没有做到 :ref:`sphinx_doc` 的各种引用功能，需要通过 ``MDX`` 扩展来使用react的功能，对撰写文档非常不友好。

应用GitHub公开仓库代码
=======================

参考
======

- `MDX and React <https://docusaurus.io/docs/markdown-features/react>`_
- `How to import a markdown file as plain text #7053 <https://github.com/facebook/docusaurus/discussions/7053>`_
- `Is it possible to import code (not just entire files with the raw loader) and display in a doc block? #9710 <https://github.com/facebook/docusaurus/discussions/9710>`_
- `Docusaurus Theme GitHub Codeblock <https://github.com/saucelabs/docusaurus-theme-github-codeblock>`_
