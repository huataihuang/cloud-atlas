.. _homebrew:

=============
Homebrew
=============

安装Homebrew
=============

- 只要主机联网，通过以下命令就能够直接安装homebrew:

.. literalinclude:: homebrew/install_homebrew
   :language: bash
   :caption: 通过网络安装Homebrew

.. note::

   会提示安装 Xcode command tools，请按照提示安装命令行工具，并继续安装Homebrew

.. note::

   安装过程反复出现SSL错误::

      ==> Downloading and installing Homebrew...
      fatal: unable to access 'https://github.com/Homebrew/brew/': LibreSSL SSL_read: SSL_ERROR_SYSCALL, errno 54
      Failed during: git fetch origin master:refs/remotes/origin/master --tags --force

   可能和curl版本有关，参考 `cURL SSL_ERROR_SYSCALL (OpenSSL\LibreSSL) #4099 <https://github.com/Homebrew/brew/issues/4099>`_ 尝试::

      echo '--no-alpn' > ~/.curlrc
      export HOMEBREW_CURLRC=1

   有可能再出现error 60，不过那是因为网络超时导致(GFW干扰)::

      fatal: RPC failed; curl 56 LibreSSL SSL_read: SSL_ERROR_SYSCALL, errno 60
      fatal: the remote end hung up unexpectedly

安装网络阻塞问题的解决方法
------------------------------

安装Homebrew的最大麻烦是 GFW 对GitHub的干扰(并不是完全不通，但是不断间歇阻塞会浪费大量的时间精力)，解决的方法是使用代理。安装脚本中涉及到 ``curl`` 和 ``git`` 都需要配置代理。我采用的方法是:

- :ref:`squid_socks_peer` 方案可以在本地构建一个squid代理，通过墙外到二级代理实现无障碍访问
- :ref:`curl_proxy`
- :ref:`git_proxy`

此外，参考 `How to install an homebrew package behind a proxy? <https://apple.stackexchange.com/questions/228865/how-to-install-an-homebrew-package-behind-a-proxy>`_ 有一个简单设置方法:

.. literalinclude:: homebrew/homebrew_proxy
   :language: bash
   :caption: 配置brew使用代理服务器 192.168.6.200 端口 3128 (案例采用局域网部署的 :ref:`squid` )

我还采用了一种方法是借助 :ref:`vpn_hotspot` ，通过手机VPN共享给局域网使用，使得自己的桌面电脑能够翻墙直接访问Homebrew的软件仓库，才能顺利完成Homebrew安装。

我在完成 Homebrew 安装完成后，立即安装 :ref:`openconnect_vpn` 客户单 ``openconnect`` ，这样可以方便 :ref:`macos` 翻墙，实现很多必要的软件安装::

   brew install openconnect

使用brew
=========

- brew使用帮助::

   brew help

- 检查是否存在安装问题::

   brew doctor

- 搜索应用程序::

   brew search

- 安装::

   brew install packgename

- 列出所有Homebrew安装的应用::

   brew list

- 删除应用::

   brew remove packagename

- 更新Homebrew自身::

   brew update

- 查看是否有软件包没有及时更新::

   brew outdated

- 更新所有软件包或单个软件包::

   brew update
   brew update packagename

- 将一个软件包保持在某个版本::

   brew pin packagename

- 解除软件包版本锁定::

   brew unpin packagename

Homebrew Cask
===============

`Homebrew Cask <https://github.com/Homebrew/homebrew-cask>`_ 扩展了Homebrew并且将它提升到优雅、简洁、安装迅速，同时提供了管理macOS GUI程序的功能，例如可以安装Atom和Google Chrome。

.. note::

   Homebrew Cask提供了安装图形软件的功能，也就是说，如果要使用 ``brew install`` 安装一个macOS上的图形软件，通常就是使用 ``brew install --cask XXX``

   例如，安装 :ref:`install_docker_macos` 中安装Docker Desktop on Mac，应该使用:

   .. literalinclude:: ../../docker/desktop/install_docker_macos/brew_install_docker
      :language: bash
      :caption: 通过Homebrew安装Docker Desktop for macOS

   如果使用 ``brew install docker`` 则只安装docker命令行

- 不需要单独安装homebrew cask，你只需要使用，例如你想安装 atom 编辑器，则执行::

   brew cask install atom

然后你就可以使用atom编辑器了。

不过，2021年时候，使用上述命令会出现报错::

   Updating Homebrew...
   Error: Unknown command: cask

这是因为最新版本brew已经改变成::

   brew install --cask atom

.. note::

   你可以通过 `Homebrew Formulae <https://formulae.brew.sh/cask/>`_ 查看所有cask tap列表。

   这省却了我很多查找下载软件的时间，例如，最常用的开发IDE Visual Studio Code就可以直接安装::

      brew install --cask visual-studio-code

升级
========

macOS升级系统，可能会导致brew的软件无法正常工作。例如，出现无法使用vim::

   vim
   dyld: Library not loaded: /System/Library/Perl/5.28/darwin-thread-multi-2level/CORE/libperl.dylib
     Referenced from: /usr/local/Cellar/macvim/8.2-171/MacVim.app/Contents/MacOS/Vim
     Reason: image not found
   [1]    13046 abort      vim

这个报错，我参考 `dyld: Library not loaded: libperl.dylib Referenced from: perl5.18 <https://stackoverflow.com/questions/39675929/dyld-library-not-loaded-libperl-dylib-referenced-from-perl5-18>`_ 升级 brew 来修复::

   brew update
   brew upgrade

也可以单独升级某个异常软件::

   brew upgrade macvim

实践和必备安装
=================

brew很好地弥补了 macOS 的开源软件版本滞后的短板，强烈建议在拿到macOS笔记本新系统时完成以下安装:

.. literalinclude:: homebrew/brew_install
   :language: bash
   :caption: 在macOS新系统必装的brew软件

.. note::

   - macOS内置的vim不支持python3，会导致类似 :ref:`jedi-vim` 缺失错误(即使 :ref:`virtualenv` 安装了 ``jedi`` 模块也无效)，所以强烈推荐Homebrew的vim with-python3。
   - :ref:`tmux` 是常用的多路会话软件，虽然从iterm2官网下载安装包也内置了安装 :ref:`tmux` 功能，但是为了方便升级并使用最新版本，采用 ``homebrew`` 来安装 ``iterm2``
   - macOS内置awk和sed，但是语法和GNU版本有差异，编写Linux上运行脚本采用较为通用的GNU版本
   - :ref:`openconnect_vpn` 客户端方便翻越GFW
   - iterm2提供了最佳终端，可以采用 :ref:`vim_tmux_iterm_zsh`

安装了homebrew vim 之后，会依赖安装多种开发语言，其中包括 :ref:`python` 3的最新版本，比macOS内置版本更好，所以建议切换到homebrew版本:

.. literalinclude:: homebrew/switch_python3_to_homebrew_version
   :language: bash
   :caption: 切换macOS的python3版本到homebrew提供的版本

