.. _docusaurus_i18n:

=======================
Docusaurus国际化(i18n)
=======================

- 修改 ``docusaurus.config.js`` 加入 ``zh-CN`` locale(这里以我要支持的中文为例)

.. literalinclude:: docusaurus_i18n/docusaurus.config.js
   :caption: 配置 ``docusaurus.config.js`` locale

.. note::

   文件复制到 ``i18n/zh-CN`` 对应目录目录进行翻译，每个locale和plugin有自己的 ``i18n`` 子目录，其目录格式是:

   .. literalinclude:: docusaurus_i18n/i18n_dir
      :caption: 每个locale和plugin有自己的 ``i18n`` 子目录 

   对于 :ref:`docusaurus_multi_docs` 使用了插件 ``plugin-content-docs`` ，以及 ``plugin-content-blog`` (BLOG)，那么需要具备如下目录结构:
   
   .. literalinclude:: docusaurus_i18n/i18n_dir_structure
      :caption: ``i18n`` 目录结构

.. note::

   这里的 ``i18n/zh-CN`` 以及目录下的 ``.json`` 文件可以通过 `docusaurus write-translations [siteDir] <https://docusaurus.io/docs/cli#docusaurus-write-translations-sitedir>`_

- 创建 ``i18n/en`` 和 ``i18n/zh-CN`` 目录结构以及对应 ``.json`` 文件

.. literalinclude:: docusaurus_i18n/write-translations
   :caption: ``i18n/en`` 和 ``i18n/zh-CN`` 目录结构以及对应 ``.json`` 文件

此时显示信息(以 ``zh-CN`` 为例:

.. literalinclude:: docusaurus_i18n/write-translations_output
   :caption: ``i18n/zh-CN`` 目录结构以及对应 ``.json`` 文件

这里实际完成后的目录结构(因为 :ref:`docusaurus_multi_docs` )，注意 ``docusaurus-plugin-content-docs`` 下有一个 ``current`` 子目录

.. literalinclude:: docusaurus_i18n/i18n_dir_structure_multi_docs
   :caption: :ref:`docusaurus_multi_docs` 环境的 ``i18n`` 目录
   :emphasize-lines: 8

.. note::

   这里使用了参数 ``--locale zh-CN`` 则会创建和输出 ``zh-CN`` 对应locale目录结构和json文件，如果没有参数则会生成 ``en`` 对应的locale目录结构。

   实践发现，需要同时为所有语言创建好目录结构(并且对应复制好文件进行后续翻译修改)，否则切换语言会显示文件找不到

- 启动(开发环境每次只能启动一个locale):

.. literalinclude:: docusaurus_i18n/start_zh-CN
   :caption: 启动 ``zh-CN`` locale 服务测试

- 添加locale下拉菜单: 为了能够在不同语言间切换，修订 ``docusaurus.config.js`` :

.. literalinclude:: docusaurus_i18n/docusaurus.config_localedropdown.js
   :caption: 修订 ``docusaurus.config.js`` 添加语言切换下拉菜单
   :emphasize-lines: 5-8

.. note::

   ``i18n`` 实际上是采用  **优先覆盖** 模式，也就是:

   - 如果 ``i18n/zh-CN/docusaurus-plugin-content-docs/current`` 目录下有对应翻译文件 ``intro.md`` ，就会显示覆盖默认的 ``intro.md``
   - 但是如果没有翻译文件，则会继续显示 ``docs`` 目录的对应默认文件

注意项
============

- 在开发环境中，每次只能测试一种 ``locale`` ，也就是如果运行了 ``--locale zh-CN`` ，则全程只能测试该locale的页面点击，当使用  ``locale下拉菜单`` 点击 ``English`` ，会出现 ``找不到页面`` 报错。这是正常的，当需要测试 ``English`` locale，需要在运行启动时去除 ``--locale zh-CN`` 以默认 ``en`` 运行
- 我最初在配置 ``docusaurus.config.js`` 只设置了 ``routeBasePath`` 为 ``arch`` ，但是依然保留了默认的 ``path`` (也就是 ``docs`` )，现在我统一为 ``architecture`` (架构)，同时设置 ``path`` 和 ``routeBasePath``

.. note::

   我的实践配置见 `multi docs, i18n (commit) <https://github.com/huataihuang/docs.cloud-atlas.dev/commit/fcef3a38cfcef78b9c621e30bca1d795460f1c88>`_ (包含 :ref:`docusaurus_multi_docs` )

参考
======

- `Docusaurus Guides > Internationalization <https://docusaurus.io/docs/i18n/introduction>`_
