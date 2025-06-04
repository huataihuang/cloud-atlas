.. _nextra_startup:

=========================
Nextra快速起步
=========================

体验
======

.. warning::

   目前我暂时放弃了Nextra，因为我感觉文档和实际代码有脱节和冲突，让我非常困扰。

我用了两天时间来学习使用Nextra，可能因为我缺乏前端开发经验，对于 ``npm/pnpm`` 不熟悉，在尝试 :ref:`nextra_i18n` 时遇到不少挫折，导致我目前暂时放弃:

- 似乎得从 `GitHub: nextra <https://github.com/shuding/nextra>`_ 完整clone出项目，并使用 ``pnpm`` 来管理和启动，这样可以少走弯路
- 我是最初从 `nextra introduction <https://nextra.site/docs>`_ 文档开始，文档实际上和 `GitHub: nextra <https://github.com/shuding/nextra>`_ 是脱节的，导致我踩了坑折腾了很久
- 因为我的后端维护经验影响，我会去折腾从最基础的部署开始，例如我尝试手册指导的安装方法，但是由于手册没有提供模版指导，我就摸索从模版复制内容过来运行。但是JavaScript或者说 :ref:`react` 生态其实很复杂(叠床架屋)，手册又写得简略(开源文档似乎都习惯以开发者而不是使用者角度撰写)，导致我调衡了一天才完成初步运行
- 在 :ref:`nextra_i18n` 又踩了坑，原来nextjs的i18n是一种动态路径路由，但是我之前找到的文档 `Build a documentation site with Next.js using Nextra <https://dev.to/mayorstacks/build-a-documentation-site-with-nextjs-2b3p>`_ 使用的模版实际上是几年前尚未实现i18n。不得已推倒重来，在 `GitHub: nextra <https://github.com/shuding/nextra>`_ 的 ``examples`` 中找出官方 ``i18n`` 模版 ``awr-site`` 来部署
- 又遇到 ``npm/pnpm`` 包管理器的迷宫了，参考文档的步骤看来是有一定执行条件的，必须按照 `GitHub: nextra <https://github.com/shuding/nextra>`_ 完整clone出项目来搞，我这种缝合胶水的方式困难重重，直接把我劝退了( :ref:`nodejs` 的包管理世界真是非常蛋疼，各种依赖冲突必须按照完美的排列完成，稍有改动可能就轰然倒塌)

不太顺利，我整理 :ref:`nextjs_vs_remix` ，准备先退回到 :ref:`react` 学习，等后续再有机会重新开始(nextjs依然是最主流的WEB框架，可能不得不学习使用)

简介
======

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

在上述安装步骤完成后，在项目目录下有如下文件:

.. literalinclude:: nextra_startup/after_intall_files
   :caption: 安装完成后的文件
   :emphasize-lines: 2,3

完成安装之后，在项目目录下会有 ``package.json`` 生成，该文件用于指导安装对应依赖以及启动运行脚本:

.. literalinclude:: nextra_startup/package.json
   :caption: ``package.json``

起步
======

- 运行:

.. literalinclude:: nextra_startup/run_dev
   :caption: 运行 ``dev`` 模式

模版(归档)
------------

.. note::

   这一段所使用的模版不支持 :ref:`nextra_i18n` ，我因为需要撰写多语言文档，所以我改为下一段记录的 ``模版`` 步骤

这里有报错，显示还没有 ``pages`` 和 ``app`` 目录:

.. literalinclude:: nextra_startup/run_dev_pages_err
   :caption: 缺少 ``pages`` 和 ``app`` 目录的报错

这个问题看起来是缺少基本内容目录导致无法运行，不过，不用急，继续按照 `Nextra Docs Theme <https://nextra.site/docs/docs-theme/start>`_ 指南进行配置和初始化

- 在项目根目录下创建 ``next.config.mjs`` ，这个配置文件可以让Nextra处理 :ref:`nextjs` 项目中Markdown文件

.. literalinclude:: nextra_startup/next.config.mjs
   :caption: 项目根目录下创建 ``next.config.mjs``

- 添加 ``mdx-components`` 文件:

- 设置搜索

- 创建根目录的布局:的

现在需要在 ``app`` 目录下创建一个根布局，也就是创建 ``app/layout.jsx`` 文件:

.. literalinclude:: nextra_startup/layout.jsx
   :caption: 创建 ``app/layout.jsx``

- 渲染 ``MDX`` 文件: 也就是使用 ``基于文件的路由`` (file-based routing)来渲染MDX文件，有两种方式:

  - 通过 ``page`` 文中件
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

模版
--------

.. note::

   现在我使用这段记录的步骤，使用nextra官方发布的 ``examples/swr-site`` 模版，以支持多国语言文档撰写

- 将 `nextra/examples/swr-site/ <https://github.com/shuding/nextra/tree/main/examples/swr-site>`_ 内容同步到这个目录下(忽略已经存在的文件不覆盖):

.. literalinclude:: nextra_startup/rsync_template
   :caption: 同步模版

- 安装(使用pnpm)

.. literalinclude:: nextra_startup/pnpm_install
   :caption: 使用 ``pnpm`` 安装

报错:

.. literalinclude:: nextra_startup/pnpm_install_error
   :caption: 使用 ``pnpm`` 安装报错

原来 `pnpm > introduction > Installation <https://pnpm.io/installation>`_ 在Workstpace中必须有一个 ``pnpm-workspace.yaml`` 来配置工作区

我参考 `next.js learn: Getting Started <https://nextjs.org/learn/dashboard-app/getting-started>`_ 的方法来构建目录

.. literalinclude:: nextra_startup/install_template
   :caption: 参考模版进行安装

导航栏
========

`nextra Documentataion: Built-In Components > Navbar <https://nextra.site/docs/docs-theme/built-ins/navbar>`_ 介绍了如何在导航栏设置内容，其中有一些是默认链接，例如 ``projectLink`` / ``chatLink`` 。

还可以将一些菜单和定制链接添加到导航栏，需要参考 `Page Configuration >> navbar-items <https://nextra.site/docs/docs-theme/page-configuration#navbar-items>`_ 

favicon.ico
================

参考 `next.js favicon,icon, and apple-icon <https://nextjs.org/docs/app/api-reference/file-conventions/metadata/app-icons>`_

在Next.js中为应用设置icon的图片类型可以是 ``.ico`` / ``.jpg`` / ``.png`` ，文件存储在 ``/app`` 目录中。需要注意其中

- ``favicon`` 图片必须位于 ``app/`` 顶层目录，且只支持 ``.ico`` 文件类型
- 应用 ``icon`` 则可以是多种类型 ``.ico, .jpg, .jpeg, .png, .svg``
- ``apple-icon`` 则支持 ``.jpg, .jpeg, .png``
- 除了 ``favicon`` 必须位于 ``app/`` 外，另外两种图片类型可以位于 ``app/**/*``

参考
=======

- `nextra introduction <https://nextra.site/docs>`_
- `Build a documentation site with Next.js using Nextra <https://dev.to/mayorstacks/build-a-documentation-site-with-nextjs-2b3p>`_
