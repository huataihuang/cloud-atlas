.. _git_proxy:

==============
git配置代理
==============

我在安装 :ref:`homebrew` 时候，遇到GFW干扰无法正常访问GitHub。分析安装脚本，可以看到需要解决 ``git`` 网络联通问题。我的解决方法是采用 :ref:`squid_socks_peer` 构建起 HTTP/HTTPS 代理，然后配置 ``git`` 使用上述 HTTP/HTTPS 代理::

   git config --global http.proxy http://192.168.10.106:8123

其他待实践...

参考
======

- `Configure Git to use a proxy <https://gist.github.com/evantoli/f8c23a37eb3558ab8765>`_
- `How do I pull from a Git repository through an HTTP proxy? <https://stackoverflow.com/questions/128035/how-do-i-pull-from-a-git-repository-through-an-http-proxy>`_
