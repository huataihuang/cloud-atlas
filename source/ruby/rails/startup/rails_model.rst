.. _rails_model:

=================
Rails model
=================

创建模型(Model)
====================

在MVC开发中， ``model`` 指使用对应数据的Ruby类，也就是Models通过一个名为Active Record的Rails功能来和应用程序的数据库交互

要定义一个model，需要使用model generator:

.. literalinclude:: rails_model/generate_model
   :caption: 生成model(数据库访问)

``model`` 命名冲突
-------------------

.. warning::

   需要注意， ``model`` 的名字不能和Rails的应用名字相同!!!

我最初不知道这个Rails不允许 ``model`` 名字(数据库连接)和应用名字相同，也是就是我的项目名设置为 ``tweet`` ，然后我尝试创建Model命名也是 ``Tweet`` :

.. literalinclude:: rails_model/generate_model_err_cmd
   :caption: **错误** 使用了和应用项目同名的model命名

此时报错显示 ``Tweet`` 名字是保留字或者已经在应用中使用了。Why?

通过 ``grep -R -i tweet *`` 可以看到在 ``config/application.rb`` 有一个冲突命名 ``module`` :

.. literalinclude:: rails_model/config_application.rb
   :caption: ``config/application.rb`` 内部包含了和应用名相同的 ``module`` 配置
   :emphasize-lines: 9

原因是创建名为 ``tweet`` 的应用程序时，这个关键字 ``tweet`` 就是模块(module)命名保留，后续就不能作为模型(model)使用了。

为了避免这样的冲突，可以修改使用其他模型(model)名，或者采用更好的应用模块(module)命名。例如，在命名应用程序是，如果考虑到 ``tweet`` 会作为model命名(数据库表名)，那么可以采用 ``tweets`` 作为应用名，既表示复数又能够避免冲突。

我重新构建了项目，命名项目名为 ``tweets`` 来重走一遍流程(毕竟刚开始工作量不多)，后续吸取教训，在理解和遵循社区最佳实践基础上，合理命名。

- 在修正了应用名 ``tweets`` 之后，重新执行一次定义model的命令(同上):

.. literalinclude:: rails_model/generate_model
   :caption: 生成model(数据库访问)

此时就能够正常运行，输出信息如下:

.. literalinclude:: rails_model/generate_model_output
   :caption: 生成model(数据库访问)输出信息
   :emphasize-lines: 2,3

上面的输出信息中显示生成了两个文件:

  - ``db/migrate/20240507031631_create_tweets.rb`` 数据库迁移文件
  - ``app/models/tweet.rb`` 模型文件

数据库迁移
-----------

- ``db/migrate/20240507031631_create_tweets.rb`` 是Ruby编写的数据库抽象:

.. literalinclude:: rails_model/migrate_create_tweets.rb
   :language: ruby
   :caption: 迁移数据库的文件

注意到，这里我虽然创建的是 ``Tweet`` model，但是在数据库表中建立的却是 ``tweets`` 表

  - 在这个 ``tweets`` 表中，默认创建了一个自增主键(auto-incrementing primary key) ``id`` ，会自动从 ``id`` 1 开始增加
  - 创建表的部分，定义了 ``title`` 和 ``body`` 两列，类型分别是 ``string`` 和 ``text``
  - 最后一行定义表是 ``t.timestamps`` ，这个方法实际上定义了两个附加列 ``created_at`` 和 ``updated_at``

- 执行数据库迁移指令:

.. literalinclude:: rails_model/db_migrate
   :caption: 数据库迁移

输出信息显示了创建一个 ``tweets`` 表:

.. literalinclude:: rails_model/db_migrate_output
   :caption: 数据库迁移输出显示创建了 ``tweets`` 表
   :emphasize-lines: 2

数据库交互
============

Rails提供了一个非常 **神奇** 的数据库交互方法，也就是控制台提供 ``irb`` 交互能够以对象方式操作数据库。下面是一个在数据库表 ``tweets`` 中插入一行记录并检查的交互过程

- 加载Rails控制台:

.. literalinclude:: rails_model/console
   :caption: Rails控制台

此时提示:

.. literalinclude:: rails_model/console_output
   :caption: Rails控制台提示

- 输入以下命令，初始化一个Rails的 ``tweet`` 对象:

.. literalinclude:: rails_model/tweet.new
   :caption: Rails初始化一个tweet对象

此时会输出生成了对象，但是需要注意这个对象仅仅初始化，还没有真正保存到数据库

.. literalinclude:: rails_model/tweet.new_output
   :caption: Rails初始化一个tweet对象输出信息
   :emphasize-lines: 2

- 输入保存命令:

.. literalinclude:: rails_model/tweet.save
   :caption: Rails保存一个tweet对象

保存成功的信息输出

.. literalinclude:: rails_model/tweet.save_output
   :caption: Rails保存一个tweet对象
   :emphasize-lines: 2

- 查看和打印非常简单，就是直接调用对象:

.. literalinclude:: rails_model/tweet
   :caption: Rails打印一个tweet对象

输出信息如下

.. literalinclude:: rails_model/tweet_output
   :caption: Rails打印一个tweet对象时输出
   :emphasize-lines: 3-7

非常简单的方法，我们就得到了一个插入数据库的记录

- 可以通过以下命令来查找记录，这里举id为1的查询:

.. literalinclude:: rails_model/tweet_find_1
   :caption: 查找id为1的记录

输出如下:

.. literalinclude:: rails_model/tweet_find_1_output
   :caption: 查找id为1的记录输出

- 打印所有记录:

.. literalinclude:: rails_model/tweet_all
   :caption: 查找所有记录

数据库数据List
================

在完成了上文的数据库交互数据添加之后，对于WEB开发来说，如何在页面上展示数据(模拟用户发布tweet之后的页面显示)，成为基础功能。简单的实现也是通过经典的MVC实现:

- 首先修订 ``app/controllers/tweets_controller.rb`` 控制器:

.. literalinclude:: rails_model/tweets_controller_fetch_db.rb
   :language: ruby
   :caption: 修订 ``app/controllers/tweets_controller.rb`` 添加索引index动作以便从数据库提取所有tweet
   :emphasize-lines: 3

- 然后对应修改 ``app/views/tweets/index.html.erb`` 视图模版:

.. literalinclude:: rails_model/index.html.erb
   :caption: ``app/views/tweets/index.html.erb`` 视图
   :language: ruby
   :emphasize-lines: 4,6

这里视图模版中使用了 HTML 和 ``ERB`` 混合:

- ``ERB`` 是将Ruby代码前乳文档的模版系统
- ``<% %>`` 表示 **解析包含的Ruby代码**
- ``<%= %>`` 表示 **解析包含的Ruby代码** ``并且将返回值输出``

通过使用ERB，剋将常规Ruby程序嵌入ERB标记中，实现很多功能。需要注意的是，应该尽量保持ERB的tag内容短小，以方便代码阅读。

.. note::

   数据库演示数据也可以通过 :ref:`sqlite_cli` 手工插入，这里我尝试了 :ref:`sqlite_current_timestamp` 插入案例增加了记录，这样就可以继续列表

上述简单的案例，就可以输出一个动态的列表展示在WEB页面

参考
=======

- `Ruby on Rails Guides <https://guides.rubyonrails.org>`_
