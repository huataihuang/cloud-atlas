.. _standard_ruby:

============================
Standard Ruby(规范工具)
============================

我们知道Ruby创始人松本行弘(Matz, まつもとゆきひろ)设计Ruby的核心理念是: "让程序员快乐" 。他认为语言应该顺应人的思维，而不是让人去屈服于机器的规则。因此，Matz 特意让 Ruby 具备了极大的灵活性，甚至故意遵循 “条条大路通罗马”（TIMTOWTDI - There's more than one way to do it） 的原则。在 Ruby 中，为了让代码读起来像散文一样通顺，同一个逻辑真的可以用完全不同的语法来写。

这种极少的约束，赋予了开发者极大的自由度。

然而， **极致的自由在团队协作和大型工程中往往会带来灾难** 。如果没有任何约束，同一个项目里可能会出现五花八门的写法，导致代码可读性变差。

于是，在长达二十多年的社区实践中，Ruby 社区经历了一个“始于自由，成于约定”的自发演进过程：

- **大浪淘沙** ：无数天才开发者在写了大量开源库（如 Rails、Sinatra、Sidekiq）后，逐渐摸索出哪些写法能让代码最清晰、最不易出错且性能最好。
- **形成共识** : 这些写法被总结为“社区最佳实践”（Best Practices）或“惯用写法”（Idiomatic Ruby）

``工具化固化`` :

- 最早大家把这些约定写成著名的 `Ruby Style Guide <https://github.com/rubocop/ruby-style-guide>`_
- 随后，社区开发了 ``RuboCop`` 静态代码分析工具，把这些文字指南变成了可以自动扫描代码的“警报器”
- 现在 `GitHub: standardrb/standard <https://github.com/standardrb/standard>`_ 采用了另一个极端: 把社区最公认、最现代、最简洁的那一套最佳实践彻底“锁死”，不允许任何人修改规则，用代码强行统一风格。

.. note::

   这是一种工程化的ruby规范工具，对于开发大型软件以及团队协作至关重要

   **Ruby 在底层把自由交给了你，但社区在工程层面上用“约定”和类似 standardrb 的工具把你引向了最高效、最优雅的道路。**

   这是一种非常奇妙的平衡：它既保留了你独自写脚本时的灵动与快乐，又保障了你在团队开发大项目时的严谨与工程规范。

standardrb结合nvim
====================

.. note::

   我在 :ref:`debian_tini_image` 也补充了这段 ``standard`` 集成配置

- 编辑器调用 ``standard`` 之前，系统需要先安装 ``standard`` 可执行程序:

.. literalinclude:: standard_ruby/install
   :caption: 全局安装 ``standard``

如果是项目中使用(例如Rails项目)，则修订 ``Gemfile`` 的 ``development`` 组添加 ``gem 'standard'`` ，然后执行 ``bundle install``

- 针对 :ref:`lazy.nvim` 不需要手工下载插件，只需要 **要给现有的格式化和语法检查插件增加对 standard 的支持** : 在 ``~/.config/vim/lua/plugins/`` 目录下创建 ``standard.lua`` 配置

.. literalinclude:: standard_ruby/standard.lua
   :caption: 配置 ``~/.config/vim/lua/plugins/standard.lua``

- 重新打开 :ref:`nvim` ，此时 LazyVim 会自动读取新配置并在后台通过 Mason 安装 ``standardrb`` 相关支持，通过 ``:Mason`` 可以查看 ``standardrb`` 是否安装成功

- 编写一个格式混乱的ruby代码:

.. literalinclude:: standard_ruby/demo.rb
   :caption: 格式混乱的demo.rb

保存一次，就会自动修订成:

.. literalinclude:: standard_ruby/demo_fix.rb
   :caption: 自动修订的demo.rb

注意还会一些提示需要手工修改 ``Style/StringConcatenation: Prefer string interpolation to string concatenation.`` 原因是风格更期望采用内嵌表达式( ``#{}`` )而不是通过 ``+`` 连接字符串和变量。这里没有自动修复是因为我在 :ref:`macos_studio` 和 :ref:`debian_tini_image` 中使用了微软和Shopify联合开发的 ``ruby-lsp`` 语言服务器，特点是极快、轻量级，但是目前自带的Code Actions(代码重构动作)比老牌的 ``solargraph`` 克制和保守得多，所以没有包含"字符串拼接转内嵌" 的自动重构。 

参考
=======

- `GitHub: standardrb/standard <https://github.com/standardrb/standard>`_
