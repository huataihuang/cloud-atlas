.. _rails_crud:

===============================
Rails 数据库CRUD (resources)
===============================

:ref:`rails_crud_r` 显示了如何读取数据库，本文将实践另外3个修改操作 ``C`` (Create), ``U`` (Update), ``D`` (Delete)。

正如之前的 :ref:`rails_crud_r` ， ``C U D`` 也是通过添加新的路由，控制器活动和视图来实现的。也就是说，结合了路由，控制器活动和视图，我们能够在一个入口执行CRUD操作，也就是通常所说的资源。

Rails提供了一个路由方法，命名为 ``resources`` 可以将所有的常规路由映射为一个 ``资源集合`` ，例如 ``tweets`` ，案例如下:

- 作为资源，需要修订之前的 ``config/routes.rb`` ，删除掉之前的2个 ``get`` 路由，取代为 ``resources`` :

待续...

参考
=======

- `Ruby on Rails Guides <https://guides.rubyonrails.org>`_
