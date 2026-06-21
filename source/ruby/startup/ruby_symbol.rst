.. _ruby_symbol:

===================
Ruby Symbol(符号)
===================

Ruby的Symbol(符号)是一种非常有代表性的语法，可以理解为"贴了标签的、不可变的字符串": 在 Ruby 中，String 是可变的（Mutable），而 Symbol 是不可变的（Immutable）

.. literalinclude:: ruby_symbol/puts
   :caption: 通过打印变量可以看到symbol对象的内存位置始终不变(object_id完全一致)
   :emphasize-lines: 2,5,8,11,14,17

也就是说不论写多少次 ``:hello``  在整个ruby进程的生命周期内，永远指向内存的同一块地方(object_id完全一致)

Ruby在比较两个Symbol时，不需要像字符串一样逐个字母对比，只需要对比内存地址(object_id)，这种速度极其恐怖

Ruby中的Hash
================

早期的Ruby使用了传统的火箭符 ``=>`` 来构建哈希

.. literalinclude:: ruby_symbol/hash.rb
   :caption: 传统hash

在引用是使用如下方法：

.. literalinclude:: ruby_symbol/use_hash.rb
   :caption: 引用hash

这里有一个问题，就是每次引用的时候，ruby都会创建一个内存对象，使用完毕再销毁，带来巨大的GC压力

修改成使用Symbol作为key字符串，那么后续引用hash值时候使用 ``:cello`` 方式，不管多少次，都使用内存同一个地方(object_id完全一致)

.. literalinclude:: ruby_symbol/hash_symbol.rb
   :caption: 采用Symbol作为hash的key

注意，在使用Symbol时，引用Symbol的key，必须在字符串前使用 ``:``

.. literalinclude:: ruby_symbol/use_hash_symbol.rb
   :caption: 使用 采用Symbol作为hash的key

另外，在Ruby 1.9之后引入了火箭符( ``=>`` )的缩写语法糖，将 ``:`` 移动到key字符串后面，就可以代替 ``=>`` 并同时使用Symbol作为key

.. literalinclude:: ruby_symbol/hash_symbol_sugar.rb
   :caption: 更为简洁的symbol语法糖

不过引用的时候依然要在字符串前使用 ``:``

.. literalinclude:: ruby_symbol/use_hash_symbol.rb
   :caption: 使用 采用Symbol作为hash的key

使用规则
============

口诀“数据用字符串，身份/内部标识用符号” :

- 使用 Symbol 的场景（作为“身份标签”）

  - Hash 的 Key：表示固定的属性名
  - 方法传参（关键字参数）：比如 Rails 里的 link_to "主页",  ``root_path`` , ``method: :post``
  - 状态机的值：比如订单状态 ``status = :pending`` 或 ``status = :completed``

- 使用 String 的场景（作为“动态数据”）

  - 需要展示给最终用户的文本（如 "用户名不能为空"）
  - 外部输入进来的数据（比如从数据库读出的用户名字、从前端表单提交过来的密码文本）
  - 需要进行拼接、裁剪、大变小等加工处理的文本（因为 Symbol 根本没有 .gsub、.split 这样的字符串修改方法）

参考
======

- 《Programming Ruby 3.3》
- gemini
