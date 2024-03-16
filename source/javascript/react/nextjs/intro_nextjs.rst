.. _intro_nextjs:

=================
Next.js 简介
=================

Next.js 是基于 :ref:`react` 的最大的全功能web应用扩展框架，并且集成了一个快速构建的 基于 :ref:`rust` 的 :ref:`javascript` 工具。根据 `Top Software Repos on GitHub <https://ght.creativemaybeno.dev/>`_ 统计，Next.js也是GitHub上排名第14的软件仓库(以Star计算)，可见这个web框架的流行程度。

.. note::

   `阮一峰的网络日志 <https://www.ruanyifeng.com/blog/>`_ 曾经推荐过一篇 `How I Built My Blog <https://www.joshwcomeau.com/blog/how-i-built-my-blog/>`_ 介绍如何采用Next.js构建blog的文章，非常详细和精彩。

Next.js是由 ``Vercel`` 公司推出的基于 :ref:`react` 的web框架，可以实现 ``server-side rendering`` 和 ``static website generation`` :

- 传统的React应用都是客户端浏览器渲染，但是Next.js扩展了功能提供了服务器端渲染，并且建议开发者使用Node.js构建服务器端选软应用
- `Vercel公司 <https://vercel.com/>`_ 提供 :ref:`static_website` 托管

从本质上来说(Under the hood)，Next.js为 :ref:`react` 抽象和自动化配置了工具，例如 bunding, compiling 等。这样开发者可以聚焦在应用程序开发而不是浪费时间来配置它。

主要功能
==========

.. csv-table:: Next.js 主要功能
   :file: intro_nextjs/nextjs_features.csv
   :widths: 20, 80
   :header-rows: 1

参考
======

- `nextjs.org <https://nextjs.org/>`_
- `Wikipedia: Next.js <https://en.wikipedia.org/wiki/Next.js>`_
