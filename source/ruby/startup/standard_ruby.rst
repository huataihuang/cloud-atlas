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

.. literalinclude:: standard_ruby/standard_simple.lua
   :caption: 配置 ``~/.config/vim/lua/plugins/standard.lua``

- 重新打开 :ref:`nvim` ，此时 LazyVim 会自动读取新配置并在后台通过 Mason 安装 ``standardrb`` 相关支持，通过 ``:Mason`` 可以查看 ``standardrb`` 是否安装成功

- 编写一个格式混乱的ruby代码:

.. literalinclude:: standard_ruby/demo.rb
   :caption: 格式混乱的demo.rb

保存一次，就会自动修订成:

.. literalinclude:: standard_ruby/demo_fix.rb
   :caption: 自动修订的demo.rb

注意还会一些提示需要手工修改 ``Style/StringConcatenation: Prefer string interpolation to string concatenation.`` 原因是风格更期望采用内嵌表达式( ``#{}`` )而不是通过 ``+`` 连接字符串和变量。这里没有自动修复是因为我在 :ref:`macos_studio` 和 :ref:`debian_tini_image` 中使用了微软和Shopify联合开发的 ``ruby-lsp`` 语言服务器，特点是极快、轻量级，但是目前自带的Code Actions(代码重构动作)比老牌的 ``solargraph`` 克制和保守得多，所以没有包含"字符串拼接转内嵌" 的自动重构。最佳实践应该是:

.. literalinclude:: standard_ruby/string_var.rb
   :caption: 内嵌表达式的字符串风格

另外，现代ruby应该在开头加上注释 ``# frozen_string_literal: true`` 可以在处理大量重复的字符串(例如循环)指向同一个内存地址，极大节省了内存并减轻GC的负担

standard.lua改进过程
----------------------

.. warning::

   我这段折腾最后发现没有什么改进效果，gemini太兜圈子了(幻觉?)，最终放弃，还是回到最简单的配置

我最初采用gemini提供的 standard.lua

.. literalinclude:: standard_ruby/standard.lua
   :caption: 配置 ``~/.config/vim/lua/plugins/standard.lua``

这个配置中有一点小问题，每次编辑ruby文件，会一闪而过 ``/Users/admin/.local/share/nvim/lazy/nvim-lint/lua/lint.lua:278: attempt to index local 'parse…`` ，但是实际上没有进行 ``ruby_lsp`` 索引。gemini解释是因为当 ``nvim-lint`` 尝试合并传入的自定义属性是，因为某些更深层的加载顺序问题，它自己内部的完整对象还没有构造完。 这里通过声明式 ``opts`` 轻微改动依然会触发内部源码的断层。

改进方法: 重构平替方案：彻底把 nvim-lint 里的 standard 拆解出来，作为一个全新的、完全由你一手掌控的独立自定义 Linter。也就是 **不覆写它官方内置的 standard 槽位，而是定义一个全新的 mystandard 名字，这样就绕过了原生插件底层的初始化冲突。**

.. literalinclude:: standard_ruby/mystandard.lua
   :caption: 定义 ``mystandard`` 名字避免 ``standard.lua`` 影响官方内置 ``standard``
   :emphasize-lines: 19

果然，这样修改之后nvim编辑ruby文件就会看到右下角有索引的行为 ``"% completed  (72%) ⠙ Ruby LSP: indexing files ruby_lsp"``

不过，以前检查完成后，右上角有一个一闪而过的 ``Linter command standardrb exited with code: 1`` ，gemini解释是因为把静态检查的名字修改成了完全自定义的 ``mystandard`` ，这对于 ``nvim-lint`` 内部处理中，只有原生的Linter才会自动读取配置 ``ignore_exit_code = true`` 属性，导致忽略了传入的防崩参数

再次改回使用内置的 ``standard`` 利用一个空对象将推出状态安全吞掉

.. literalinclude:: standard_ruby/standard_init_fix.lua
   :caption: 修改 ``standard.lua`` 回内置 ``standard`` 但增加一个空表防止初始化未完成

这次修改以后，虽然右下角显示Ruby 语言服务（LSP）索引是正常进行的，但是在索引之前，可以看到系统似乎停顿了一下，右上角一闪而过显示 ``/Users/admin/.local/share/nvim/lazy/nvim-lint/lua/lint.lua:278: attempt to index local 'parse…``

gemini解释是打开Ruby问见时会触发一次静态检查，此时nvim-lint 的内部原生 standard 工具对象还只是一个“空壳”或者还没被框架完全实例化，它的 parser 属性此时处于 nil 状态。虽然在 opts 函数里通过 ``opts.linters.standard.cmd = "standardrb"`` 进行了局部赋值，但在赋值的瞬间，原厂的 ``parser`` 还没有准备好，随后的检查逻辑直接在底层代码的第 ``278`` 行因为触碰了 ``nil`` 的 ``parser`` 而引发了这一瞬间的弹窗。

解决的方法是延迟替换: 当 Neovim 启动时， ``standard.lua`` 保持绝对纯净，零干扰；只有当 ``ruby-lsp`` 彻底就绪、右下角的 ``indexing files`` 开始滚动、整个 ``nvim-lint`` 已经 ``100%`` 物理实例化完毕之后，才动态地把 ``standard`` 的底层执行命令替换为 ``standardrb`` 。

.. literalinclude:: standard_ruby/standard_trig_fix.lua
   :caption: 修改 ``standard.lua`` 等parser就绪之后再修改standard为standardrb

现在编辑 ruby 文件时候，确实能够正确索引，并且也不再出现 ``/Users/admin/.local/share/nvim/lazy/nvim-lint/lua/lint.lua:278: attempt to index local 'parse…`` ，但是一闪而过改成了 ``Linter not found: standard`` ，虽然看起来没有影响，但是还是有点逼死强迫症。原因是打开Ruby文件的瞬间，LazyVim 极其高效的核心框架会瞬间扫描插件声明。此时 ``ruby = { "standard" }`` 会使得 ``nvim-lint`` 在系统中寻找名为 ``standard`` 的可执行文件。但是由于历史原因，这个执行名字是 ``standardrb`` 。这要等待后面的自动命令(Autocmd)触发订正为 ``standardrb`` 才会解决。

太折腾了，既然无法解决初始化一开始时候找不到standard命令(虽然可以通过后续补丁来修正，但是无法消除开始时候一闪而过的找不到standard的报错)，那不如回退到最简单的方式，为 ``standardrb`` 建立一个软链接:

.. literalinclude:: standard_ruby/ln
   :caption: 建立 ``standardrb`` 软链接

这就从根本上解决了自动找到 ``standard`` 快捷方式指向 ``standardrb`` 

那么我们前面复杂的hack脚本已经不再需要，改回最初最简单的模式:

.. literalinclude:: standard_ruby/standard_simple.lua
   :caption: 采用最简单干净的 ``~/.config/nvim/lua/plugins/standard.lua``

我发现这个简单配置其实就足够了，这里要注意的是 ``nvim-lint`` 使用的是命令行工具，所以要使用实际的安装命令 ``standardrb`` ，否则就会报错 ``Linter not found: standard`` 。现在已经实现了目标，唯一的小遗憾是有不规范的语法时 ``standardrb`` 返回的值是 ``1`` 会导致屏幕上一闪而过 ``Linter command standardrb exited with code: 1`` ，不过不影响使用，我尝试了多次也改变不了，就只能这样了。 

参考
=======

- `GitHub: standardrb/standard <https://github.com/standardrb/standard>`_
