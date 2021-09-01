.. _install_vim_centos6:

==========================
在CentOS6上编译安装vim
==========================

:ref:`prepare_kernel_dev` 是在CentOS 6上进行的，主要是想在一个比较简化(低版本)环境中，学习内核开发、系统开发。所以也就依然需要在CentOS 6这样早期版本上准备开发环境。

为了能够使用最新特性，采用 :ref:`install_vim` 方法完整编译安装 ``vim`` + ``you-complete-me`` 以及vim插件。

准备工作
=============

不论是Debian系还是Fedora系，要完整编译 ``vim`` + ``you-complete-me`` 需要先安装相关库，请擦考 `Building Vim from source <https://github.com/ycm-core/YouCompleteMe/wiki/Building-Vim-from-source>`_ 。

我主要是在字符界面完成开发(通过ssh登陆到服务器上工作)，所以准备库安装略有不同::

   sudo yum install -y ncurses-devel ruby ruby-devel lua lua-devel luajit \
   luajit-devel ctags git python python-devel \
   python34 python34-devel tcl-devel

centos 6 发行版 ``没有`` 提供::

   luajit
   luajit-devel
   python3
   python3-devel

所以需要采用第三方软件仓库 EPEL安装。注意，CentOS 6已经EOL了，所以需要先 :ref:`fix_centos6_repo` ，然后执行上述安装 ``python34`` 。

编译vim
===========

- 安装前先删除系统之前安装的vim::

   yum remove vim-enhanced vim-filesystem vim-common

不过，还是保留 ``vim-minimal``

- 下载源代码::

   cd ~
   git clone https://github.com/vim/vim.git
   cd vim

- 编译(去除了gui支持)::

   ./configure --with-features=huge \
               --enable-multibyte \
               --enable-rubyinterp=yes \
               --enable-python3interp=yes \
               --with-python3-config-dir=$(python3-config --configdir) \
               --enable-luainterp=yes \
               --enable-cscope \
               --prefix=/usr/local

   make VIMRUNTIMEDIR=/usr/local/share/vim/vim82
   sudo make install

安装Vundle插件管理器
=========================

- Vundle管理插件::

   git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

- 配置 ``~/.vimrc`` :

.. literalinclude:: install_vim/vimrc_c
   :language: bash
   :linenos:
   :caption:

.. note::

   我这里在CentOS 6环境中只开发 C，所以没有像 :ref:`install_vim` 一样安装多种语言以及多种语言支持，如果需要开发多种语言，请参考 :ref:`install_vim` 。

- 安装插件: 执行 ``vim`` 命令，进入编辑器，然后执行::

   :PluginInstall

- 安装 ``YouCompleteMe`` 还需要进一步插件编译::

   cd ~/.vim/bundle/youcompleteme
   python3 install.py --clangd-completer

这里只编译支持C系列语言，如果要开发全系列语言则使用参数 ``--all`` ，详情参考 :ref:`install_vim`

安装插件
===========



参考
=========

- `Building Vim from source <https://github.com/ycm-core/YouCompleteMe/wiki/Building-Vim-from-source>`_