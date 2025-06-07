.. _docusaurus_multi_docs:

=========================
Docusaurus多文档
=========================

我希望实现一个多文档的文档网站:

- 有不同的方面的文档，每个文档相当于一个手册，在一个实例中能够同时服务多个手册，类似于 `Red Hat Documentation <https://docs.redhat.com/>`_
- 我希望构建 `docs.cloud-atlas.dev <https://docs.cloud-atlas.dev>`_ 网站的不同手册，例如:

  - `Cloud Atlas: Arch <https://docs.cloud-atlas.dev/arch>`_
  - `Cloud Atlas: Discovery <https://docs.cloud-atlas.dev/discovery>`_
  - 不同分册

Docusaurus通过 `plugin-content-docs插件 <https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-content-docs>`_ 实现了这个功能

::

   npx create-docusaurus@docusaurus/preset-classic docs.cloud-atlas.dev preset-classic

安装插件
=========

- (如果使用了 ``preset-classic`` 模版，也即是我在 :ref:`docusaurus_startup` 中执行安装模版 ``classic`` 内置模版和网站内容，则已经包含了 ``@docusaurus/plugin-content-docs`` 插件，这样就不需要执行这个插件安装步骤)执行以下命令安装 `plugin-content-docs插件 <https://docusaurus.io/docs/api/plugins/@docusaurus/plugin-content-docs>`_

.. literalinclude:: docusaurus_multi_docs/install
   :caption: 安装 ``plugin-content-docs插件`` 

参考 `Docusaurus Getting Started > Installation <https://docusaurus.io/docs/installation>`_ :

The classic template contains @docusaurus/preset-classic which includes standard documentation, a blog, custom pages, and a CSS framework (with dark mode support).

也就是说，其实在 :ref:`docusaurus_startup` 安装 ``classic`` 已经包含了 ``preset-classic``

配置
=======

- 首先为各个手册创建目录，除了默认的 ``docs`` 目录，还可以创建 ``docs-api`` , ``docs-system`` 之类

- 修改 ``docusaurus.config.js`` 文件，配置 ``default`` 文档

.. literalinclude:: docusaurus_multi_docs/docusaurus.config.js
   :caption: 修订 ``docusaurus.config.js`` 添加多文档配置(启用 ``plugin-content-docs`` 插件)
   :emphasize-lines: 4,5,9,10,14-25,33,35-40

.. note::

   我的实践案例见 `Docs Multi-instance修订 <https://github.com/huataihuang/docs.cloud-atlas.dev/commit/f1105b8e406f82cbdddd01b2091eeb1cfc0188d7>`_

- 然后创建一个 ``discovery`` 存放对应于 ``discovery`` 路由和标签的文件，这个代表第2本手册目录

说明
------

- 默认的第一个文档目录就是 ``docs`` ，这个似乎不能修改(或者说修改无效)，但是可以修订 ``navbar`` 标签以及路由(相当于url路径)

.. note::

   我的实践配置见 `multi docs, i18n (commit) <https://github.com/huataihuang/docs.cloud-atlas.dev/commit/fcef3a38cfcef78b9c621e30bca1d795460f1c88>`_ (包含 :ref:`docusaurus_i18n` )

参考
=====

- `Is there a way to have two docs in Docusaurus 2? <https://stackoverflow.com/questions/60783595/is-there-a-way-to-have-two-docs-in-docusaurus-2>`_
- `Multi-instance plugins and plugin IDs <https://docusaurus.io/docs/using-plugins#multi-instance-plugins-and-plugin-ids>`_
- `Docs Multi-instance <https://docusaurus.io/docs/docs-multi-instance>`_
