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

创建模型(Model)
====================

在MVC开发中， ``model`` 指使用对应数据的Ruby类，也就是Models通过一个名为Active Record的Rails功能来和应用程序的数据库交互

要定义一个model，需要使用model generator:

.. literalinclude:: rails_quickstart/generate_model
   :caption: 生成model(数据库访问)

``model`` 命名冲突
-------------------

.. warning::

   需要注意， ``model`` 的名字不能和Rails的应用名字相同!!!

我最初不知道这个Rails不允许 ``model`` 名字(数据库连接)和应用名字相同，也是就是我的项目名设置为 ``tweet`` ，然后我尝试创建Model命名也是 ``Tweet`` :

.. literalinclude:: rails_quickstart/generate_model_err_cmd
   :caption: **错误** 使用了和应用项目同名的model命名

此时报错显示 ``Tweet`` 名字是保留字或者已经在应用中使用了。Why?

通过 ``grep -R -i tweet *`` 可以看到在 ``config/application.rb`` 有一个冲突命名 ``module`` :

.. literalinclude:: rails_quickstart/config_application.rb
   :caption: ``config/application.rb`` 内部包含了和应用名相同的 ``module`` 配置
   :emphasize-lines: 9

原因是创建名为 ``tweet`` 的应用程序时，这个关键字 ``tweet`` 就是模块(module)命名保留，后续就不能作为模型(model)使用了。

为了避免这样的冲突，可以修改使用其他模型(model)名，或者采用更好的应用模块(module)命名。例如，在命名应用程序是，如果考虑到 ``tweet`` 会作为model命名(数据库表名)，那么可以采用 ``tweets`` 作为应用名，既表示复数又能够避免冲突。

我重新构建了项目，命名项目名为 ``tweets`` 来重走一遍流程(毕竟刚开始工作量不多)，后续吸取教训，在理解和遵循社区最佳实践基础上，合理命名。

- 在修正了应用名 ``tweets`` 之后，重新执行一次定义model的命令(同上):

.. literalinclude:: rails_quickstart/generate_model
   :caption: 生成model(数据库访问)

此时就能够正常运行，输出信息如下:

.. literalinclude:: rails_quickstart/generate_model_output
   :caption: 生成model(数据库访问)输出信息
   :emphasize-lines: 2,3

上面的输出信息中显示生成了两个文件:

  - ``db/migrate/20240507031631_create_tweets.rb`` 数据库迁移文件
  - ``app/models/tweet.rb`` 模型文件

数据库迁移
-----------

- ``db/migrate/20240507031631_create_tweets.rb`` 是Ruby编写的数据库抽象:

.. literalinclude:: rails_quickstart/migrate_create_tweets.rb
   :language: ruby
   :caption: 迁移数据库的文件

注意到，这里我虽然创建的是 ``Tweet`` model，但是在数据库表中建立的却是 ``tweets`` 表

  - 在这个 ``tweets`` 表中，默认创建了一个自增主键(auto-incrementing primary key) ``id`` ，会自动从 ``id`` 1 开始增加
  - 创建表的部分，定义了 ``title`` 和 ``body`` 两列，类型分别是 ``string`` 和 ``text``
  - 最后一行定义表是 ``t.timestamps`` ，这个方法实际上定义了两个附加列 ``created_at`` 和 ``updated_at``

- 执行数据库迁移指令:

.. literalinclude:: rails_quickstart/db_migrate
   :caption: 数据库迁移

输出信息显示了创建一个 ``tweets`` 表:

.. literalinclude:: rails_quickstart/db_migrate_output
   :caption: 数据库迁移输出显示创建了 ``tweets`` 表
   :emphasize-lines: 2

数据库交互
============

Rails提供了一个非常 **神奇** 的数据库交互方法，也就是控制台提供 ``irb`` 交互能够以对象方式操作数据库。下面是一个在数据库表 ``tweets`` 中插入一行记录并检查的交互过程

- 加载Rails控制台:

.. literalinclude:: rails_quickstart/console
   :caption: Rails控制台

此时提示:

.. literalinclude:: rails_quickstart/console_output
   :caption: Rails控制台提示

- 输入以下命令，初始化一个Rails的 ``tweet`` 对象:

.. literalinclude:: rails_quickstart/tweet.new
   :caption: Rails初始化一个tweet对象

此时会输出生成了对象，但是需要注意这个对象仅仅初始化，还没有真正保存到数据库

.. literalinclude:: rails_quickstart/tweet.new_output
   :caption: Rails初始化一个tweet对象输出信息
   :emphasize-lines: 2

- 输入保存命令:

.. literalinclude:: rails_quickstart/tweet.save
   :caption: Rails保存一个tweet对象

保存成功的信息输出

.. literalinclude:: rails_quickstart/tweet.save_output
   :caption: Rails保存一个tweet对象
   :emphasize-lines: 2

- 查看和打印非常简单，就是直接调用对象:

.. literalinclude:: rails_quickstart/tweet
   :caption: Rails打印一个tweet对象

输出信息如下

.. literalinclude:: rails_quickstart/tweet_output
   :caption: Rails打印一个tweet对象时输出
   :emphasize-lines: 3-7

非常简单的方法，我们就得到了一个插入数据库的记录

- 可以通过以下命令来查找记录，这里举id为1的查询:

.. literalinclude:: rails_quickstart/tweet_find_1
   :caption: 查找id为1的记录

输出如下:

.. literalinclude:: rails_quickstart/tweet_find_1_output
   :caption: 查找id为1的记录输出

- 打印所有记录:

.. literalinclude:: rails_quickstart/tweet_all
   :caption: 查找所有记录

数据库数据List
================

在完成了上文的数据库交互数据添加之后，对于WEB开发来说，如何在页面上展示数据(模拟用户发布tweet之后的页面显示)，成为基础功能。简单的实现也是通过经典的MVC实现:

- 首先修订 ``app/controllers/tweets_controller.rb`` 控制器:

.. literalinclude:: rails_quickstart/tweets_controller_fetch_db.rb
   :language: ruby
   :caption: 修订 ``app/controllers/tweets_controller.rb`` 添加索引index动作以便从数据库提取所有tweet
   :emphasize-lines: 3
 
参考
======

- `Ruby on Rails Guides <https://guides.rubyonrails.org>`_
- `Ruby on Rails Tutorial <https://www.railstutorial.org/>`_
