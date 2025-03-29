.. _rails_quickstart:

=================
Rails快速起步
=================

.. note::

   实际上大多数语言的起步都很容易，rails也不例外。这里借着hello world来温习一下开发WEB程序的概念，也是大多数WEB框架采用的方式。

Rails哲学
===========

- 不要重复自己: 不要重复编写相同代码(模块化可复用)，而是通过清晰的、可维护的代码来降低重复编码
- 约定高于配置: Rails有 **默认约定的最佳实践** ，而不是通过无尽的配置实现相同优化(我对原文的理解)

:strike:`tweet` ``tweets``
=============================

.. note::

   我的学习目标: clone一个twitter

   模拟学习的项目名字是 :strike:`「tweet」` **「tweets」** (就像很多教学是以blog为案例)，虽然这个名字不能作为正式名，但是自己学习实践应该没有关系...

.. note::

   注意应用命名是 ``tweets`` 而不是 ``tweet`` ，原因见下文(避免和model命名冲突)

- 创建项目:

.. literalinclude:: rails_quickstart/new_tweets
   :caption: 执行 ``rails new`` 创建名为 :strike:`tweet` ``tweets`` 的项目

此时输出信息:

.. literalinclude:: rails_quickstart/new_tweets_output
   :caption: 执行 ``rails new`` 创建名为 :strike:`tweet` ``tweets`` 的项目输出信息
   :emphasize-lines: 1,4

可以观察到rails创建了一个和项目名相同的目录 ``tweet`` ，然后在这个项目下创建了一系列 **最佳实践** 目录，并且使用 ``bundle install`` 安装了一系列gem依赖:

  - 对于初学者这种默认的 **最佳实践** 非常规范地提供了一个 「脚手架」，无需纠结该如何组织程序源代码，社区已经提供了经过大量实践总结的约定结构
  - 在前人的经验基础上，简单定制就能实现一个轻巧的WEB程序，并且随着经验积累不断改进
  - 甚至提供了一个 ``Dockerfile`` (配套了 ``.dockerignore`` 避免不需要的文件被复制到容器内部) ，只需要一条命令就可以将自己开发的程序运行到容器中，大大降低了普通开发者的运维难度

项目目录
---------

**请参考官网**

Hello,Rails!
===============

在 ``bin`` 目录下提供了运行Rails的脚本，所以启动命令非常简单:

.. literalinclude:: rails_quickstart/server
   :caption: 执行rails程序

注意观察输出:

.. literalinclude:: rails_quickstart/server_output
   :caption: 执行rails程序的输出信息
   :emphasize-lines: 4,10

启动了一个 ``Puma`` web服务器(随Rails默认一起分发)，运行在服务器的回环地址 ``127.0.0.1`` 的 ``3000`` 端口上。此时用浏览器访问 http://127.0.0.1:3000 ，就会看到Rails的一个简单初始页面(点击图标实际上会跳到官网页面)，不过当前什么也没有，所以接下来我们需要简单定制开发。

route, controller, view
==========================

经典的Rails开发使用:

- route: 采用Ruby DSL(Domain-Specific Language, 领域特定语言)
- controller: Ruby类，通过Ruby类提供的公开方法 **行动**
- view: 模版，通常是混合HTML和Ruby编写

route
--------

Rails的路由入口是 ``config/routes.rb`` ，这个文件定义了我们的Rails程序起始路由，你可以将它看成WEB服务器的根开始的URL，例如 ``/tweets`` 路由就表示访问我们的WEB服务器的 ``/tweets`` 路径，例如 http://127.0.0.1:3000/tweets 

另一种理解(假设你很熟悉 :ref:`nginx` )，在nginx的概念中，也有一个称为 ``location`` 的定义表示URL访问

- 首先修改 ``config/routes.rb`` 加上我们想要的这行路由(其他部分是之前 ``rails new tweet`` 生成的默认内容

.. literalinclude:: rails_quickstart/config_routes.rb
   :caption: ``config/routes.rb`` 定义了路由配置
   :emphasize-lines: 2

生成对应controller和view
~~~~~~~~~~~~~~~~~~~~~~~~~~

Rails采用了一种约定俗成的命名方式来对应 ``route <=> controller <=> view`` 执行以下命令自动生成对应框架:

.. literalinclude:: rails_quickstart/generate_controller
   :caption: rails生成controller ，这里命名为 ``Tweets`` 控制器

- 路由是URL的一部分，我们用小写字符串 ``tweets`` 来命名route
- 根据路由 ``tweets`` 命名，Rails会自动约定使用 ``tweets_controller`` 作为 Controller

  - 类 ``TweetsController`` 在 ``app/controller/tweets_controller.rb`` 中定义

- 根据路由 ``tweets`` 命令，Rails生成约定的视图 ``app/views/tweets/index.html.erb``

controller
--------------

- 修订生成的控制器 ``app/controllers/tweets_controller.rb``

.. literalinclude:: rails_quickstart/tweets_controller.rb
   :language: ruby
   :emphasize-lines: 1

可以看到类 ``TweetsController`` 是从 ``ApplicationController`` 引入，当前没有做什么定制

.. note::

   ``tweets_controller`` 的 ``index`` 活动是空白的: 当没有明确定制action来渲染视图view时，Rails就会自动渲染匹配控制器名字的视图，这里也就是 ``app/views/tweets/index.html.rb`` 作为默认视图

view
-------

- 视图文件已经生成 ``app/views/tweets/index.html.erb`` ，简单修订一下内容如下:

.. literalinclude:: rails_quickstart/index.html.rb
   :language: ruby
   :emphasize-lines: 1

修订第一行来反应我们的页面 ``tweets``

现在访问 http://127.0.0.1:3000/tweets 就能看到完整的 ``route => controller => view`` 展示内容，可以看到定制视图的显示内容 **Hello, Tweets!**

设置应用Home页面
==================

``config/routes.rb`` 配置了路由，所以想要默认显示自己开发的某个路由，需要添加 ``root`` 指令，也就是修改 ``config/routes.rb`` :

.. literalinclude:: rails_quickstart/config_routes_root.rb
   :caption: ``config/routes.rb`` 配置默认路由
   :emphasize-lines: 2

下一步
========

现在初步完成了一个Rails的 ``Hello World`` 案例，但是页面是写死的，没有体现出Rails灵活而强大的开发能力。所以，下一步需要学习和实践 :ref:`rails_model` ，通过数据库交互来实现动态WEB页面，真正实现WEB开发。
 
参考
======

- `Ruby on Rails Guides <https://guides.rubyonrails.org>`_
- `Ruby on Rails Tutorial <https://www.railstutorial.org/>`_
