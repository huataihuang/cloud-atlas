.. _nextjs_vs_remix:

=====================
Next.js vs Remix
=====================

作为后端运维，当尝试前端开发时，总是被各种前端工具和框架搞得头晕目眩。前端确实是一个非常繁杂且迭代发展迅速的技术领域，不断重复发明轮子(中性词)一方面使得技术发展极快，另一方面也导致混乱和无所适从。

作为 :ref:`javascript` 的组件库， :ref:`react` 已经通过多年发展和竞争淘汰逐渐成为主流 **user interface library** 。但是React不是完整的WEB框架(据说facebook内部使用自己的WEB框架，但不开源)，所以要构建网站，需要通过 :ref:`nextjs` 或 :ref:`remix` 来完成。

.. note::

   根据 `react.dev <https://react.dev/>`_ 官网说明:

   React is a library. It lets you put components together, but it doesn’t prescribe how to do routing and data fetching. To build an entire app with React, we recommend a full-stack React framework like :ref:`nextjs` or :ref:`remix` .

.. warning::

   作为前端小白，我整理本文是为了自己后续学习实践参考，但是受限于知识水平，目前我只能综合调研，还不能提出自己有效的观点。敬请谅解!

- :ref:`nextjs` 提供了全面的、更具伸缩能力的rendering methods(SSG,SSR,ISR); :ref:`remix` 则专注于性能和开发体验，只支持服务器端渲染(server-side rendering, SSR)
- :ref:`nextjs` 使用基于文件的路由，也就是在 ``pages`` 目录通过添加文件来创建新路由(page router)，不过现在2025年最新版本已经提供了 ``app router`` ； :ref:`remix` 使用配置文件来定义路由，并且宣称使用 ``nested router`` 可以实现快速且复杂的加载路由
- :ref:`remix` 比 :ref:`nextjs` 更为简化开发，并且初始化性能比 :ref:`nextjs` 快；但是当项目复杂需要实现高级交互时，remix不如next.js这样开箱即用，需要开发者自己深入挖掘
- 适合Remix的项目:

  - 较为简单
  - 开发快速
  - 在简单中追求性能

- 适合Next.js的项目:

  - 需要实现复杂交互
  - 长期维护项目
  - 可复用的REST API

- :ref:`nextjs` 的(重量级)使用者众多，从reddit投票和GitHub的star来看， :ref:`nextjs` 是大约 :ref:`remix` 的3倍
- :ref:`remix` 似乎紧跟 :ref:`react` 的技术路线，目前已经使用了 ``React Router v7 (RR7)`` 实现路由(也许技术更新但褒贬不一)
- :ref:`nextjs` 倾向于服务商绑定，主要因为开发者是 ``Vercel`` 公司，所以可以快速部署到 Vercel 平台； :ref:`remix` 据说是react团队专门负责router部分的开发人员独立出来搞的，没有明显的平台绑定，但是由于和 :ref:`react` 深度绑定，所以react的技术线路调整会深刻影响remix

我的想法
=========

:ref:`nextjs` vs :ref:`remix` 有点类似 :ref:`django` vs ``flask`` ，也就是 ``大而全`` vs ``小而美`` :

由于在 :ref:`nextra_i18n` 遭遇挫折，我准备系统化学习 :ref:`react` ，暂时不再使用 :ref:`nextjs` 和 :ref:`nextra` 。这样我的 [cloud-atlas.dev](https://cloud-atlas.dev) 文档系统准备采用 :ref:`docusaurus` 实现，也即是更接近于 :ref:`react` 。

在这种，情况下我准备先学习 :ref:`remix` ，实现小型网站开发。后续再根据规模或者工作机会再学习和实现 :ref:`nextjs` 。总之，学好底层的 :ref:`javascript` / :ref:`typescript` / :ref:`react` ，上层WEB框架转换也不是太纠结。

参考
======

- `Remix or Nextjs? Why? <https://www.reddit.com/r/reactjs/comments/115k86h/remix_or_nextjs_why/>`_
