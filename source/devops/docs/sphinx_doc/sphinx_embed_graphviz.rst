.. _sphinx_embed_graphviz:

=================================
Sphinx文档嵌入Graphviz图形可视化
=================================

Graphviz 是一款开源图形可视化软件。图形可视化是一种将结构信息表示为抽象图形和网络图表的方式。它在网络、生物信息学、软件工程、数据库和网页设计、机器学习以及其他技术领域的可视化界面中有着重要的应用。

.. note::

   目前我还很少使用Graphviz，不过在以往工作中曾经使用过作为绘制工作流。本文仅做简单整理记录，以便后续能够参考完成一些文档撰写的图示参考。

准备工作
=========

- 对于需要渲染文档的主机，需要先安装 `Graphviz官网 <https://www.graphviz.org/>`_ 提供的GraphViz工具集。对于 :ref:`macos` 平台可以使用 :ref:`homebrew` 安装:

.. literalinclude:: sphinx_embed_graphviz/brew_install_graphviz
   :caption: :ref:`macos` 平台 使用 :ref:`homebrew` 安装 Graphviz

Sphinx配置
===========

- 修订 Sphinx 文档的 ``conf.py`` 配置:

.. literalinclude:: sphinx_embed_graphviz/conf.py
   :caption: 激活 Graphviz 扩展
   :emphasize-lines: 2,10

- 撰写文档嵌入Graphviz的案例代码:

.. literalinclude:: sphinx_embed_graphviz/graphviz
   :caption: 嵌入 Graphviz 的代码案例

- 显示效果

  - nodes具有一个 ``href`` 属性， ``SVG`` 渲染后包含 **可点击的超链接**

.. graphviz::
    :name: sphinx.ext.graphviz
    :caption: Sphinx and GraphViz Data Flow
    :alt: How Sphinx and GraphViz Render the Final Document
    :align: center

     digraph "sphinx-ext-graphviz" {
         size="6,4";
         rankdir="LR";
         graph [fontname="Verdana", fontsize="12"];
         node [fontname="Verdana", fontsize="12"];
         edge [fontname="Sans", fontsize="9"];

         sphinx [label="Sphinx", shape="component",
                   href="https://www.sphinx-doc.org/",
                   target="_blank"];
         dot [label="GraphViz", shape="component",
              href="https://www.graphviz.org/",
              target="_blank"];
         docs [label="Docs (.rst)", shape="folder",
               fillcolor=green, style=filled];
         svg_file [label="SVG Image", shape="note", fontcolor=white,
                 fillcolor="#3333ff", style=filled];
         html_files [label="HTML Files", shape="folder",
              fillcolor=yellow, style=filled];

         docs -> sphinx [label=" parse "];
         sphinx -> dot [label=" call ", style=dashed, arrowhead=none];
         dot -> svg_file [label=" draw "];
         sphinx -> html_files [label=" render "];
         svg_file -> html_files [style=dashed];
     }

参考
======

- `Graphviz官网 <https://www.graphviz.org/>`_
- `Embedding Graphs Into Your Sphinx Documents <https://jhermann.github.io/blog/python/documentation/2020/03/25/sphinx_ext_graphviz.html>`_
