.. _docusaurus_startup:

==========================
Docusaurus快速起步
==========================

`Docusaurus 文档 <https://docusaurus.io/>`_ 是使用最广泛的基于 :ref:`react` 开发的Markdown文档平台。我在 :ref:`docs_as_code` 调研不同平台，并且尝试了 :ref:`nextra` 未果，然后我将目光投向了这个由facebook开源的文档平台。

特点
==========

- Docusaurus是一个易于使用的 **静态站点生成器** (类似于 :ref:`mkdocs` / :ref:`jekyll` / :ref:`sphinx_doc` )
- 可以快速搭建具有客户端导航的 **单页应用** ，这是因为它基于 :ref:`react` 所以不仅能够开箱即用，还提供了定制以用于构建 **各种网站** (个人网站、产品、博客、营销主页等等)

简单来说，Docusaurus就是一个高度定制化的 :ref:`react` 内容平台，如果不介意风格单一，想要快速推出 **基于内容** 的网站，那么参考 `最佳Docusaurus站点 <https://docusaurus.io/zh-CN/showcase?tags=favorite>`_ 可以构建面向用户的生产网站。

快速起步
========

- 在安装了 :ref:`install_nodejs` 之后，就可以快速创建Docusaurus网站，以下是我的案例:

.. literalinclude:: docusaurus_startup/install
   :caption: 创建Docusaurus网站
   :emphasize-lines: 2

.. literalinclude:: docusaurus_startup/install_output
   :caption: 创建Docusaurus网站

- 启动:

.. literalinclude:: docusaurus_startup/start
   :caption: 启动Docusaurus

注意默认仅监听 ``localhost`` ，所以如果需要在所有接口上提供，则参考 `Docusaurus docs: CLI <https://docusaurus.io/docs/cli>`_ 传递参数 ``--host 0.0.0.0`` :

.. literalinclude:: docusaurus_startup/start_0
   :caption: 启动Docusaurus监听所有端口

此时访问端口 ``3000`` 可以看到 Docusaurus 提供了一个默认网站，展示了一个简单的教程

build
==========

- 在完成了内容构建之后，执行 ``build`` 指令可以为最终部署构建输出文件(静态html)。我的实践是在 :ref:`docusaurus_multi_docs` 和 :ref:`docusaurus_i18n` 之后执行这个构建:

.. literalinclude:: docusaurus_startup/build
   :caption: 构建输出

.. note::

   通过 ``ngpm run build`` 可以完整构建整个网站，对于 :ref:`docusaurus_i18n` 也可以提供多语言服务和自如切换，是最终的展示结果

我遇到报错:

.. literalinclude:: docusaurus_startup/build_error
   :caption: build报错
   :emphasize-lines: 20,22,24

我经过对比(grep)发现，原来是 :ref:`docusaurus_i18n` 时，采用了 ``docusaurus write-translations`` 指令来生成 ``i18n`` 目录结构以及对应 ``.json`` 文件。这些 ``.json`` 文件是包含了一些 ``footer.json`` 配置文件，其中定制了一些导航链接指向 ``docs/intro.md`` ，我在生成了 ``i18n`` 目录之后再修订 ``docusaurus.config.js`` 中的 ``docs`` 路由 ``routeBasePath`` 没有及时更新到 ``i18n`` ，这样是导致 ``build`` 报错的原因。另外，涉及到 ``src/pages/index.js`` 包含了 ``docs/intro`` 链接需要修订

如果要忽略错误可以调整 ``docusaurus.config.js`` 设置(但不建议):

.. literalinclude:: docusaurus_startup/docusaurus.config_onBrokenLinks.js
   :caption: 调整 ``docusaurus.config.js`` 设置 ``onBrokenLinks`` 参数
   :emphasize-lines: 2

这样 ``build`` 就能够顺利完成，就会在项目目录下构建一个 ``build`` 目录包含了最终静态文件

serve
========

- 启动服务可以从 ``build`` 目录提供网站服务，由于是静态网站，所以性能会比开发模式下实时渲染快很多，并且可以使用普通 :ref:`nginx` 对外提供服务:

.. literalinclude:: docusaurus_startup/serve
   :caption: 提供服务

参考
=====

- `Docusaurus Introuction <https://docusaurus.io/docs>`_
- `Docusaurus 介绍 <https://docusaurus.io/zh-CN/docs>`_
