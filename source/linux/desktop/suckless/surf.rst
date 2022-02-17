.. _surf:

=================================
surf - WebKit2/GTK+ 极简浏览器
=================================

`suckless.org surf <https://surf.suckless.org/>`_ 是一个极简化的浏览器。surf精简到不包括任何图形控制元素(没有任何导航菜单和按钮)，是通过 ``dmenu``  快捷键控制的。

在surf浏览器上，只包含浏览器页面以及可选的滚动条。Surf的主要功能是通过第三方 ``WebKitGTK`` 库实现，其他程序功能则提供窗口和一系列 ``XProperties`` 来控制该浏览器特性。

Surf支持cookies，但是不包含常规浏览器的常用功能，例如 ``tab`` 浏览，书签以及广告过滤。不过，surf通过patch，脚本和扩展程序来实现这些功能。surf默认只包含调用demnu程序的快捷键支持，其他大多数配置需要修改源代码头文件，然后重新编译来实现。

.. note::

   我感觉可能还是使用发行版直接提供的 :ref:`dwm` 和 surf 比较方便。虽然通过源代码能够定制修改，但是大多数情况下通用的配置已经够好，自己编译实在太花费时间精力了。

   如果后期搞 :ref:`lfs_linux` 再考虑源代码编译surf

   我甚至感觉在 :ref:`dwm` 环境下使用 firefox 也非常轻量级，速度和兼容性极佳。

安装
=======

- surf依赖 ``webkit2gtk`` ，所以需要安装开发库::

   sudo apt install libwebkit2gtk-4.0-dev libgcr-3-dev

- 另外参考Arch Linux的包列表依赖，补充安装 ``x11-utils`` (包含 ``xprop`` )::

   sudo apt install x11-utils

- 下载源代码及编译安装::

   git clone https://git.suckless.org/surf
   cd surf
   sudo make clean install

surf编译排查
--------------

编译报错::

   Package gcr-3 was not found in the pkg-config search path.
   Perhaps you should add the directory containing `gcr-3.pc'
   to the PKG_CONFIG_PATH environment variable`
   No package 'gcr-3' found
   surf.c:9:10: fatal error: glib.h: No such file or directory
       9 | #include <glib.h>
       |          ^~~~~~~~
   compilation terminated.
   make: *** [Makefile:31: surf.o] Error

参考 `Can't compile surf browser - missing /usr/include/glib.h <https://www.linux.org/threads/cant-compile-surf-browser-missing-usr-include-glib-h.37767/>`_ ，实际上 ``/usr/include/glib.h`` 已经移动到 ``/usr/include/glib-2.0/glib.h`` ( 根据 ``dpkg-query -S /usr/include/glib-2.0/glib.h`` 可以看到系统已经安装了 ``libglib2.0-dev`` : ``libglib2.0-dev:armhf: /usr/include/glib-2.0/glib.h`` )

在上述讨论中建议参考Arch Linux的surf包说明，先确保系统安装好:

- gcr - A library for bits of crypto UI and parsing (补充安装)
- webkit2gtk (安装 libwebkit2gtk-4.0-dev)
- xorg-xprop (安装 x11-utils)
- ca-certificates (ca-certificates-utils) (optional) – SSL verification (已经安装)
- curl (curl-git, curl-minimal-git) (optional) – default download handler (已经安装)
- dmenu (optional) – URL-bar (已经安装)
- tabbed (tabbed-git, tabbed-flexipatch-git) (optional) – tabbed frontend (我后续通过编译安装)
- xterm (jbxvt-git, xterm-git) (optional) – default download handler (不安装，使用 :ref:`st` )

我经过反复验证发现:

- 需要安装 ``libgcr-3-dev`` 才能在编译时消除 ``No package 'gcr-3' found``
- 需要安装 ``libwebkit2gtk-4.0-dev`` 才能使得 ``surf`` 编译正确找到 ``glib.h`` ，也就是说这个 ``glib.h`` 是属于 ``libwebkit2gtk-4.0-dev`` 而不是系统的 ``glib-2.0-dev``

**然后编译能够完成**

使用
======

``surf`` 没有任何常规浏览器的导航栏、菜单等等，就是一个简介的页面，就像一张画纸铺满整个可用的窗口空间。

是的，屏幕利用率非常高...但是，等等，怎么操作前进后退呢？

默认的快捷键是以 ``ctrl`` 引导的:

使用问题排查
==============

无法访问google
----------------

使用 ``surf`` 访问 ``google.com`` 会出现页面空白，终端输出信息::

   child exited with status 2

提示无法读取 ``default.css``
-----------------------------

发现访问很多网站时终端信息提示::

   Could not read style file: /home/huatai/.surf/styles/default.css

参考
=======

- `wikipedia: surf (web browser) <https://en.wikipedia.org/wiki/Surf_(web_browser)>`_
- `suckless.org surf <https://surf.suckless.org/>`_
- `Use the Surf Browser for a Minimalist Web-Browsing Experience <https://www.maketecheasier.com/surf-browser-minimalist-web-browsing-experience/>`_
