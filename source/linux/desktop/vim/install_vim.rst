.. _install_vim:

==============
Vim安装
==============

Vim是传奇编辑器vi的继承者，功能强大但需要使用者不断训练形成 ``肌肉记忆`` 。在所有的Unix/Linux系统上都能够方便安装和使用，特别适合没有图形界面的远程终端开发环境。

使用Vim的优点:

- 轻量级和随处可得: 几乎所有Linux系统都能够快速安装，无需图形界面，适合远程服务器开发(ssh登录)
- 通过简单配置备份就可以随时恢复工作环境，构建适合开发 C/Python/Go 等所有主流开发语言

.. note::

   一直以来，我都没有系统学习过Vi，虽然不断使用，但是仅限于非常基本的使用操作。不过，对于服务器开发者，这个编辑器对于提高开发效率有极大帮助，依然值得投入学习。

.. note::

   本文是在树莓派的Raspberry Pi OS上实践，也即是Debian Linux系统上编译安装 ``vim`` + ``you-complete-me`` 以及vim插件；对于macOS环境通过 :ref:`homebrew` 组合多个工具配置相同环境请参考 :ref:`vim_tmux_iterm_zsh` 。

安装
======

- 在 :ref:`pi_400` 环境，也就是 Debian 10上安装::

   sudo apt install vim

配置
======

几乎不用配置，默认vim提供了基础的语法高亮。不过，你可以定制自己的 ``.vimrc`` 然后备份，并回复到任何你需要的工作环境中获得一致的体验。

- 初始你可以使用以下简单的 ``.vimrc`` :

.. literalinclude:: install_vim/vimrc_base
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

.. literalinclude:: install_vim/vimrc_vundle
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

.. literalinclude:: install_vim/vimrc_plugins
   :language: bash
   :linenos:
   :caption:
   :emphasize-lines: 11,12

- 然后在vim中执行命令::

   :PluginInstall

YouCompleteMe插件
------------------

.. note::

   YouCompleteMe 安装是非常繁琐的过程，特别是编译支持golang，需要下载大量依赖模块，而GFW阻塞

编译vim
~~~~~~~~~

YouCompleteMe插件对vim版本有要求，在树莓派当前Raspberry Pi OS中提供的vim版本不能满足。可以参考 `Building Vim from source <https://github.com/ycm-core/YouCompleteMe/wiki/Building-Vim-from-source>`_ 进行编译安装

- 首先安装依赖::

   sudo apt install libncurses5-dev libgtk2.0-dev libatk1.0-dev \
   libcairo2-dev libx11-dev libxpm-dev libxt-dev python2-dev \
   python3-dev ruby-dev lua5.2 liblua5.2-dev libperl-dev git

我不编译gvim，则不安装图形相关开发库，另外根据自己需要编写的语言安装开发库，可以取消部分不安装，例如，如果不编写perl，可以不安装 ``libperl-dev`` ::

   sudo apt install libncurses5-dev python2-dev \
   python3-dev ruby-dev lua5.3 liblua5.3-dev git
   
- 删除已经安装的vim::

   sudo apt remove vim vim-runtime gvim
   
- 编译 Vim ::

   git clone https://github.com/vim/vim.git
   cd vim
   ./configure --with-features=huge \
               --enable-multibyte \
               --enable-rubyinterp=yes \
               --enable-python3interp=yes \
               --with-python3-config-dir=$(python3-config --configdir) \
               --enable-perlinterp=yes \
               --enable-luainterp=yes \
               --enable-gui=gtk2 \
               --enable-cscope \
               --prefix=/usr/local

我的编译选项做了精简如下::

   ./configure --with-features=huge \
               --enable-multibyte \
               --enable-rubyinterp=yes \
               --enable-python3interp=yes \
               --with-python3-config-dir=$(python3-config --configdir) \
               --enable-luainterp=yes \
               --enable-cscope \
               --prefix=/usr/local   

.. note::

   对于Ubuntu用户，只能使用Python 2或Python 3，所以不能同时使用 ``python-config-dir`` 和 ``python3-config-dir`` ，否则 YouCompleteMe 会在启动vim时提示 ``YouCompleteMe unavailable: requires Vim compiled with Python (2.6+ or 3.3+) support`` 。

- 编译::

   make VIMRUNTIMEDIR=/usr/local/share/vim/vim82

- 为了方便卸载，先安装 `checkinstall <https://wiki.debian.org/CheckInstall>`_ 再进行安装(会按照系统包管理器生成包进行安装，这样就方便卸载)::

   sudo apt install checkinstall
   sudo checkinstall

- 也可以直接安装::

   sudo make install

- 设置vim作为默认编辑器::

   sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
   sudo update-alternatives --set editor /usr/local/bin/vim
   sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
   sudo update-alternatives --set vi /usr/local/bin/vim

安装其他插件
--------------

为了开发golang，另外安装 `vim-go插件 <https://github.com/fatih/vim-go>`_ 和 `Tagbar插件 <https://github.com/preservim/tagbar>`_ ::

   Plugin 'fatih/vim-go'
   Plugin 'Tagbar'

其中  ``Tagbar`` 需要 ``ctags/gotags`` 支持，依赖 ``Exuberant Ctags`` 和 ``Universal Ctags`` ，安装::

   sudo apt install exuberant-ctags universal-ctags
   go get -u github.com/jstemmer/gotags

配置golang的.vimrc
---------------------

- 配置 ``vim-go`` , ``Tagbar`` 和 ``NERDTree``

.. literalinclude:: install_vim/vimrc_golang
   :language: bash
   :linenos:
   :caption:
   :emphasize-lines: 34-84

编译安装YouCompleteMe
~~~~~~~~~~~~~~~~~~~~~~~~~

在编译YouCompleteMe之前，首先需要把你需要支持的语言开发工具安装好，然后才能在编译安装YouCompleteMe时候开启参数。

- 安装语言工具::

   apt install golang nodejs default-jdk npm

如果需要开发 c# ，还需要安装 ``mono-complete``

- 安装YCM编译工具::

   apt install build-essential cmake python3-dev

- 编译YCM::

   cd ~/.vim/bundle/youcompleteme
   python3 install.py --all

这里可以不使用 ``--all`` 参数，而单独指定需要支持的语言：

  - 需要支持 C一族语言使用 ``--clangd-completer``
  - 支持C# 则安装mono 然后使用 ``--cs-completer``
  - 支持Go 则安装Go然后使用 ``--go-completer``
  - 支持JavaScript和TypeScript 则安装 node.js 和 npm ，然后使用 ``--ts-completer``
  - 支持Rust 则使用 ``--rust-completer``
  - 支持Java 则安装JDK 8 然后使用 ``--java-completer``

如果不指定任何参数，则编译的YCM仅支持Python代码补全。

我使用如下编译方法::

   python3 install.py --clangd-completer --go-completer \
       --ts-completer --rust-completer --java-completer

遇到报错::

   ...
   reading manifest file 'src/watchdog.egg-info/SOURCES.txt'
   reading manifest template 'MANIFEST.in'
   warning: no files found matching '*.h' under directory 'src'
   writing manifest file 'src/watchdog.egg-info/SOURCES.txt'
   go: finding mvdan.cc/xurls/v2 v2.2.0
   go: mvdan.cc/xurls/v2@v2.2.0: unknown revision mvdan.cc/xurls/v2.2.0
   go: error loading module requirements

`xurls <https://pkg.go.dev/mvdan.cc/xurls/v2>`_ 是使用正则表达式解析url的工具，在Go 1.13开始使用。上述报错可以参考 `Getting: go: error loading module requirements <https://stackoverflow.com/questions/58253972/getting-go-error-loading-module-requirements>`_ ，主要是go模块下载问题，手工单独安装::

   go get mvdan.cc/xurls/v2@v2.2.0

提示::

   go: finding mvdan.cc/xurls/v2 v2.2.0
   go: downloading mvdan.cc/xurls v0.0.0-20200417124523-1707d8b9d1bb
   go get mvdan.cc/xurls/v2@v2.2.0: go.mod has post-v0 module path "mvdan.cc/xurls/v2" at revision 1707d8b9d1bb

但是我发现当前 :ref:`pi_400` 的Raspberry Pi OS提供的golang版本是 ``1.11`` ，可能低于 ``xurls`` 版本  ``1.13``  要求，使用以下命令检查仓库提供的golang版本::

   sudo apt-cache search golang|grep golang-1.*

可以看到软件仓库提供的最高版本只有 1.12 ，不能满足要求。

卸载Raspberry Pi OS tigong

使用YouCompleteMe
--------------------

当输入时，YCM会自动提示最接近的可选输入内容，可以持续输入直到真正匹配内容高亮，此时按下 ``tab`` 键自动完成输入:

.. figure:: ../../../_static/linux/desktop/vim/ycm.gif

参考
======

- `Install and Use Vim on Raspberry Pi <https://roboticsbackend.com/install-use-vim-raspberry-pi/>`_
- `CentOS 8 搭建Vim golang环境 && YouCompleteMe Golang安装支持 <https://blog.csdn.net/Wind4study/article/details/104565482>`_
- `配置vim,打造自己的C IDE <https://blog.csdn.net/liangsir_l/article/details/50608350>`_ - 这篇文档还没有实践，待完善
