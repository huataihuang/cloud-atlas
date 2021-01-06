.. _intrudoce_nodejs:

=================
Node.js 简介
=================

Node.js是JavaScript的运行平台，其显著特征是：

- 异步机制
- 事件驱动机制
- 小巧精悍的标准库

Node当前有两个活跃版本：

- 长期支持版(LTS)
- 当前版(current)

虽然Node.js从2009年诞生，仅仅走过11年发展历史，但是已经被广泛应用在WEB开发每个角落。

虽然，和JavaScript一样，Node.js诞生也存在不足，但是随着Node.js广泛使用和迭代发展，已经成为WEB开发的事实运行标准。

Node所使用的Google V8引擎是基于ECMAScript 2015开发的: ECMAScript 2015是ECMAScript标准的第6个版本，也称为ES6，一般简写为ES2015。

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

Node Web应用解析
=================

Node和JavaScript的优势之一是它们的单线程编程模型：指令序列一次执行一条，代码不是并行执行的，这种机制规避了线程编程中经常出现的问题，如资源死锁和竞态条件。


- 事件：当浏览器触发一个事件时(例如点击按钮)就会有一个之前定义的函数运行
- 非阻塞I/O：程序在请求慢速资源(如磁盘或网络)时不会等待可以继续执行其他任务，当资源就绪(完成操作)则会运行一个回调函数来处理操作结果
- 异步API(事件轮询, event loop)

Node和V8
==========

Node的动力源自V8 JavaScript引擎，最初由Google Chrome的Chromium项目组开发。V8的特性是会被JavaScript直接编译为机器吗，此外还有一些代码优化特性，所以Node的性能卓越。

Node使用本地组件 ``libuv`` 来处理I/O，V8负责JavaScript代码的解释和执行。使用C++绑定层将libuv和V8结合起来。

.. figure:: ../_static/nodejs/nodejs_stack.png
   :scale: 70

Node根据V8的ES2015特性分为以下三个特性组:

- shipping: 默认开启，稳定特性
- staged: Node运行命令行参数 ``--harmony`` 启用，V8团队将所有接近完成的特性放在这组中
- in progress: 稳定性较差，需要具体的特性参数来开启，通过 ``node --v8-options | grep "in gress"`` 可以获得可用的in progress特性

Node版本
==========

- 长期支持版(LTS): 18个月支持服务，之后有12个月维护性支持服务
- 当前版(current)
- 每日构建版(nightly)

当Node主版本号变化，则意味着有些API可能不兼容，则项目需要重新测试。


参考
======

- `Node.js 的发展历程 <https://guide.daocloud.io/dcs/node-js-9153945.html>`_ - 历史简述可做参考
- `Node.js发展史 <http://www.ayqy.net/blog/node-js发展史/>`_ 这是Node.js编年史，非常详尽且有很多互联网文档索引链接，对于Node.js历史详情和发展趋势感兴趣可以阅读
- `koa.js,egg.js,express.js三者有什么区别？ <https://www.zhihu.com/question/391604647>`_
- 「Node.js实战(第2版)」
