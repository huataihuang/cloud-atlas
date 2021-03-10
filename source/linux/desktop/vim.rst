.. _vim:

==============
Vim
==============

Vim是传奇编辑器vi的继承者，功能强大但需要使用者不断训练形成 ``肌肉记忆`` 。在所有的Unix/Linux系统上都能够方便安装和使用，特别适合没有图形界面的远程终端开发环境。

使用Vim的优点:

- 轻量级和随处可得: 几乎所有Linux系统都能够快速安装，无需图形界面，适合远程服务器开发(ssh登录)
- 通过简单配置备份就可以随时恢复工作环境，构建适合开发 C/Python/Go 等所有主流开发语言

.. note::

   一直以来，我都没有系统学习过Vi，虽然不断使用，但是仅限于非常基本的使用操作。不过，对于服务器开发者，这个编辑器对于提高开发效率有极大帮助，依然值得投入学习。

安装
======

- 在 :ref:`pi_400` 环境，也就是 Debian 10上安装::

   sudo apt install vim

配置
======

几乎不用配置，默认vim提供了基础的语法高亮。不过，你可以定制自己的 ``.vimrc`` 然后备份，并回复到任何你需要的工作环境中获得一致的体验。

- 初始你可以使用以下简单的 ``.vimrc`` :

.. literalinclude:: vim/vimrc_base
   :language: bash
   :linenos:
   :caption:

插件
======

Vundle插件管理器
-----------------

要充分发挥vim的强大功能，需要使用插件，可以实现现代IDE的语法高亮，自动补全，目录树视图，debug工具以及很多有用的功能。

推荐使用 Vundle管理插件::

   git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

然后在 ``.vimrc`` 的开头添加:

.. literalinclude:: vim/vimrc_vundle
   :language: bash
   :linenos:
   :caption:
   :emphasize-lines: 1-13

有关 Vuldle 的详细说明参考 `Vundle.vim GitHub <https://github.com/VundleVim/Vundle.vim>`_

安装插件
----------

安装插件的方法有2步:

- 在 ``.vimrc`` 中plugin位置处添加插件
- 在vim中执行 ``:PluginInstall``  命令

从 `VimAwesome网站 <https://vimawesome.com/>`_ 可以找到GitHub流行的插件列表，以下我们来实践安装 ``NerdTree`` 插件(文件系统树状浏览视图) 和 ``YouCompleteMe`` 插件(代码补全)

- 在 ``.vimrc`` 中添加 ``Plugin`` 行:

.. literalinclude:: vim/vimrc_plugins
   :language: bash
   :linenos:
   :caption:
   :emphasize-lines: 11,12

- 然后在vim中执行命令::

   :PluginInstall

YouCompleteMe插件
------------------

YouCompleteMe插件对vim版本有要求，在树莓派当前Raspberry Pi OS中提供的vim版本不能满足。可以参考 `Building Vim from source <https://github.com/ycm-core/YouCompleteMe/wiki/Building-Vim-from-source>`_ 进行编译安装

- 首先安装依赖::

   sudo apt install libncurses5-dev libgtk2.0-dev libatk1.0-dev \
   libcairo2-dev libx11-dev libxpm-dev libxt-dev python2-dev \
   python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git

我不编译gvim，则不安装图形相关开发库，另外根据自己需要编写的语言安装开发库，可以取消部分不安装，例如，如果不编写perl，可以不安装 ``libperl-dev`` ::

   sudo apt install libncurses5-dev python2-dev \
   python3-dev ruby-dev lua5.3 liblua5.3-dev git
   
- 编译 Vim

   

参考
======

- `Install and Use Vim on Raspberry Pi <https://roboticsbackend.com/install-use-vim-raspberry-pi/>`_
