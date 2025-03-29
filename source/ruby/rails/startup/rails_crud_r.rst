.. _rails_crud_r:

========================
Rails 数据库CRUD 之 R
========================

虽然业内常常说业务开发如果没有精研技术就不过是 ``CRUD boy`` ，但是CRUD(Create, Read, Update, Delete)却是大多数WEB应用的基础，Rails提供了很多功能来简化CRUD代码，方便完成开发。

在 :ref:`rails_model` 中实现的是数据库查询和index记录的列表，对于我们的简单开发，实际上需要以一种合理的方式展示title和body，也就是能够类似于文档浏览方式来展示发布的 tweets

本段落为读取R的案例演示

显示tweet内容
================

- 修订 :ref:`rails_quickstart` 中曾经创建过索引动作的 ``config/routes.rb`` 路由，增加一个路由来映射新的控制器动作:

.. literalinclude:: rails_crud_r/config_routes.rb
   :language: ruby
   :caption: 增加一个新的路由映射控制器动作
   :emphasize-lines: 4

新增的 ``get`` 路由有一个特殊的扩展路径 ``:id`` ，这是一个路由参数:

所谓的路由参数就是将值填入 ``params`` Hash，控制器动作会相应捕获这个 ``:id`` 值作为参数。

举例，访问 http://localhost:3000/tweets/1 ，这里的 ``1`` 就是从 ``:id`` 获得的值，也就是访问 ``TweetsController`` 的 ``show`` 动作的 参数 ``params[:id]``

.. note::

   官方原文我没有精确翻译，大致只是按照我理解来撰写；不过，根据实例演示走一遍，大致就能理解

   先 **依样画葫芦** ，慢慢积累经验也就熟悉了

- 下一步就是定制控制器，也就是 ``app/controllers/tweets_controller.rb`` （前面在 :ref:`rails_model` 中定义过 ``index`` 动作，这里再增加一个 ``show`` 动作):

.. literalinclude:: rails_crud_r/tweets_controller_show.rb
   :language: ruby
   :emphasize-lines: 6-8
   :caption: 定义show动作控制器，这样可以通过参数 ``:id`` 获取数据库记录行

.. warning::

   这里 ``show`` 动作的返回对象是 ``@tweet`` ，不是 ``@tweets`` ，错误命名会导致访问视图时渲染错误

这里 ``show`` 动作调用了 ``Tweets.find`` 传递了路由参数 ``ID`` ，返回的tweet就存储到 ``@tweet`` 实例变量(你可以理解成根据 ``id`` 从数据库查询出记录对象)，这样的对象结果就能够被下面的 ``视图`` 访问

- 根据Rails约定，默认 ``show`` 动作会渲染 ``app/views/tweets/show.html.erb`` ，则该文件内容如下:

.. literalinclude:: rails_crud_r/show.html.erb
   :language: ruby
   :caption: 对应 ``show`` 动作的视图模版 ``app/views/tweets/show.html.erb``

现在访问 http://localhost:3000/tweet/1 就能看到展示出第一条tweet内容::

   Hello Rails

   I am on Rails!   

改进索引页面
=============

前面在 :ref:`rails_model` 中构架的的 ``app/views/tweets/index.html.erb`` 没有构建内容索引超链接，所以这里改进一下页面

.. literalinclude:: rails_crud_r/index.html.erb
   :caption: 改进 ``app/vies/tweets/index.html.erb`` 增加索引超链接
   :language: ruby
   :emphasize-lines: 6,7

这样访问 http://127.0.0.1:3000/tweets 就能看到tweets的索引形式的超链接，点击超链接就可以查看详细内容

参考
=======

- `Ruby on Rails Guides <https://guides.rubyonrails.org>`_
