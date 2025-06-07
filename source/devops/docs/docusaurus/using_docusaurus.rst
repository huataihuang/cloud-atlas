.. _using_docusaurus:

====================
使用Docusaurus
====================

Docusaurus初次启动运行非常简单，并且默认内置了一个简易教程，可以参考其步骤快速开始使用，而且贴心地提供了 ``i18n`` 支持设置，正好符合我的需求。

创建页面
===========

Page就是一个独立页面，类似 ``about.md`` 页面

Docusaurus提供了两种独立页面(standalone page)创建方法，一种是 ``Markdown`` 文件，一种是 ``React`` 文件，保存在 ``src/pages`` ，目录能够自动映射为访问URL。需要注意，文件映射以后没有后缀:

- ``src/pages/index.js`` → ``localhost:3000/``
- ``src/pages/foo.md`` → ``localhost:3000/foo``
- ``src/pages/foo/bar.js`` → ``localhost:3000/foo/bar``

React页面
-------------

- 创建一个 ``src/pages/my-react-page.js`` :

.. literalinclude:: using_docusaurus/my-react-page.js
   :caption: 创建React页面案例

则访问就是 http://localhost:3000/my-react-page

- 创建 ``src/pages/my-markdown-page.md`` :

.. literalinclude:: using_docusaurus/my-markdown-page_md
   :language: markdown
   :caption: 创建Markdown页面案例

则访问就是 http://localhost:3000/my-markdown-page

创建文档
============

所谓文档(Document)就是一组 ``pages`` 并且有以下特征:

- 具备一个 ``sidebar``
- 具备 ``previous/next`` 导航
- 有版本控制

默认的文档位于 ``docs/`` 目录下，在Docusaurus的安装中，已经构建了一个包含简单教程的

- 创建的文档默认会自动出现在 ``sidebar`` 上，并且可以通过文档标题部分设置 ``sidebar`` 的位置以及标签
- 通过修改 ``sidebars.js`` 还可以手工设置 ``sidebar``

以下是一个非常简单清晰的案例:

- 创建 ``docs/hello.md``

.. literalinclude:: using_docusaurus/hello_md
   :language: markdown
   :caption: 简单docs案例
    

参考
======

- :ref:`docusaurus_startup` 运行后自带的简易教程
