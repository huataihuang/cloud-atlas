.. _nextra_startup:

=========================
Nextra快速起步
=========================

Nextra是基于 :ref:`nextjs` 的框架，用于构建内容密集型的网站，Nextra具备了 :ref:`nextjs` 所有功能，并提供了易于使用的Markdown撰写功能。

Nextra提供了两种不同的用途theme:

- `Nextra Docs Theme <https://nextra.site/docs/docs-theme/start>`_

  - 顶部有一个导航栏
  - 一个搜索框
  - 一个页面侧边栏
  - 一个内容列表(TOC)
  - 一系列内建组件

- `Nextra Blog Theme <https://nextra.site/docs/blog-theme/start>`_

.. note::

   我的目标是构建自己的 `docs.cloud-atlas.dev <https://docs.cloud-atlas.dev>`_ 不同的技术手册，所以会以 ``Docs Theme`` 为起点构建

安装
========

- 在创建 Nextra Docs站点之前，需要首先安装 :ref:`nextjs` , :ref:`react` , Nextra 和 Nextra Docs Theme:

.. literalinclude:: nextra_startup/install
   :caption: 安装Nextra

安装输出信息:

.. literalinclude:: nextra_startup/install_output
   :caption: 安装Nextra输出信息
   :emphasize-lines: 10

可以根据上述提示升级 ``npm`` 版本(可选): ``npm install -g npm@11.4.1``

完成安装之后，在项目目录下会有 ``package.json`` 生成，该文件用于指导安装对应依赖以及启动运行脚本:

.. literalinclude:: nextra_startup/package.json
   :caption: ``package.json``

起步
======

- 运行:

.. literalinclude:: nextra_startup/run_dev
   :caption: 运行 ``dev`` 模式

这里有报错，显示还没有 ``pages`` 和 ``app`` 目录:

.. literalinclude:: nextra_startup/run_dev_pages_err
   :caption: 缺少 ``pages`` 和 ``app`` 目录的报错

这个问题看起来是缺少基本内容目录导致无法运行，不过，不用急，继续按照 `Nextra Docs Theme <https://nextra.site/docs/docs-theme/start>`_ 指南进行配置和初始化

- 在项目根目录下创建 ``next.config.mjs`` ，这个配置文件可以让Nextra处理 :ref:`nextjs` 项目中Markdown文件

.. literalinclude:: nextra_startup/next.config.mjs
   :caption: 项目根目录下创建 ``next.config.mjs``

- 添加 ``mdx-components`` 文件:

- 设置搜索

- 创建根目录的布局:

现在需要在 ``app`` 目录下创建一个根布局，也就是创建 ``app/layout.jsx`` 文件:

.. literalinclude:: nextra_startup/layout.jsx
   :caption: 创建 ``app/layout.jsx``

- 渲染 ``MDX`` 文件: 也就是使用 ``基于文件的路由`` (file-based routing)来渲染MDX文件，有两种方式:

  - 通过 ``page`` 文件
  - 通过 ``content`` 目录

按照 `nextra Documentataion: File Conventions > content <https://nextra.site/docs/file-conventions/content-directory>`_ 介绍，现在的文件转换是采用 ``content`` 目录，只需要简单将 ``pages`` 目录重命名为 ``content`` 就可以

我尝试将 `GitHub: shuding/nextra-docs-template <https://github.com/shuding/nextra-docs-template?tab=readme-ov-file>`_ 项目中初始页面复制过来修改:

.. literalinclude:: nextra_startup/cp_template
   :caption: 复制 ``nextra-docs-template``

当然，如果更为简单，就只需要 ``content/index.mdx`` 一个文件，简单案例内容可以如下:

.. literalinclude:: nextra_startup/index_sample.mdx
   :caption: 一个最简单的 ``index.mdx``

- 添加 ``[[...mdxPath]]/page.jsx`` 文件:

.. literalinclude:: nextra_startup/page.jsx
   :caption: 添加 ``[[...mdxPath]]/page.jsx``
   :emphasize-lines: 2

这里我修改了第2行，因为我发现项目根目录是 ``../../`` ，在这个根目录下有一个 ``mdx-components.js``

另外，我还修改了 ``components/counter.tsx`` 添加了一行 ``use client'`` ，原因是::

   TypeError: useState only works in Client Components. Add the "use client" directive at the top of the file to use it. Read more: https://nextjs.org/docs/messages/react-client-hook-in-server-component

导航栏
========

`nextra Documentataion: Built-In Components > Navbar <https://nextra.site/docs/docs-theme/built-ins/navbar>`_ 介绍了如何在导航栏设置内容，其中有一些是默认链接，例如 ``projectLink`` / ``chatLink`` 。

还可以将一些菜单和定制链接添加到导航栏，需要参考 `Page Configuration >> navbar-items <https://nextra.site/docs/docs-theme/page-configuration#navbar-items>`_ 



参考
=======

- `nextra introduction <https://nextra.site/docs>`_
- `Build a documentation site with Next.js using Nextra <https://dev.to/mayorstacks/build-a-documentation-site-with-nextjs-2b3p>`_
