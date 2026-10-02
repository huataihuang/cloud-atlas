.. _intro_antora:

====================
Antora简介
====================

Antora网站生成器处理所有创建一个文档网站的工作，从拉取、聚合到转换和内容排版，生成最终网站的文件发布。默认的pipeline能够快去起步，但是理解Antora的模块和开放架构意味着能够按需定制Antora。

默认的generator pipeline
==========================

- 构建 Playbook: Playbook 文件是一个简单的配置文件，可以使用 YAML、JSON 或 TOML 格式编写。它包含各种信息和设置，例如要使用哪些内容、如何处理内容、如何生成站点以及将输出发布到何处。
- 加载内容仓库: Antora 根据 Playbook 中列出的内容源，加载指定的 Git 仓库或本地内容文件夹，为扫描其中的内容文件做好准备。Antora 确定要使用指定仓库中的哪些引用（分支、标签和起始路径）。
- 查找内容源根目录: Antora 从内容源根目录开始查找，当发现名为 ``antora.yml`` 的组件版本描述文件时，便会将该目录下的相关文件识别为某个组件版本的一部分。
- 计算附加元数据: Antora 利用 playbook 中的站点属性以及上一步分配给文件的信息，为每个文件添加模块（module）、族（family）、族内相对路径（family-relative path）及其他元数据值。此外，它还计算每个可发布文件的输出路径（磁盘路径）和发布路径（URL）。
- 将文件组织成内容目录: Antora 进一步将汇总的文件整理成一个可查询、可传输的内容目录。
- 将 AsciiDoc 文件转换为可嵌入的 HTML: 利用 Asciidoctor.js，将内容目录中“页面族（page family）”内的 AsciiDoc 文件转换为可嵌入的 HTML。
- 转换导航文件: Antora 从内容目录中获取导航文件，将其内容转换为按特定层级组织（即导航菜单中包含的导航树）的导航项，并生成导航模型。
- 定位并获取 UI 包: Antora 根据 playbook 中列出的 URL 查找并获取 UI 包。
- 将 UI 文件转换为虚拟文件对象: Antora 解压 UI 包中的文件，并为每个文件创建一个包含其内容及路径信息的虚拟文件对象。
- 分类 UI 文件: Antora 利用 UI 描述符文件（ui.yml）识别静态 UI 文件，并将这些文件的类型设定为“静态（static）”。根据文件所在位置（asset、layout、helper 或 partial），确定所有其他文件的类型。
- 计算 UI 文件的输出路径: 针对每个可发布（类型为 static 或 asset）的 UI 文件，Antora 都会计算其输出路径。
- 将 UI 文件组织到 UI 目录中: 将虚拟 UI 文件整理为一个可传输的集合。
- 将转换后的 AsciiDoc 内容嵌入页面模板

.. note::

   从官方文档来看，Antora在后台处理的步骤很复杂，看来得在实践中慢慢理解摸索

参考
======

- `How Antora Works <https://docs.antora.org/antora/latest/how-antora-works/>`_
