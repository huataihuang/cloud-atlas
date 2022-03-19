.. _vim_tmux_iterm_zsh:

======================================
结合Vim,Tmux,iTerm和Oh-my-Zsh开发环境
======================================

我在 :ref:`install_vim` 中花费了不少精力在Linux环境编译适合运行you-complete-me的vim，但是对于我们开发目标其实是非常分散精力的。我一直在尝试能够快速构建一个完善的vim开发环境，作为使用macOS作为桌面的工作者，在Mac环境下可以利用现有的工具来实现。

iTerm
=======

作为macOS最佳终端模拟器，提供了结合 :ref:`tmux` 以及各种便利功能，可以通过 :ref:`homebrew` 快速安装::

   brew install --cask iterm2

Vim
=======

虽然macOS内置了vim，但是版本比较陈旧不适合运行很多高级功能，例如不支持you-complete-me的最新版本，所以我们也通过 :ref:`homebrew` 安装::

   #编译you-complete-me需要使用macvim，所以替换vim
   brew install macvim
   # 要安装 you-complete-vim 还需要cmake
   brew install cmake

Tmux
=======

Tmux是一个终端多路管理器，可以同时在一个单一屏幕中管理多个终端会话，常常用来替代 ``screen`` 实现中断工作环境的自动保持和恢复::

   brew install tmux

Oh-my-Zsh
============

zsh已经是macOS推荐的内置shell，Oh-my-zsh提供了定制框架，能够极大提高工作效率::

   brew install zsh
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

组合工具
========

安装了 Vim,Tmux,iTerm和Oh-my-Zsh 之后，我们把这些工具组合起来使用以便发挥最大效力：

- 安装Vundle作为插件管理器::

   git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

- clone Danielshow 提供的Boxsetting::

   git clone https://github.com/Danielshow/BoxSetting
   cd BoxSetting

- 复制配置文件::

   cp tmux.conf ~/.tmux.conf
   cp vimrc ~/.vimrc
   cp zshrc ~/.zshrc

这里 ``~/.zshrc`` 中用户目录配置需要修改成你自己的home目录。

- 安装npm（参考 :ref:`nodejs_dev_env` ） - 参考原文使用npm安装 `spaceship-prompt <https://github.com/denysdovhan/spaceship-prompt>`_ ::

   curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
   nvm install node

- 安装 `spaceship-prompt <https://github.com/denysdovhan/spaceship-prompt>`_ ::

   npm install -g spaceship-prompt

   # 这里用户名是 huatai ，请修改成你的名字
   ZSH_CUSTOM=/Users/huatai/.oh-my-zsh
   git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"

   # 软连接
   ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

- 修改 ``~/.zshrc`` 注释掉一些还没有安装的插件，确保启动终端不再报错

- ``spaceship-prompt`` 使用了 `Powerline Font <https://github.com/powerline/fonts>`_ ，需要安装以后才能展示非常忙美观的字符图标::

   # clone
   git clone https://github.com/powerline/fonts.git --depth=1
   # install
   cd fonts
   ./install.sh
   # clean-up a bit
   cd ..
   rm -rf fonts

完成安装以后，可以在 ``iterm2`` 中配置字体，例如选择对编程优化的 ``Fira Mono for Powerline`` 字体(15)

- 打开 ``vim`` ，执行命令::

   :PluginInstall

- 如果在编译安装 you-complete-me 时候有些报错则通过以下方式fix::

   # 之前使用vim发现确实编译失败，所以改为macvim
   brew install cmake macvim
   cd ~/.vim/bundle/YouCompleteMe
   ./install.py

我遇到报错显示我的操作系统是 10.13 但是编译目标确实10.9::

   building '_watchdog_fsevents' extension
   creating /Users/huatai/.vim/bundle/youcompleteme/third_party/ycmd/third_party/watchdog_deps/watchdog/build/3
   ...
   .../watchdog_fsevents.c:191:25: warning: 'kFSEventStreamEventFlagItemCloned' is only
      available on macOS 10.13 or newer [-Wunguarded-availability-new]
   ...

解决的方法可能是手工安装一次 ``watchdog`` 模块::

   sudo python3 -m pip install -U watchdog

完整的安装脚本
=================

为方便再次完成上述 :ref:`macos` 新系统初始化，整理为以下安装脚本:

.. literalinclude:: vim_tmux_iterm_zsh/macos_dev_init.sh
   :language: bash
   :linenos:
   :caption: macOS开发环境初始化脚本

参考
======

- `Setting up Vim, Tmux, iTerm and Oh-my-Zsh. <https://www.codementor.io/@danielshotonwa53/setting-up-vim-tmux-iterm-and-oh-my-zsh-134dvb9u4x>`_
