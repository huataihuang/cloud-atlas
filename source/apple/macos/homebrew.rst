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

.. warning::

   实际上在墙内，执行第一步在线安装命令就会出错，原因是GFW屏蔽了 ``raw.githubusercontent.com`` 。不过，这个脚本实际上可以下载到本地执行(通过墙外VPS搬运回来)。这样只要开始执行安装脚本，接下来就是如何让 :ref:`git` 和 :ref:`curl` :ref:`across_the_great_wall` 了，我在下文提供了解决方法。

安装网络阻塞问题的解决方法
------------------------------

安装Homebrew的最大麻烦是 GFW 对GitHub的干扰(并不是完全不通，但是不断间歇阻塞会浪费大量的时间精力)，解决的方法是使用代理。安装脚本中涉及到 ``curl`` 和 ``git`` 都需要配置代理。我采用的方法是: 

socks代理
~~~~~~~~~~

采用 :ref:`ssh_tunneling_dynamic_port_forwarding` 构建本地socks代理，然后结合简单的 :ref:`curl_proxy`

- 我最初采用socks结合squid代理 ( :ref:`squid_socks_peer` 方案可以在本地构建一个squid代理，通过墙外到二级代理实现无障碍访问)，不过感觉对桌面来说有点复杂，所以改为更为简单的 :ref:`curl_proxy`

.. literalinclude:: ../../infra_service/ssh/ssh_tunneling_dynamic_port_forwarding/ssh_tunnel_dynamic
   :caption: 执行一条命令建立起动态端口转发的翻墙ssh tunnel


.. literalinclude:: ../../web/curl/curl_proxy/socks5_proxy_env
   :caption: 配置curl的socks5代理环境变量

- :ref:`git_proxy`

.. literalinclude:: ../../devops/git/git_proxy/git_config_http.proxy_socks5
   :language: bash
   :caption: 全局配置git使用socks5代理

squid代理 :ref:`squid_socks_peer`
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

由于墙内访问VPS阻塞严重，所以我改进为采用阿里云墙内服务器转跳方式的 squid代理 :ref:`squid_socks_peer` 也就是对于本地客户端而言，实际上是通过HTTP代理完成访问的

此外，参考 `How to install an homebrew package behind a proxy? <https://apple.stackexchange.com/questions/228865/how-to-install-an-homebrew-package-behind-a-proxy>`_ 有一个简单设置方法:

.. literalinclude:: homebrew/homebrew_proxy
   :language: bash
   :caption: 配置brew使用代理服务器 192.168.6.200 端口 3128 (案例采用局域网部署的 :ref:`squid` )

:ref:`vpn_hotspot`
~~~~~~~~~~~~~~~~~~~

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

- ``brew`` 提供了重启服务的功能，例如重启 :ref:`macos_homebrew_nginx` :

.. literalinclude:: ../../web/nginx/macos_homebrew_nginx/brew_restart_nginx
   :language: bash
   :caption: 使用brew重启nginx

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

服务起停
============

``brew`` 提供了一个 ``services`` 方式来启动和停止服务以及管理服务的自动启动

- 通过以下命令 ``tapping`` ``homebrew/services`` (只需要执行一次):

.. literalinclude:: homebrew/tap_services
   :caption: 安装 ``brew services``

- 通过以下命令可启动/停止 nginx 服务，其中 ``start`` 命令不仅启动nginx而且会设置nginx随着操作系统启动而启动:

.. literalinclude:: homebrew/services_start_stop_nginx
   :caption: ``brew`` 启动和停止nginx

- ``list`` 命令可检查当前系统所有服务:

.. literalinclude:: homebrew/services_list
   :caption: ``brew`` 检查系统所有服务

输出类似:

.. literalinclude:: homebrew/services_list_output
   :caption: ``brew`` 检查系统所有服务输出案例


实践和必备安装
=================

brew很好地弥补了 macOS 的开源软件版本滞后的短板，强烈建议在拿到macOS笔记本新系统时完成以下安装:

.. literalinclude:: homebrew/brew_install
   :language: bash
   :caption: 在macOS新系统必装的brew软件

.. note::

   - (现在我改为使用 :ref:`nvim` ))macOS内置的vim不支持python3，会导致类似 :ref:`jedi-vim` 缺失错误(即使 :ref:`virtualenv` 安装了 ``jedi`` 模块也无效)，所以强烈推荐Homebrew的vim with-python3。
   - :ref:`nvim` 是现代化vim的实现，目前我采用 :ref:`nvim` 代替 :ref:`vim` 以便实现快速的IDE构建
   - :ref:`tmux` 是常用的多路会话软件，虽然从iterm2官网下载安装包也内置了安装 :ref:`tmux` 功能，但是为了方便升级并使用最新版本，采用 ``homebrew`` 来安装 ``iterm2``
   - macOS内置awk和sed，但是语法和GNU版本有差异，编写Linux上运行脚本采用较为通用的GNU版本
   - :ref:`openconnect_vpn` 客户端方便翻越GFW
   - iterm2提供了最佳终端，可以采用 :ref:`vim_tmux_iterm_zsh`
   - Homebrew提供了 :ref:`docker_desktop` 集成安装，可以方便实现Docker官方版本安装部署
   
安装了homebrew :ref:`vim` 或 :ref:`nvim` 之后，会依赖安装多种开发语言，其中包括 :ref:`python` 3的最新版本，比macOS内置版本更好，所以建议切换到homebrew版本:

.. literalinclude:: homebrew/switch_python3_to_homebrew_version
   :language: bash
   :caption: 切换macOS的python3版本到homebrew提供的版本

Big Sur安装homebrew
====================

.. note::

   参考 `Homebrew Documentation: Installation <https://docs.brew.sh/Installation>`_ 说明，当前（2024年初)要求操作系统是 macOS Monterey(12)或更高版本。更早的10.11(EI Capitan) - 11(Big Sur)不被官方支持，仅提示可能工作，更早的10.10(Yosemite)及之前版本已明确不支持。

   早期的10.4(Tiger)-10.6(Snow Leopard)以及PPC支持则需要采用fork出来的 `Tigerbrew <https://github.com/mistydemeo/tigerbrew>`_  

   由于我的笔记本非常古老，只能安装 Big Sur (11)，所以安装非常折腾。

Command Line Tools版本过低
---------------------------

我现在使用的笔记本电脑都是10年前的古旧硬件，无法安装最新的macOS，最高只能支持Big Sur，也就是 macOS 11.7.10 。这带来一个问题，就是默认初始安装的 Command Line Tools 版本比较旧。此时Homebrew安装应用会提示报错:

.. literalinclude:: homebrew/command_line_tools_error
   :caption: 由于Command Line Tools版本过低导致Homebrew安装应用报错
   :emphasize-lines: 1,14,23

需要注意安装Command Line Tools后等待升级提示并完成升级到 13.2 版本之后再安装Homebrew才能避免错误。如果系统没有提升升级(例如我的实践)，则可以按照上面输出提示尝试删除掉已经安装的Command Line Tools之后再次安装。过一会就有提示升级，可以升级Command Line Tools 到 13.2

pip安装失败
-------------

另一个问题是安装过程出现pip错误:

.. literalinclude:: homebrew/pip_error
   :caption: 安装过程pip报错

既然是执行 ``pip`` 报错，那么完整执行命令:

.. literalinclude:: homebrew/pip_command
   :caption: 完整执行pip命令

报错信息如下:

.. literalinclude:: homebrew/pip_command_output
   :caption: 完整执行pip命令报错信息

这个问题比较尴尬，之所以会启用socks代理，是为了解决 :ref:`across_the_great_wall` ，但是网络看来欠佳。我最后是通过改进为通过墙内部署 :ref:`ssh_tunneling` 转发端口来加速网络，最终完成安装

openssl卡在make test
---------------------

一个奇怪的问题，openssl编译成功，但是 ``make test`` 会卡住:

.. literalinclude:: homebrew/openssl_make_test
   :caption: 卡在make test的openssl安装

我尝试单独安装

.. literalinclude:: homebrew/openssl_install
   :caption: 单独安装openssl 3

输出显示 

.. literalinclude:: homebrew/openssl_install_output
   :caption: 单独安装openssl 3输出显示

然后检查 ``~/Library/Logs/Homebrew/`` 目录下日志 ``tail -f openssl@3/04.make`` 可以看到进展情况

.. literalinclude:: homebrew/openssl_make_test_error
   :caption: openssl make test错误日志输出
   :emphasize-lines: 7,11,13,32

观察看到 ``make test`` 会请求本地回环地址端口进行测试，但是我为了解决网络连接问题，特意使用了代理，似乎存在冲突。所以添加去除本地回环地址代理

参考
===========

- `How to use pip with socks proxy? <https://stackoverflow.com/questions/22915705/how-to-use-pip-with-socks-proxy>`_
