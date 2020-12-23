.. _intrudoce_node.js:

=================
Node.js 简介
=================

虽然Node.js从2009年诞生，仅仅走过11年发展历史，但是已经被广泛应用在WEB开发每个角落。就像Linux操作系统无所不在，基于JavaScript解释引擎的Node.js，不需要我再做解释。虽然，和JavaScript一样，Node.js诞生也存在不足，但是随着Node.js广泛使用和迭代发展，已经成为WEB开发的事实运行标准。

- 随着ES2015发展和定稿，涌现了大批利用ES2015特性开发的新模块，例如 `express框架 <http://expressjs.com/>`_ 核心团队开发的 :ref:`koa`

  - 阿里巴巴基于koa开发的开源企业级框架 :ref:`egg`

koa.js, egg.js, express.js, TypeScript
=======================================

Express.js是Node.js开发的传统Web框架，提供了 web 开发所需的路由、模版引擎、MVC、Cookie、Session等功能，支持通过中间件扩展，上手简单，功能强大，是目前最流行的Node.js Web框架。

- Express是ECMAScript 5 向 ECMAScript 6(2015)过渡时期的产物，处理异步比较繁琐
- Express原作者基于 ECMAScript 8 (2017) 标准推出了 Koa 2，用 async + await 语法让中间件代码更加简洁、清爽，形成了经典的洋葱模型。

Koa目标和Express一致，但几个显著变化：

- 中间层使用洋葱模型，让中间件代码根据next方法分隔有两次执行时机
- 几乎不再内置任何中间件，把控制权和复杂度交给开发者

  - 由于web应用离不开sesson，试图模版，路由和文件上传，日志管理，这些在Koa都不提供，需要从官方的Middleware寻找，这带来了非常繁杂的搭配

- Koa 1通过generator、Koa 2通过async/await愈发，让web中高频出现的异步调用编写简洁

egg.js也是生成web的框架:

- 提供了一套约定有线配置的实现，以便架构师可以通过配置轻松定制符合团队约定的web框架
- egg.js底层基于Koa2，中间件机制和koa一致，只不过为了实现通过config文件配置，需要简单包装

  - egg.js实际上就是基于Koa.js，将社区最佳实践整合进了Koa.js，并且将多进程启动，开发时的热更新等问题一并解决了
  - 对开发者友好，开箱即用(就是最佳配置)
  - egg.js不支持现在最热的TypeScript，所以淘宝在egg.js基础上，引入了TypeScript支持，取名为 ``MidwayJS``

Nest.js 是基于Express.js的全功能框架，在Express.js上封装，充分利用了TypeScript的特性。当前社区活跃，进展迅速。不过需要有TypeScript基础才能较好学习。

.. note::

   当前应该学习最新的ECMAScript标准实现，并学习TypeScript，同时可以学习Koa 2框架来实现自己的项目目标。

参考
======

- `Node.js 的发展历程 <https://guide.daocloud.io/dcs/node-js-9153945.html>`_ - 历史简述可做参考
- `Node.js发展史 <http://www.ayqy.net/blog/node-js发展史/>`_ 这是Node.js编年史，非常详尽且有很多互联网文档索引链接，对于Node.js历史详情和发展趋势感兴趣可以阅读
- `koa.js,egg.js,express.js三者有什么区别？ <https://www.zhihu.com/question/391604647>`_
