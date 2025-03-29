.. _my_vimrc:

===================
我的vim配置
===================

虽然在 :ref:`install_vim` 中可以通过自定义编译以及插件安装方式，打造一个功能强大的IDE。不过，步骤相对繁琐。所以，我以 `Ultimate vimrc <https://github.com/amix/vimrc>`_ 为基础，重新构建一个精简的vim开发环境:

- `Ultimate vimrc <https://github.com/amix/vimrc>`_ 在GitHUB上拥有 26.8k 的Star，足以见得该项目的成功;并且还在不断改进
- `Ultimate vimrc <https://github.com/amix/vimrc>`_ ``awesome version`` 提供了精简但同时具备插件扩展，可以方便自己定制

Ultimate vimrc安装
====================

建议安装Awesome版本，包含了大量强大插件，并且非常容易扩展:

.. literalinclude:: my_vimrc/install_ultimate_vimrc.sh
   :language: bash
   :caption: 安装Ultimate vimrc Awsome版本

是的，安装步骤就是这么简单...

升级
-------

要升级 ``vimrc`` 执行以下命令(git rebase):

.. literalinclude:: my_vimrc/update_ultimate_vimrc.sh
   :language: bash
   :caption: 升级Ultimate vimrc

:ref:`jedi-vim`
-----------------

`Ultimate vimrc <https://github.com/amix/vimrc>`_ 使用了 `GitHub:jedi-vim <https://github.com/davidhalter/jedi-vim>`_ 来实现vim的 Python autocompletion，依赖于 ``python-jedi`` 。在 :ref:`arch_linux` 和 `strike`:`macOS` ( :ref:`macos` 系统自带vim不支持python也会报这个错误，但是 ``pip install jedi`` 不能解决这个问题，需要使用 :ref:`homebrew` 安装内置支持Python3的vim ) 上默认可能没有安装，此时使用 ``vim`` 编辑文件会提示错误::

   Error detected while processing BufRead Autocommands for "*.rst"..FileType Autocommands for "*"..Syntax Autocommands for "*"..function <SNR>14_SynSet[25]..script /usr/share/vim/vim90/syntax/rst.vim[230]../h
   ome/huatai/.vim_runtime/sources_non_forked/jedi-vim/after/syntax/python.vim[1]../home/huatai/.vim_runtime/sources_non_forked/jedi-vim/autoload/jedi.vim[260]..function jedi#init_python[13]..BufRead Autocomma
   nds for "*.rst"..FileType Autocommands for "*"..Syntax Autocommands for "*"..function <SNR>14_SynSet[25]..script /usr/share/vim/vim90/syntax/rst.vim[230]../home/huatai/.vim_runtime/sources_non_forked/jedi-v
   im/after/syntax/python.vim[1]../home/huatai/.vim_runtime/sources_non_forked/jedi-vim/autoload/jedi.vim[260]..function jedi#init_python[11]..<SNR>156_display_exception:
   line   19:
   Error: jedi-vim failed to initialize Python: jedi#setup_python_imports: ModuleNotFoundError: No module named 'jedi' (in BufRead Autocommands for "*.rst"..FileType Autocommands for "*"..Syntax Autocommands f
   or "*"..function <SNR>14_SynSet[25]..script /usr/share/vim/vim90/syntax/rst.vim[230]../home/huatai/.vim_runtime/sources_non_forked/jedi-vim/after/syntax/python.vim[1]../home/huatai/.vim_runtime/sources_non_
   forked/jedi-vim/autoload/jedi.vim[260]..function jedi#init_python[4]..<SNR>156_init_python[6]..jedi#setup_python_imports, line 20). See :messages and/or :JediDebugInfo for more information.

验证可以在 ``python`` 中执行 ``import jedi`` 会提示错误::

   >>> import jedi
   Traceback (most recent call last):
     File "<stdin>", line 1, in <module>
   ModuleNotFoundError: No module named 'jedi'

在 :ref:`arch_linux` 解决方法很简单，就是安装 ``python-jedi`` ::

   pacman -S python-jedi

也可以通过 ``pip`` 安装，例如在 :ref:`macos` 上，现在默认是python3/pip3，则执行以下命令安装::

   sudo pip3 install jedi

然后就可以正常使用

Ultimate vimrc配置
====================

安装完成后，打开 ``~/.vimrc`` 就会看出 `Ultimate vimrc <https://github.com/amix/vimrc>`_ 巧妙之处:

.. literalinclude:: my_vimrc/vimrc
   :language: bash
   :caption: 用户目录 ~/.vimrc
   :emphasize-lines: 11

`Ultimate vimrc <https://github.com/amix/vimrc>`_ 将默认配置文件划分为4类，对应4个标准默认配置文件；同时提供个用户一个自定义配置文件 ``~/.vim_runtime/my_configs.vim`` 让用户进行定制。我们的所有配置定制都应该在这个文件进行，避免项目原更新后本地配置被覆盖或冲突。

初步定制
=========

relative行号
-----------------

我觉得 ``relative linue number`` 可能是最值得启用的功能:

- 以往需要复制多行数据，往往需要肉眼计算需要 ``yy`` 多少行，繁琐而容易出错
- vim提供了自动现实相对行号的功能: 以当前光标行为基础，动态显示上下行的相对行差，这样就非常容易知道需要复制多少行能够覆盖需要复制的内容

启用命令::

   :set relativenumber
   :set rnu

关闭命令::

   :set norelativenumber
   :set nornu

不过，此时当前行一直显示是 ``0``  不是很直观。没关系，从 vim 7.4  开始可以同时启用当前行号和相对行号::

   :set number relativenumber
   :set nu rnu

- 在 ``~/.vim_runtime/my_configs.vim`` 中添加以下行启用上述功能::

   set nu rnu

字体色彩定制
---------------

`Ultimate vimrc <https://github.com/amix/vimrc>`_ 内置了多种 ``color schemes`` ，默认是 ``peaksea`` 。但是这个默认字体色彩比较暗淡(素雅)，阅读代码色彩对不不太强烈清晰，所以我修订为 ``dracula`` (暗黑模式尤其出彩)。

- 在 ``~/.vim_runtime/my_configs.vim`` 中添加以下行启用暗黑模式 ``dracula`` 色彩模式::

   set background=dark
   colorscheme dracula

完整 ``my_configs.vim``
---------------------------

- 最终完成 ``~/.vim_runtime/my_configs.vim`` :

.. literalinclude:: my_vimrc/my_configs.vim
   :language: bash
   :caption: ~/.vim_runtime/my_configs.vim

.. note::

   - :ref:`vim_auto_indent`
   - :ref:`vim_fold`

插件安装
==========

常规插件安装
----------------

`Ultimate vimrc <https://github.com/amix/vimrc>`_ 使用 `tpope / vim-pathogen <https://github.com/tpope/vim-pathogen>`_ 管理插件。 ``vim-pathogen`` 包装了著名的 `Vundle.vim GitHub <https://github.com/VundleVim/Vundle.vim>`_ ，提供自动插件安装

- 只需要将插件的github项目clone到 ``~/.vim_runtime`` 目录下，例如 ``XXX_plugin`` ::

   cd ~/.vim_runtime/my_plugins
   git clone https://github.com/xxx/XXX_plugin.git

- 然后打开vim应用， `Ultimate vimrc <https://github.com/amix/vimrc>`_ 会自动完成插件安装

YouCompleteMe插件
------------------

- 需要注意，默认 :ref:`kali_linux` 安装的是 ``vim.basic`` ::

   $ ls -lh /etc/alternatives/vim
   lrwxrwxrwx 1 root root 18 Feb 10 04:06 /etc/alternatives/vim -> /usr/bin/vim.basic

这个基础版本vim没有内建支持Python::

   YouCompleteMe unavailable: requires Vim compiled with Python (3.6.0+) support.

那么要如何安装一个内置支持python的vim呢？

  - 安装 ``vim-nox``

    - 建议安装 ``vim-nox``

  - 或者 ``vim-pytonjedi`` (会依赖安装 ``vim-nox`` )

    - `jedi-vim - awesome Python autocompletion with VIM <https://github.com/davidhalter/jedi-vim>`_ (一个内建了自动代码完成库 `Jedi <http://github.com/davidhalter/jedi>`_ 的VIM)
    - 查看 `cm-core / YouCompleteMe <https://github.com/ycm-core/YouCompleteMe>`_ 项目就可以看到 ``YouCompleteMe`` 自身就是包含 ``a Jedi-based completion engine for Python 2 and 3``

.. note::

   在 :ref:`redhat_linux` 系列中，使用 :ref:`fedora` ，则安装 ``vim-enhanced`` 软件包::

      sudo dnf install vim-enhanced

安装完成后检查 ``/etc/alternative/vim`` 可以看到原先软链接到 ``/usr/bin/vim.basic`` 被修订成 ``/usr/bin/vim.nox`` ::

   $ ls -lh /etc/alternatives/vim
   lrwxrwxrwx 1 root root 16 Apr 26 07:24 /etc/alternatives/vim -> /usr/bin/vim.nox

- 完整安装依赖(包括支持python的vim版本，以及cmake等):

.. literalinclude:: my_vimrc/vimrc_ubuntu_dep_dev
   :language: bash
   :caption: Ubuntu编译YouCompleteMe依赖软件安装

.. literalinclude:: my_vimrc/vimrc_fedora_dep_dev
   :language: bash
   :caption: Fedora编译YouCompleteMe依赖软件安装

.. note::

   对于 :ref:`fedora` 需要安装 ``python3-devel`` ，不过默认可能已经安装

安装自己需要的开发软件

- 安装 :ref:`rust` :

.. literalinclude:: ../../../../rust/rust_startup/install_rust.sh
   :language: bash
   :caption: Liinux平台安装Rust

- 安装 :ref:`golang` / :ref:`nodejs` (支持TypeScript)

.. literalinclude:: my_vimrc/vimrc_ubuntu_go_nodejs
   :language: bash
   :caption: Ubuntu安装Go和node.js

.. literalinclude:: my_vimrc/vimrc_fedora_go_nodejs
   :language: bash
   :caption: Fedora安装Go和node.js

- 进入YouCompleteMe目录:

.. literalinclude:: my_vimrc/vimrc_prepare_ycm
   :language: bash
   :caption: 准备YCM目录

由于 ``golang.org`` 网站被GFW屏蔽，所以会导致编译时无法获取go模块，需要 :ref:`go_proxy` :

.. literalinclude:: ../../../../golang/go_proxy/alias_go_proxy.sh
   :language: bash
   :caption: alias设置go代理

由于 ``npm`` 需要访问 ``npmjs.com`` 已经被GFW屏蔽( ``npm.org`` 没有屏蔽，但是重定向到 ``npmjs.com`` )，所以也要 :ref:`npm_proxy` :

.. literalinclude:: ../../../../nodejs/startup/npm_proxy/npm_proxy
   :language: bash
   :caption: 设置npm代理

配置 ``git`` 代理:

.. literalinclude:: ../../../../devops/git/git_proxy/git_config_http.proxy
   :language: bash
   :caption: 全局配置git使用HTTP/HTTPS代理

由于 YouCompleteMe 编译需要从github下载 ``clangd`` 源代码tar包，所以还需要配置 :ref:`fedora_proxy`

按需编译YouCompleteMe：

.. literalinclude:: my_vimrc/compile_youcompleteme.sh
   :language: bash
   :caption: 按需编译YouCompleteMe

如果出现编译错误，可以按照提示采用debug模式来观察哪里出现错误::

   /usr/bin/python3 /home/huatai/.vim_runtime/my_plugins/YouCompleteMe/third_party/ycmd/build.py --clangd-completer --go-completer --ts-completer --rust-completer --verbose

使用YouCompleteMe
--------------------

编译安装 ``YouCompleteMe`` 之后，使用 ``vim`` 打开任何支持开发语言的项目，都会自动创建索引并支持代码自动完成功能。这对提高开发效率非常有帮助，几乎就是IDE的完备功能。不过需要注意，类似 :ref:`golang` 项目构建索引需要访问Internet上的golang网站，如果被GFW屏蔽，会导致 ``vim`` 长时间停滞在 ``loading packages``
状态而导致代码自动完成功能失效。

所以，务必确保 :ref:`go_proxy` 配置正确，即上述采用 ``alias`` 来保证 go 能够安装模块。



参考
=======

- `The (Ultimate) Vim(rc) Guide, with plugins <https://cyberchris.xyz/blog/2019/10/20/vim-guide>`_
- `Vim’s absolute, relative and hybrid line numbers <https://jeffkreeftmeijer.com/vim-number/>`_
- `YouCompleteMe unavailable: requires Vim compiled with Python (2.6+ or 3.3+) support #2573 <https://github.com/ycm-core/YouCompleteMe/issues/2573>`_
