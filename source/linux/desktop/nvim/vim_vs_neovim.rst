.. _vim_vs_neovim:

====================
vim vs. neovim
====================

差异
======

- 项目维护和功能改进

  - vim的首席开发者没有将vim发展成社区友好的项目: 添加功能支持缓慢(例如异步支持、内置终端仿真器和弹出窗口)
  - vim项目非常古老，代码可维护性较差
  - neovim在添加功能方面进展迅速

- Code auto-completion (LSP) - LSP(语言服务器协议)，定义编辑器如何与“语言服务器”通信，以启用代码突出显示、语法检查、代码完成、嵌入提示、类型提示等选项:

  - neovim 附带对 LSP 的开箱即用支持，并使用 Lua 进行进一步配置 - :ref:`coc.nvim` 提供了 coc extensions 来支持各种开发语言
  - vim 需要一个外部插件来实现此功能 ( 我之前实践 :ref:`vim_autocompletion` 花费了大量的精力 )

- 支持更好的插件 - 插件是现代化编辑器的必备功能:

  - vim 已经拥有丰富的插件支持和生态系统，以至于有专门针对 vim 的插件管理器
  - neovim 内置插件管理器，并且允许插件使用一种 "更通用的语言" Lua 中编写插件( vim 使用 ``vimscript`` )
  - neovim 的远程插件架构提供了 **远程过程调用(RPC)** 来扩展编辑器功能，这些调用可以使用任何编程语言异步进行
  - neovim 插件管理器比 vim 更为好用

- 插件对比:

  - vim常用插件:

    - YouCompleteMe: Vim 代码补全引擎，提供准确且上下文相关的建议，包括函数签名、变量名称和导入的模块
    - UltiSnips: Vim 的代码片段管理系统，允许开发人员使用可自定义的触发器快速插入常用的代码片段
    - vim-fugitive: vim 的 Git 集成插件，提供直接从编辑器与 Git 存储库交互的无缝方式
    - NERDTree: Vim 的文件系统浏览器，提供项目目录结构的树形视图
    - Vim-Plug: Vim 的插件管理器，可以简化 Vim 插件的安装和管理，支持并行安装、延迟加载和自动插件更新

  - neovim常用插件: Neovim 的一项显着功能是它对 **异步** 插件的支持，它允许插件在后台运行，而不会中断用户的工作流程。 这可以带来更流畅、更高效的编辑

    - :ref:`coc.nvim` : Neovim 的语言服务器协议客户端，可为多种编程语言（包括 Python）提供代码补全、语法突出显示和错误检查
    - Neomake: 为包括 Python 在内的各种编程语言提供异步链接和错误检查
    - Vim-Plug: Vim 的流行插件管理器，但它也适用于 Neovim。 它可以轻松安装和管理 Neovim 插件，并支持延迟加载和自动更新等功
    - deoplete: Neovim 的一个快速简单的代码补全插件，支持各种补全源，包括 YouCompleteMe 和 :ref:`coc.nvim` 它为 Python 中的代码补全提供上下文相关的建议，并且可以配置不同的补全引擎
    - nvim-tree.lua: Neovim 的文件系统资源管理器，提供项目目录结构的树形视图。 支持创建、删除、重命名等基本文件管理功能，并可定制各种图标和主题。

- 并行启动:

  - neovim能够并行启动每个插件，所以在初始化时候更快

- 嵌入编辑器:

  - neovim编辑器的代码库比vim相对容易维护，所以将核心编辑器嵌入到其他编辑器成为可能: 现在可以在 :ref:`vscode` 中嵌入使用 neovim
  - neovim对GTK和Qt等现代UI框架有更好的支持，这可以为编辑器带来更现代化的外观和感觉

- 标准化配置存放: 大多数现代 Linux 应用程序都遵循名为 XDG（跨桌面组）的标准，该标准规定用户特定的配置文件应存储在 ``~/.config`` 目录中

  - neovim 很好地遵循了XDG标准，主配置文件 ``init.nvim`` 存储在 ``~/.config/nvim/`` 目录中，这对于备份重要文件会相对方便

- 开箱即用:

  - vim 和 neovim 都提供了强大的配置能力，但是 **neovim 提供了更好的默认值** :

    - ``autoindent`` 默认激活
    - 默认使用黑色背景，除非在终端中明确设置
    - 默认激活 ``hlsearch`` (highlight all matches)

  - neovim 内置调试和分析功能对于 Python 开发人员来说是一个很大的优势

- 速度:

  - vim 占用内存很少，可以轻松处理大文件
  - neovim 更好地支持异步插件。 这意味着插件可以在后台运行，而不会阻塞编辑工作流程: 在处理大型项目或复杂文件时带来更好的性能

neovim的改进
==================

由于vim具有很长的开发历史，积累了超过30w行c语言代码，维护非常困难。neovim目标是重构vim源代码:

- 简化维护以提高错误修复和功能合并的速度
- 无需对核心源代码进行任何修改即可实现新的/现代的用户界面
- 通过基于协进程的新插件架构提高可扩展性: 插件可以用任何编程语言编写，无需编辑器的任何明确支持。
- 以上目标使得 neovim 对社区开发友好，能够快速迭代改进

neovim 不是重头开始的项目，是从 vim 7 fork出来进行重构，大多数 vimscript 插件可以继续工作:

- 迁移到CMake进行构建: 遗留过时代码被清理，并且删除了专门支持遗留系统和编译器的代码
- 大多数特定平台代码被删除，并使用 ``libuv`` (现代化的多平台库，具有执行常见系统任务功能，支持大多数Unix和Windows)处理系统差异
- 所有支持嵌入式脚本语言解释器的代码都被一个新的插件系统取代: 插件系统支持任何语言编写的扩展
- GUI作为插件实现，与 neovim 核心解耦

参考
=====

- `neovim introduction <https://github.com/neovim/neovim/wiki/Introduction>`_
- `Comparing Vim and Neovim for Python Developer <https://denisrasulev.medium.com/comparing-vim-and-neovim-for-python-developer-3baa1b4dbd8f>`_
- `How is NeoVim Different From Vim? <https://www.baeldung.com/linux/vim-vs-neovim>`_
- `7 Reasons Why Developers Prefer NeoVim Over Vim <https://linuxhandbook.com/neovim-vs-vim/>`_
- `I need a guide to configure everything from scratch.  <https://www.reddit.com/r/neovim/comments/15q0a4g/i_need_a_guide_to_configure_everything_from/>`_ 讨论如何配置neovim，可以作为信息参考起点
