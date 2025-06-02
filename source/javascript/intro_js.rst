.. _intro_js:

================
JavaScript简介
================

JavaScript最初是由Brendan Eich为Netscape Navigator(第一个商业web浏览器)开发的"LiveScript"(我理解是一种动态脚本)。JavaScript虽然和著名的Java语言名字相似，但是JS实际上是一门基于原型(面向编程的一种风格，通过复制已经存在的原型对象的过程实现继承)和头等函数(即函数是头等公民)的多范式高级解释型编程语言。

JavaScript支持:

- 面向对象程序设计
- 指令式编程
- 函数式编程

JavaScript特点:

- 通过方法来操控文本、数组、日期以及正则表达式
- 不支持I/O (网络、存储和图形等)，但可以由它的宿主环境提供支持

JavaScript由Ecma(欧洲计算机制造商协会)通过ECMAScript实现语言的标准化，已经被世界上绝大多数网站所使用，也被世界树瘤浏览器(Chrome, Firefox, Saari 和 Opera)所支持。

对于客户端而言，JavaScript通常被实现为一门解释语言，但是JavaScript现在也可以被即时编译(JIT)。随着HTML5和CSS3语言标准的推行，JavaScript还可以用于游戏、桌面和移动应用程序开发，以及服务器端网络环境运行(如 :ref:`nodejs` )。

学习线路(我的想法)
=====================

我是从后端运维工作开始我的IT职业生涯的，前端对我来说是一个模糊的景象: 各种眼花缭乱的工具和开发框架让人无所适从

不过，我的目标是通过前端技术实现全栈(真正的全栈，从底层基础设施到顶层应用)，我需要通过前端来构建web、应用，来实现表达和完成普通人能够使用的产品。那么我该如何学习JavaScript呢？

我的逐渐形成的学习线路想法:

- 学习 :ref:`html5` 和 :ref:`css` 能够构建基本页面
- 学习 JavaScript 底层技术，并且重点以JS为主，所有的framework最终都是JS构建的组件荟萃，不管技术潮流如恨来去，JS已经是既成的基础
- 适当学习 :ref:`react` 来完成UI组件的布局和组合，毕竟不可能每个WEB组件元素都自己构建，快速的WEB应用开发都依赖react

  - 可能会对比 :ref:`nextra` 使用 ``Docusaurus`` 来同样构建 :ref:`devops_docs` (如果想用更接近 :ref:`react` 的技术堆栈)

- :ref:`nextjs` 相当于 :ref:`react` 的固定(优化)组合，更为容易构建WEB，但是也限制了天马行空的构建。不过，对于需要快速拿到结果，还是需要 :ref:`nextjs` 这种更高层的预制品来完成作品。所以，我会从两个方向学习，一个是底层JavaScript向上，尽可能打好基础；另一个是从 :ref:`nextjs` 向下，以便能够快速完成WEB构建作品，能够将自己的想法变成现实
- 构建 :ref:`devops_docs` 则采用 :ref:`nextra` 以便能够充分学习 :ref:`nextjs` 的技术理念

主要学习的目标还是 :ref:`javascript` ，越是底层生命力越旺盛，框架毕竟会由于开源社区的的风向而转变，基本不变的只有底层。

学习资料
==========

- `Fireship <https://fireship.io>`_ 制作了很多有趣的视频以及快速学习资料，我在看了 `How to Run JavaScript Code <https://fireship.io/courses/javascript/beginner-js-where-to-run/>`_ 小短文以及该系列的几个形象的视频(充满复古风味很合我的口味)，觉得非常推荐给懂一点英语的JS小白(例如我自己)
- ``WebPlatform`` 项目提供了一系列 `Learn the latest in web technologies <https://webplatform.github.io/docs/tutorials/>`_ ，虽然在2015年已经停止更新，但是文档还是写得非常清晰的，可以借鉴
- :ref:`learn_enough` 中包含了 `Learn enough javascript <https://www.learnenough.com/javascript>`_ 可以作为入门学习

favicon
=========

网站页面需要一个默认 ``favicon`` :

- `favicon.cc <https://www.favicon.cc>`_ 提供了在线绘制 ``favicon`` ，能够自己设计和绘制网站图标
- `favicon.io <https://favicon.io>`_ 可以智能根据文本、图片以及emojis来生成 ``favicon`` (后端应该使用了类似现在非常流程的 :ref:`stable_diffusion` AI技术 )
- 参考 `HTML Favicon <https://www.w3schools.com/html/html_favicon.asp>`_ 可以为HTML添加 ``favicon``

参考
=======

- `维基百科: JavaScript <https://zh.wikipedia.org/zh-hans/JavaScript>`_
- `Reddit: Which React framework should I learn? <https://www.reddit.com/r/react/comments/10vklh7/which_react_framework_should_i_learn/>`_
