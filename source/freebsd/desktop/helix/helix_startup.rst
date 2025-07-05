.. _helix_startup:

====================
Helix快速起步
====================

`helix-editor <https://github.com/helix-editor/helix>`_ 是使用 :ref:`rust` 编写的编辑器，并且借鉴了 Kakoune 和 :ref:`nvim` 的设计进行开发(主要是Kakoune的设计理念)。

为社么使用helix
==================

对我来说，我一直使用 :ref:`vim` 来完成 :ref:`linux` / :ref:`freebsd` 上编辑和软件开发工作，但是vim作为上古神器，需要大量的"无谓"投入来实现一个基本的 :ref:`nvim_ide` ，而且配置方法繁杂多变，完全偏离了我"只是为了提高编程效率"的初始目标。

另外，虽然 :ref:`nvim_ide` 配置已经很简化了，但是一方面要依赖社区不断开发和修复配置方法，另一方面这种特定vim配置工具(方法)对Linux依赖极深，当我迁移到 :ref:`freebsd` 开发就遇到了无法完成基本的LSP配置(Mason不支持FreeBSD上clangd配置)。实在没有精力在折腾，所以转向内建支持LSP的Helix，尝试在FreeBSD上新的编辑器体验。

功能
=======

- 类似vim的模式编辑
- 多种选择方式
- 内建 :ref:`helix_lfs`
- 通过 ``tree-setter`` 实现智能、增量型的语法高亮和代码编辑器

安装
=========

FreebSD
-----------

FreebSD发行版已经提供了Helix，可以通过 ``pkg`` 安装:

.. literalinclude:: helix_startup/freebsd_install_helix
   :caption: FreeBSD安装helix

使用
=======

配置vim键盘映射(放弃)
-------------------------

Helix虽然借鉴了 ``Kaboune`` 和 :ref:`nvim` 设计，但是主要偏向于 ``Kaboune`` 。所以默认的键盘模式采用了和 ``vim`` 略有差别的快捷键( `Migrating from Vim <https://github.com/helix-editor/helix/wiki/Migrating-from-Vim>`_ )。由于多年使用vim形成的肌肉记忆，所以我依然希望helix能够采用vim的模式，所以采用 `LGUG2Z/helix-vim/config.toml <https://github.com/LGUG2Z/helix-vim/blob/master/config.toml>`_ 更改默认配置:

.. note::

   `Vim keymap for Helix #4419 <https://github.com/helix-editor/helix/issues/4419>`_ 的讨论非常有启发: ``0atman`` 提出了值得思考的设计理念:

   **工具的一致性** 而不是片面追求更优雅的特例: 保留 HELIX 的先选择后执行默认设置。但允许为 emacs 和 vim 模式配置原生绑定
   
   他提出理念其实是很好的产品设计理念:

   - **标准化总是胜过技术正确性** : Colemak 和 Dvorak 的打字速度比 Qwerty 键盘快得多，也更符合人体工程学，但是Qwerty使用最广，为了能够保持一致体验，用户会依然选择Qwerty键盘
   - 类似Qwerty键盘的商业案例，如果不作出一点让步，Helix就有可能被淘汰；而提供抵消的vim或emacs模式，可能会拥有1000倍的用户

   不过Helix开发者拒绝了这个建议，以及一些用户从其他角度的分析也很有说服力:

   - Helix的目标是开发更好的编辑器，而不是取代vim/emacs
   - Helix的内部设计使得采用vim键盘模式会增加大量容易误导的开发工作
   - 虽然vim用户会欢迎这种兼容模式，但是对于不使用vim/emacs的用户，例如 :ref:`vscode` 和 Jetbrain 的用户，会带来困扰
   - 虽然不能在每个地方都立即使用helix，但是跨平台支持安装，还是很容易确保自己的工作环境中具备相同的开箱即用的helix

   有一个用户提到他不依赖vim插件，现在转为使用helix:

   - 拒绝导入vim键盘绑定功能，因为类似vim这样不同的编辑器配置和文档存在严重的碎片化和歧义问题
   - vim/nvim大量插件存在相互冲突的配置，使得基本用户无所适从

   我这个讨论非常有意思，就像拥有无数发行版的Linux和只有一个发行版的FreeBSD:

   - vim确实浪费了我大量的时间来探索研究如何配置一个可用的 :ref:`nvim_ide` 环境，并且眼花缭乱的社区配置充满了歧义和冲突，导致我每隔一段时间配置就要调整和重新研究
   - 有点类似Linux，其实更应该研究统一的内核而不是不同发行版各不相同的包管理和配置差异；对于编辑器，不应该聚焦于程序开发而不是反复配置界面和编辑器功能
   - 我现在更喜欢FreeBSD，就是为了能够更聚焦于核心的开发工作；类似helix，我或许应该尝试全新的编辑器

.. note::

   使用 `LGUG2Z/helix-vim/config.toml <https://github.com/LGUG2Z/helix-vim/blob/master/config.toml>`_ 和原本的vim还是有细微差别

- 修改 ``~/.config/helix/config.toml`` :

.. literalinclude:: helix_startup/config.toml
   :caption: 配置兼容vim模式的 ``~/.config/helix/config.toml``

helix编辑模式
-----------------

待续...

参考
======

- `Vim keymap for Helix #4419 <https://github.com/helix-editor/helix/issues/4419>`_


参考
======

- `Helix Package managers <https://docs.helix-editor.com/package-managers.html>`_
