.. _apt:

==========
APT包管理
==========

contrib/non-free软件包
=========================

有些厂商提供的软件包是存放在"捐献"(contrib)和"非自由"(non-free)范畴的，默认没有激活。例如，在NVIDIA CUDA提供了PyCUDA ( :ref:`jetson_pycuda` ) 就属于 contrib area 。

- 编辑 ``/etc/apt/sources.lst`` ，将 ``contrib`` 和 ``non-free`` 的配置行激活就可以使用 contrib 和 non-free 仓库::

   deb http://deb.debian.org/debian buster main contrib non-free
   deb-src http://deb.debian.org/debian buster main contrib non-free


APT代理
========

在墙内很多软件仓库由于GFW屏蔽，导致系统部署存在很大障碍。主要的解决方法是构建 :ref:`linux_vpn` 结合 :ref:`squid` 代理来翻墙，例如我在部署CentOS/SUSE的系统就采用 :ref:`polipo_proxy_yum` 。

Ubuntu/Debian使用的APT软件包管理也支持代理配置，这里我结合 :ref:`squid_socks_peer` 实现完美翻墙代理。

在Ubuntu上安装软件时，如果需要使用代理服务器，可以在 ``/etc/apt/apt.conf`` 中设置，添加如下行::

   Acquire::http::Proxy "http://yourproxyaddress:proxyport";

如果代理服务器需要密码和账号登陆，则将::

   "http://yourproxyaddress:proxyport";

修改成::

   "http://username:password@yourproxyaddress:proxyport";

proxy.conf
============

现在比较新的Ubuntu版本，有关apt的配置都存放在 ``/etc/apt/apt.conf.d`` 目录下，所以建议将代理配置设置为 ``/etc/apt/apt.conf.d/proxy.conf`` ::

   Acquire::http::Proxy "http://user:password@proxy.server:port/";
   Acquire::https::Proxy "http://user:password@proxy.server:port/";

文件查找
=========

我们经常需要找到某个程序文件属于哪个软件包，例如需要安装或者卸载某个文件。

- 对于已经安装的软件包，可以通过 ``dpkg`` 工具查找::

   dpkg -S /bin/ls

这个命令有点类似 :ref:`redhat_linux` 中的 ``rpm -q /bin/ls``

- 对于尚未安装的软件包，我们需要搜索软件仓库，则建议安装 ``apt-file`` 工具来搜索::

   sudo apt install apt-file
   sudo apt-file update
   apt-file find kwallet.h

此外，你可以可以通过 `Ubuntu Packages Search <http://packages.ubuntu.com/>`_ 网站来查找软件包。

参考
========

- `Configure proxy for APT? <https://askubuntu.com/questions/257290/configure-proxy-for-apt>`_
- `How do I find the package that provides a file? <https://askubuntu.com/questions/481/how-do-i-find-the-package-that-provides-a-file>`_
