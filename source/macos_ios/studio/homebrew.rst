.. _homebrew:

=============
Homebrew
=============

安装Homebrew
=============

- 只要主机联网，通过以下命令就能够直接安装homebrew::

   /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

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

   有可能再出现error 60，不过那是因为网络超时导致(GFW)重试即可::

      fatal: RPC failed; curl 56 LibreSSL SSL_read: SSL_ERROR_SYSCALL, errno 60
      fatal: the remote end hung up unexpectedly

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
