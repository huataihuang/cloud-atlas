.. _nextra_i18n:

=================
Nextra i18n
=================

.. warning::

   ``Next.js I18n`` 仅支持 ``nextra-theme-docs`` (奇怪，blog模式不支持？)

Nextra默认就支持 `Next.js Internationalized Routing <https://nextjs.org/docs/advanced-features/i18n-routing>`_ ，所以只需要就配置可以支持国际化。

- 修改 ``next.config.mjs`` :

.. literalinclude:: nextra_i18n/next.config.mjs
   :caption: ``next.config.mjs`` 配置 ``i18n``
   :emphasize-lines: 11-14

- 配置文档theme: 在 ``theme.config.jsx`` 中添加 ``i18n`` 选项以配置语言下拉列表:

.. literalinclude:: nextra_i18n/theme.config.jsx
   :caption: 配置语言下拉列表 ``theme.config.jsx``

我这里遇到一个报错问题，显示 ``TypeError`` :

.. literalinclude:: nextra_i18n/typeerror
   :caption: ``TypeError``

- 参考 `next.js App Router > Guides > Internationalization <https://nextjs.org/docs/app/guides/internationalization>`_ 国际化是 ``Routing`` 是通过子目录( 例如 ``/fr/products`` )或 域名( ``my-site.fr/products`` )来实现。所以，该指南指出要确保所有位于 ``app/`` 目录下特定文件要 ``nested`` 进入 ``app/[lang]`` ，这样Next.js就能够动态处理的不同locales的路由

我参考了 `nextra/examples/swr-site/ <https://github.com/shuding/nextra/tree/main/examples/swr-site>`_ 案例，尝试将 ``app/`` 目录下的 ``layout.jsx`` 和 ``[[...mdxPath]]`` 目录移动到 ``[lang]`` 自目录下，但是报错依旧 **如上**

原来在 `next.js App Router > Guides > Internationalization <https://nextjs.org/docs/app/guides/internationalization>`_ 提到针对 ``app/[lang]`` 是转发给每个 ``layout`` 和 ``page`` 的 ``lang`` 参数，例如 ``app/[lang]/page.tsx`` :

.. literalinclude:: nextra_i18n/pages.tsx
   :caption: ``app/[lang]/page.tsx``

我对比了 `nextra/examples/swr-site/ <https://github.com/shuding/nextra/tree/main/examples/swr-site>`_ 确实和原先从 `GitHub: shuding/nextra-docs-template <https://github.com/shuding/nextra-docs-template?tab=readme-ov-file>`_ 复制过来的模版不同，提供了关于 ``lang`` 参数的路由:

.. literalinclude:: nextra_i18n/layout.tsx
   :caption: 包含 ``lang`` 参数的 ``layout.tsx``
   :emphasize-lines: 9

我的解决方法
============

我重做了 :ref:`nextra_startup` 的模版复制步骤，也就是

参考
======

- `nextra Documentatiaon: Next.js I18n <https://nextra.site/docs/guide/i18n>`_
- `[Nextra 4] i18n + static website #3934 <https://github.com/shuding/nextra/issues/3934>`_  使用 `nextra/examples/swr-site/ <https://github.com/shuding/nextra/tree/main/examples/swr-site>`_ 案例来完成i18n
