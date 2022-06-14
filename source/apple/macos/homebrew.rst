.. _homebrew:

=============
Homebrew
=============

安装Homebrew
=============

- 只要主机联网，通过以下命令就能够直接安装homebrew::

   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

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

- 不需要单独安装homebrew cask，你只需要使用，例如你想安装 atom 编辑器，则执行::

   brew cask install atom

然后你就可以使用atom编辑器了。

不过，2021年时候，使用上述命令会出现报错::

   Updating Homebrew...
   Error: Unknown command: cask

这是因为最新版本brew已经改编成::

   brew install --cask atom

.. note::

   你可以通过 `Homebrew Formulae <https://formulae.brew.sh/cask/>`_ 查看所有cask tap列表。

   这省却了我很多查找下载软件的时间，例如，最常用的开发IDE Visual Studio Code就可以直接安装::

      brew cask install visual-studio-code

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
