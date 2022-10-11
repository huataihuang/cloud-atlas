.. _freebsd_synergy:

===============================
FreeBSD运行Synergy共享键盘鼠标
===============================

我在 :ref:`freebsd_wine` 遇到困难，所以考虑FreeBSD桌面简化(不模拟运行Windows应用)，而采用 :ref:`synergy` 来操作公司提供的MacBook，方便在FreeBSD上开发，同时能够使用必要的商业软件。

Synergy背后的symless公司只提供了Windows/macOS/Linux的二进制包(提供了方便的图形设置方法)，但是Synergy软件本身是GPLv2开源，所以在FreeBSD平台也有对应的移植，只不过没有方便的配置图形界面。

- 安装::

   pkg install synergy

安装以后系统中有2个程序:

- synergyc 客户端
- synergys 服务端

配置
======

我将FreeBSD作为服务端，也就是提供键盘鼠标共享，所以需要准备一个配置文件。默认配置文件案例是 ``/usr/local/etc/synergy.conf`` 将其复制到自己的用户目录::

   cp /usr/local/etc/synergy.conf /home/huatai/.synergy.conf

- 修订 ``/home/huatai/.synergy.conf`` :

.. literalinclude:: freebsd_synergy/synergy.conf
   :language: bash

- 启动服务器端::

   synergys -c /home/huatai/.synergy.conf --daemon

.. note::

   我的实践尚未完成，待继续

参考
=====

- `Synergy share keyboard and mouse from Freebsd to Mac or any other OS <https://forums.freebsd.org/threads/synergy-share-keyboard-and-mouse-from-freebsd-to-mac-or-any-other-os.70333/>`_
