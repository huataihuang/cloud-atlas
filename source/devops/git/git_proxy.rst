.. _git_proxy:

==============
git配置代理
==============

HTTP/HTTPS proxy
===================

我在安装 :ref:`homebrew` 时候，遇到GFW干扰无法正常访问GitHub。分析安装脚本，可以看到需要解决 ``git`` 网络联通问题。我的解决方法是采用 :ref:`squid_socks_peer` 构建起 HTTP/HTTPS 代理

- 配置 ``git`` 使用上述 HTTP/HTTPS 代理:

.. literalinclude:: git_proxy/git_config_http.proxy
   :language: bash
   :caption: 全局配置git使用HTTP/HTTPS代理

.. note::

   当配置git使用HTTP/HTTPS代理时，会使得git采用HTTPS方式代替 :ref:`ssh` 方式来访问git仓库。我遇到一个问题是 :ref:`build_lineageos_20_pixel_4` 结合使用 :ref:`squid_socks_peer` 同步 ``googlesource`` 仓库报错:

   解决的方法是独立编译 :ref:`git-openssl`

- 配置 ``git`` 使用socks5代理:

.. literalinclude:: git_proxy/git_config_http.proxy_socks5
   :language: bash
   :caption: 全局配置git使用socks5代理

配置 ``socks5`` 或者 ``socks5h`` 都可以，不过 ``socks5h`` 可以使得主机名解析也通过代理

SSH proxy
==============

- git ssh proxy command:

.. literalinclude:: git_proxy/git_ssh
   :caption: git ssh proxy

- **OR** use ``~/.ssh/config`` :

.. literalinclude:: git_proxy/git_ssh_config
   :caption: git ssh proxy config

参考
======

- `Configure Git to use a proxy <https://gist.github.com/evantoli/f8c23a37eb3558ab8765>`_
- `How do I pull from a Git repository through an HTTP proxy? <https://stackoverflow.com/questions/128035/how-do-i-pull-from-a-git-repository-through-an-http-proxy>`_
- `Using a socks proxy with git for the http transport <https://stackoverflow.com/questions/15227130/using-a-socks-proxy-with-git-for-the-http-transport>`_
- `Use git over socks5 proxy <https://gist.github.com/bynil/2126e374db8495fe33de2cbc543149ae>`_
